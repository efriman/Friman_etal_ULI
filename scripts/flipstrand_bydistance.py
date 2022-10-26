#!/usr/bin/env python3
from coolpuppy.coolpup import CoordCreator, PileUpper, bin_distance_intervals
from coolpuppy.lib.io import save_pileup_df
import cooler
from cooltools.lib import common, io
import bioframe
import os
import os.path as op
import logging
import argparse
import numpy as np
from collections.abc import Iterable

logging.basicConfig(format="%(message)s", level='INFO')

def flip_strand_annotation(intervals):
    intervals["orientation"] = intervals["strand1"] + intervals["strand2"]
    intervals["orientation"] = np.where(intervals["orientation"] == "-+", "+-", intervals["orientation"])
    return intervals

def flip_func(intervals):
    intervals = bin_distance_intervals(intervals,
                                       band_edges=[100_000,
                                                   1_000_000,
                                                   10_000_000,
                                                   25_000_000,
                                                   100_000_000])
    intervals = flip_strand_annotation(intervals)
    return intervals

def validate_csv(value, default_column="balanced.avg"):
    if value is None:
        return
    file_path, _, field_name = value.partition("::")
    if not op.exists(file_path):
        raise ValueError(f"Path not found: {file_path}")
    if not field_name:
        field_name = default_column
    elif field_name.isdigit():
        field_name = int(field_name)
    return file_path, field_name

def parse_args_flipannotation():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("cool_path", type=str)
    parser.add_argument("features",type=str)
    parser.add_argument("outname", type=str)
    
    parser.add_argument(
        "--expected",
        default=None,
        type=validate_csv,
        required=False,)
    
    parser.add_argument(
        "--nshifts",
        default=5,
        type=int,
        required=False,) 
    
    parser.add_argument(
        "--subset",
        default=0,
        type=int,
        required=False,)

    parser.add_argument(
        "--nproc",
        default=1,
        type=int,
        required=False,)
    parser.add_argument(
        "--clr_weight_name",
        default="weight",
        type=str,
        required=False,
        nargs="?",
        const=None,
    )
    return parser

def main():
    parser = parse_args_flipannotation()
    args = parser.parse_args()

    logging.info(args)

    clr = cooler.Cooler(args.cool_path)

    coolname = os.path.splitext(os.path.basename(clr.filename))[0]
    
    if args.features != "-":
        bedname, ext = os.path.splitext(os.path.basename(args.features))
        features = args.features
        features = bioframe.read_table(
            features, schema="bed12", index_col=False, dtype={"chrom": str}
        )
    else:
        features = bioframe.read_table(sys.stdin, schema="bed12", index_col=False)
    
    if args.expected is None:
        expected = False
        expected_value_col = None
    else:
        expected_path, expected_value_col = args.expected
        expected_value_cols = [
            expected_value_col,
        ]
        expected = io.read_expected_from_file(
                expected_path,
                contact_type="cis",
                expected_value_cols=expected_value_cols,
                verify_cooler=clr,
            )
    outname = args.outname
    if args.nproc == 0:
        nproc = -1
    else:
        nproc = args.nproc
    
    cc = CoordCreator(features, resolution=int(clr.binsize), flank=100_000, 
                      mindist=100_000, maxdist=100_000_000, subset=args.subset,
                      nshifts=args.nshifts,)
    pu = PileUpper(clr, cc, control=True, expected=expected, 
                   flip_negative_strand=True, clr_weight_name=args.clr_weight_name)
    pup = pu.pileupsWithControl(modify_2Dintervals_func=flip_func, 
                                groupby=["orientation", "distance_band"], 
                                nproc=nproc)
    
    pup = pup.reset_index()
    
    pup = pup.loc[pup["orientation"] != "all",:]
    
    pup["separation"] = pup["distance_band"].apply(
            lambda x: f"{x[0]/1000000}Mb-\n{x[1]/1000000}Mb"
            if len(x) == 2
            else f"{x[0]/1000000}Mb+"
        )
    
    headerdict = vars(args)
    headerdict["resolution"] = int(clr.binsize)
    if "expected" in headerdict:
        if not isinstance(headerdict["expected"], str) and isinstance(
            headerdict["expected"], Iterable
        ):
            headerdict["expected_file"] = headerdict["expected"][0]
            headerdict["expected_col"] = headerdict["expected"][1]
            headerdict["expected"] = True
    save_pileup_df(outname, pup, headerdict)
    logging.info(f"Saved output to {outname}")

if __name__ == '__main__':
    main()