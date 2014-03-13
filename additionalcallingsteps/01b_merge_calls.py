import pandas as pd
pd.set_option("display.line_width", 200)
from conifertools import ConiferPipeline, CallTable, CallFilterTemplate
import argparse
import numpy as np


def merge_calls(a, b):
    for f in ["sampleID","chromosome","state"]:
        if a[f] != b[f]:
            print "calls do not have same", f 
            print a, b
        
    for f in ["start","stop"]:
        assert a[f] != b[f]
    
    if a["start"] >= b["start"]:
        a,b = b,a
    merged = a.copy()
    merged["stop"] = b["stop"]
    merged["stop_exon"] = b["stop_exon"]
    merged["num_probes"] = b["stop_exon"] - a["start_exon"]
    merged["size_bp"] = b["stop"] - a["start"]
    merged["probability"] = np.mean([a["probability"],b["probability"]])
    merged["median_svdzrpkm"] = np.mean([a["median_svdzrpkm"],b["median_svdzrpkm"]])
    merged["stdev_svdzrpkm"] = np.mean([a["stdev_svdzrpkm"],b["stdev_svdzrpkm"]])
    if "merge_count" not in merged:
        merged = merged.set_value("merge_count", 2)
    else:
        merged["merge_count"] += 1
    return merged

def merge_calls_across_SD(calls, pipeline, max_distance_to_merge=50, min_sd_percent=0.5):
    out_calls = [] #pd.DataFrame(columns=list(calls.calls.columns) + ["merge_count"])
    chrom_probes = {chrom: pd.DataFrame(p.r.h5file.root.probes._f_getChild("probes_chr%d" % chrom).read()) for chrom in range(1,24)}
    for sampleID in set(calls.calls.sampleID):
        print sampleID
        sample_calls = CallTable(calls.calls[calls.calls["sampleID"] == sampleID])
        for chrom in set(sample_calls.calls.chromosome):
            chr_probes = chrom_probes[chrom]
            calls_to_merge = sample_calls.filter(lambda x: x["chromosome"] == chrom).calls.sort("start")
            if len(calls_to_merge) <= 1:
                # no calls to merge
                out_calls.append(calls_to_merge.ix[calls_to_merge.index[0]])#, ignore_index=True)
            else:
                # for each call, first check it is within the max_distance_to_merge
                # then check if the SD content between them is more than the min_sd_percent
                first_call = calls_to_merge.ix[calls_to_merge.index[0]]
                # start iterating on the second call
                for ix, second_call in calls_to_merge.ix[calls_to_merge.index[1:]].iterrows():
                    delta = second_call["start_exon"] - first_call["stop_exon"]
                    if (second_call["state"] == first_call["state"]) and (delta < max_distance_to_merge):
                        gap_sd_count = chr_probes.ix[xrange(first_call["stop_exon"],second_call["start_exon"])].isSegDup.sum()
                        gap_sd_percent = float(gap_sd_count)/delta
                        if gap_sd_percent >= min_sd_percent:
                            merged = merge_calls(first_call, second_call)
                            first_call = merged.copy()
                        else:
                            out_calls.append(first_call)#, ignore_index=True)
                            first_call = second_call
                    else:
                        # too far apart, do not merge
                        out_calls.append(first_call)#, ignore_index=True)
                        first_call = second_call                    
                #if not last_call_was_merged:
                out_calls.append(second_call)#, ignore_index=True)
    out_calls = pd.DataFrame(out_calls)
    return CallTable(out_calls)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--conifer_file", action="store", required=True)
    parser.add_argument("--call_file", action="store", required=True)
    parser.add_argument("--outfile", "-o", action="store", required=True)
    args = parser.parse_args()
    p = ConiferPipeline(args.conifer_file)

    calls = CallTable(args.call_file)
    m = merge_calls_across_SD(calls, p)

    m.save(args.outfile)

