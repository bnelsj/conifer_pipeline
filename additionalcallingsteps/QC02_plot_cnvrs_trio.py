import pandas
pandas.set_option("display.line_width", 200)
from conifertools import CallTable, ConiferPlotter, ConiferPlotTrack
import argparse
import os
import matplotlib
import matplotlib.pyplot as plt


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--conifer_file", action="store", required=True)
    parser.add_argument("--call_file", action="store", required=True)
    parser.add_argument("--out_dir", action="store", required=True)
    parser.add_argument("--min_freq", type=int, action="store", required=False, default=0)
    parser.add_argument("--max_freq", type=int, action="store", required=False, default=30)
    parser.add_argument("--cnvrID", type=int, nargs="*", action="store", required=False, default=None)
    parser.add_argument("--cohort", action="store", required=False, default = "SSC")
    args = parser.parse_args()

    
    INHERITED_CODES = ['fa_to_both', 'fa_to_pro', 'fa_to_sib', 'mo_to_both', 'mo_to_pro', 'mo_to_sib']
    calls = CallTable(args.call_file)
    del calls.calls["cnvrID"]# = calls.calls["cnvrID_%s" % args.cohort]
    if isinstance(args.cnvrID, list):
        calls = calls.filter(lambda x: x["cnvrID_%s" % args.cohort] in args.cnvrID)

    calls = calls.filter(lambda x: (x["cnvr_frequency_%s" % args.cohort] >= args.min_freq) & (x["cnvr_frequency_%s" % args.cohort] < args.max_freq))

    calls.calls["familyID"] = map(lambda x: x.split(".")[0], calls.calls.sampleID.values)
    offspring_calls = calls.filter(lambda x: x["sampleID"].endswith(("p1","s1","s2","s3")))
    parent_calls =  calls.filter(lambda x: x["sampleID"].endswith(("mo","fa")))
    sibling_calls = calls.filter(lambda x: x["sampleID"].endswith(("s1", "s2", "s3")))

    plotters = {}
    colors = {"fa": "b", "mo": "b", "sib": "g", "pro": "r"}
    for rel, codes in zip(["pro", "sib", "mo", "fa"], [["p1", "p2"], ["s1", "s2", "s3"], ["mo"], ["fa"]]):
        # create a plotter for each family member
        plotters[rel] = ConiferPlotter(args.conifer_file)
        # add the calls from that group
        t=ConiferPlotTrack(plotters[rel], data_in = calls.filter(lambda x: x["sampleID"].split(".")[1] in codes), 
                                   name="%s calls" % rel, collapse=False, color=colors[rel], linewidth=3, position=2.3)
        plotters[rel].add_track(t)
    
    # add the SD track to the proband plot
    SDtrack = ConiferPlotTrack(plotters["pro"],
                                   data_in = "/net/eichler/vol8/home/nkrumm/REFERENCE_INFO/hg19genomicSuperDups.bed",
                                   name="SD",
                                   color="y",
                                   position=2.5)
    plotters["pro"].add_track(SDtrack)
    
    esp_call_track = ConiferPlotTrack(plotters["pro"],
                                   data_in = CallTable("ESP.all_chr.qc.filtered.clustered.translated.csv"),
                                   name="ESP",
                                   collapse=False,
                                   color="0.5",
                                   linewidth=3,
                                   position=3)

    plotters["pro"].add_track(esp_call_track)

    # make output directories
    #out_dirs = {}
    #out_dirs["inh"] = os.path.join(args.out_dir, "inh")
    #out_dirs["denovo"] = os.path.join(args.out_dir, "denovo")
    #if not os.path.exists(out_dirs["inh"]):
    #    os.makedirs(out_dirs["inh"])
    #if not os.path.exists(out_dirs["denovo"]):
    #    os.makedirs(out_dirs["denovo"])
    
    for call in offspring_calls:
        print call
        cnvrID = call["cnvrID_%s" % args.cohort]
        fID = call["familyID"]
        rel = call["sampleID"].split(".")[1]
        #if cnvrID in parent_calls.calls[parent_calls.calls.familyID==fID]["cnvrID_SSC"].values:
        #if call.inh in INHERITED_CODES:
            # inherited event
        outdir = args.out_dir
        #else:
            # potential de novo
        #    outdir = os.path.join(out_dirs["denovo"], "chr%d" % call["chromosome"])

        if not os.path.exists(outdir):
            os.makedirs(outdir)
        outfilename = os.path.join(outdir, "chr%s_%s_%s_%s.png" % (call["chromosome"], call["start"], call["stop"], call["familyID"]))
        
        if not os.path.exists(outfilename):
            sib_ID = "%s.%s" % (call["familyID"], "s1")
            if sib_ID in plotters["sib"].samples:
                fig, axes = plt.subplots(figsize=(10,14), nrows=4)
            else:
                fig, axes = plt.subplots(figsize=(10,14), nrows=3)
            # plot the proband
            call["sampleID"] = "%s.p1" % call["familyID"] 
            if call["sampleID"] in plotters["pro"].samples:
                show_call_line = rel=="p1"
                _ = plotters["pro"].basicPlot(call, outdir=outdir,ax=axes[0], show_call_line=show_call_line)


            for sib_code in ["s1", "s2", "s3"]:
                sib_ID = "%s.%s" % (call["familyID"], sib_code)
                if sib_ID in plotters["sib"].samples:
                    call["sampleID"] = sib_ID
                    show_call_line = rel in ["s1", "s2", "s3"]
                    _ = plotters["sib"].basicPlot(call, outdir=outdir,ax=axes[1], show_call_line=show_call_line)

            # See if we have data for the mother
            call["sampleID"] = "%s.mo" % call["familyID"] 
            if call["sampleID"] in plotters["mo"].samples:
                _ = plotters["mo"].basicPlot(call, outdir=outdir,ax=axes[-2], show_call_line=False)
            
            call["sampleID"] = "%s.fa" % call["familyID"] 
            if call["sampleID"] in plotters["fa"].samples:
                _ = plotters["fa"].basicPlot(call, outdir=outdir,ax=axes[-1], show_call_line=False)


            plt.savefig(outfilename)
            plt.close(fig)
            plt.clf()
            del fig
            del axes
