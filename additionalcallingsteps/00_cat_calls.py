from conifertools import ConiferPipeline, CallTable
import argparse
import numpy as np


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("input_call_files", nargs="+")
    parser.add_argument("--outfile", "-o", action="store", required=True)
    args = parser.parse_args()
    calls = CallTable()
    for filename in args.input_call_files:
        calls.appendCalls(CallTable(filename))

    calls.save(args.outfile)
