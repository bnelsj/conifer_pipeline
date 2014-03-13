from conifertools import ConiferPipeline, CallTable
import argparse
import numpy as np
import scipy.stats
import time

def genotype_family(call, p, sample_size, flank_probes=20):

    sampleID = call["sampleID"]
    chromosome=call["chromosome"]
    data = {}
    try:
        data["index"] = p.getConiferData(sampleID, chromosome)
        data["mo"] = p.getConiferData(sampleID.split(".")[0] + ".mo", chromosome)
        data["fa"] = p.getConiferData(sampleID.split(".")[0] + ".fa", chromosome)
        #data["mo"] = p.getConiferData(sampleID[0:5] + ".mo", chromosome)
        #data["fa"] = p.getConiferData(sampleID[0:5] + ".fa", chromosome)
    except:
        print "could not get data for family", sampleID.split('.')[0]
        #print "could not get data for family", sampleID[0:5]
        return False

    num_exons = len(data["index"].exons)
    exon_start = np.where(data["index"].exons["start"] == call["start"])[0][0]
    exon_stop = np.where(data["index"].exons["stop"] == call["stop"])[0][0]
    flank_start = max(0,exon_start - flank_probes)
    flank_stop = min(exon_stop + flank_probes + 1, num_exons)

    data_mask = np.zeros(num_exons, dtype=np.bool)
    data_mask[flank_start:flank_stop] = True

    out_r = []
    d_1 = data["index"].rpkm[data_mask]
    for s in np.random.choice(p.samples, size=sample_size, replace=False):
        if s == sampleID:
            continue
        d_2 = p.r.getExonValuesByExons(chromosome, flank_start, flank_stop, sampleList=[s]).rpkm.T
        try:
            m, _, r, _, _ = scipy.stats.linregress(d_1,d_2)
        except ValueError:
            print "Could not do linear regression!"
            print call
            print d_1
            print d_2
            r = 0
        out_r.append(r)
    out_r = np.array(out_r)
    tdist = scipy.stats.distributions.t(*scipy.stats.distributions.t.fit(out_r))

    _ , _, p_from_mother, _, _ = scipy.stats.linregress(data["index"].rpkm[data_mask], data["mo"].rpkm[data_mask])
    _ , _, p_from_father, _, _ = scipy.stats.linregress(data["index"].rpkm[data_mask], data["fa"].rpkm[data_mask])
    
    return {"mo": (tdist.cdf(p_from_mother), np.median(data["mo"].rpkm[exon_start:exon_stop+1])), 
            "fa": (tdist.cdf(p_from_father), np.median(data["fa"].rpkm[exon_start:exon_stop+1]))}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--conifer_file", action="store", required=True)
    parser.add_argument("--call_file", action="store", required=True)
    parser.add_argument("--outfile", "-o", action="store", required=True)
    parser.add_argument("--threshold", default=0.99)
    parser.add_argument("--sample_size", default=None)
    args = parser.parse_args()
    p = ConiferPipeline(args.conifer_file)

    calls = CallTable(args.call_file)
    calls.calls["familyID"] = map(lambda x: x[0:5], calls.calls.sampleID)
    new_calls = CallTable()
    offspring_calls = calls.filter(lambda x: x["sampleID"].endswith(("p", "s", "p1"))).calls
    #offspring_calls = calls.filter(lambda x: x["sampleID"][6] in ["p","s"]).calls
    parent_calls = calls.filter(lambda x: x["sampleID"].endswith(("m", "f", "mo", "fa"))).calls
    #parent_calls =  calls.filter(lambda x: x["sampleID"][6] in ["m","f"]).calls
    
    if args.sample_size:
        sample_size = int(args.sample_size)
    else:
        sample_size = len(p.samples)
    print sample_size
    total_calls = len(offspring_calls)
    cnt = 0
    for ix, c in offspring_calls.iterrows():
        # first check if parents already have calls:
        cnt += 1
        if cnt % 100 == 0:
            print "%d/%d" % (cnt, total_calls)

        familyID=c["familyID"]
        t = parent_calls[(parent_calls.familyID == familyID) &\
                         (parent_calls.chromosome == c["chromosome"]) &\
                         (parent_calls.start < c["stop"]) &\
                         (parent_calls.stop > c["start"])]

        if len(t) == 0:
            # if they do not have calls, then genotype and potentially add them
            t1 = time.time()
            res = genotype_family(c, p, sample_size=sample_size)
            print "GT done in %0.3f" % (time.time() - t1)
            if not res:
                # failed to get data from parents (missing samples?)
                continue
            from_mo = res["mo"][0]
            from_fa = res["fa"][0]

            if (from_mo >= args.threshold) or (from_fa >= args.threshold):
                print "threshold exceeded; genotyping all samples"
                res = genotype_family(c, p, sample_size=len(p.samples))
                from_mo = res["mo"][0]
                from_fa = res["fa"][0]

                if (from_mo >= args.threshold) and (from_fa < args.threshold):
                    # add call for the mother
                    new_call = c.copy()
                    new_call["sampleID"] = c["sampleID"].split(".")[0] + ".mo"
                    new_call["median_svdzrpkm"] = res["mo"][1]
                    new_call.set_value("genotyped_p", from_mo)
                    print "New call --> Mother (r=%f)" % from_mo
                    print new_call
                    new_calls.addCall(new_call.to_dict())
                elif (from_fa >= args.threshold) and (from_mo < args.threshold):
                    # add calll for the father
                    new_call = c.copy()
                    new_call["sampleID"] = c["sampleID"][0:5] + ".fa"
                    new_call["median_svdzrpkm"] = res["fa"][1]
                    new_call.set_value("genotyped_p", from_fa)
                    print "New call --> Father (r=%f)" % from_fa
                    print new_call
                    new_calls.addCall(new_call.to_dict())

    new_calls.save(args.outfile)
