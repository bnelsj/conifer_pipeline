import numpy as np
import pandas
pandas.set_option("display.line_width",200)
from conifertools import *
import argparse




def translate_call_coordinates(in_calls, conifer_file, overwrite=True):
    """
    Translates the start_exon and stop_exon of a CallTable 
    to match that of another CoNIFER file.
    """
    if isinstance(in_calls, CallTable):
        in_calls = in_calls.calls
    
    chroms = set(in_calls.chromosome)
    out_calls = pandas.DataFrame()
    for chrom in chroms:
        chr_calls = in_calls[in_calls.chromosome == chrom].sort(["start","stop"])
        chr_probes = conifer_file.getProbesByChrom(chrom).sort(["start","stop"])
        if overwrite:
            out_field_start_exon, out_field_stop_exon = "start_exon", "stop_exon"
            out_field_start, out_field_stop = "start", "stop"
            num_probes_field, size_bp_field = "num_probes", "size_bp"
        else:
            out_field_start_exon, out_field_stop_exon = "start_exon_translated", "stop_exon_translated"
            out_field_start, out_field_stop = "start_translated", "stop_translated"
            num_probes_field, size_bp_field = "num_probes_translated", "size_bp_translated"
        
        chr_calls[out_field_start_exon] = np.searchsorted(chr_probes.stop.values,chr_calls.start.values)
        chr_calls[out_field_stop_exon] = np.searchsorted(chr_probes.start.values,chr_calls.stop.values)-1
        chr_calls[num_probes_field] = chr_calls[out_field_stop_exon]-chr_calls[out_field_start_exon] + 1
        chr_calls[out_field_start] = chr_probes.ix[chr_calls[out_field_start_exon]]["start"].values
        chr_calls[out_field_stop] = chr_probes.ix[chr_calls[out_field_stop_exon]]["stop"].values
        chr_calls[size_bp_field] = chr_calls[out_field_stop] - chr_calls[out_field_stop]
        out_calls = out_calls.append(chr_calls)
    
    return CallTable(out_calls).filter(lambda x: x[num_probes_field] != 0)



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--conifer_file", action="store", required=True)
    parser.add_argument("--call_file", action="store", required=True)
    parser.add_argument("--out_file", action="store", required=True)
    args = parser.parse_args()

    p = ConiferPipeline(args.conifer_file)
    in_calls = CallTable(args.call_file)

    out_calls = translate_call_coordinates(in_calls, p)

    out_calls.save(args.out_file)