from conifertools import ConiferPipeline, CallTable, CallFilterTemplate
import argparse


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("conifer_file")
    parser.add_argument("call_file")
    parser.add_argument("out_file")

    args = parser.parse_args()

    calls = CallTable(args.call_file)

    p = ConiferPipeline(args.conifer_file)

    GeneAnnotation = CallFilterTemplate(p,
                 "/net/eichler/vol8/home/nkrumm/REFERENCE_INFO/hg19.refGene.bed",
                 name="RefSeq",
                 filter_type="name")


    calls = calls.annotate(GeneAnnotation)
    print_cols = ["cnvrID_SSC", "sampleID", "chromosome", "start", "stop", "state", "size_bp", 
                  "cnvr_frequency_SSC", "cohort",
                  "median_svdzrpkm", "num_probes", "RefSeq"]
    calls.save(args.out_file, cols=print_cols)


