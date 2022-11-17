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
    intervals["orientation"] = np.where(intervals["orientation"] == "--", "++", intervals["orientation"])
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
        "--mindist",
        type=int,
        required=False,) 
    
    parser.add_argument(
        "--maxdist",
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
                      mindist=args.mindist, maxdist=args.maxdist, subset=args.subset,
                      nshifts=args.nshifts,)
    pu = PileUpper(clr, cc, control=True, expected=expected, 
                   flip_negative_strand=True, clr_weight_name=args.clr_weight_name)
    pup = pu.pileupsWithControl(modify_2Dintervals_func=flip_strand_annotation, 
                                groupby=["orientation"], 
                                nproc=nproc)
    
    pup = pup.reset_index()
    
    pup = pup.loc[pup["orientation"] != "all",:]
    
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