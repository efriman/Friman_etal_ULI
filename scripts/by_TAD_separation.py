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
import pandas as pd

logging.basicConfig(format="%(message)s", level='INFO')

def TAD_distance(intervals):
    intervals["TAD_distance"] = np.abs(intervals["TAD_1"] - intervals["TAD_2"])
    intervals["TAD"] = np.where(intervals["TAD_distance"]==0, 
                                "0", 
                                np.where(intervals["TAD_distance"]==1, 
                                         "1", 
                                         ">1"))
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

def parse_args_byTAD():
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
        required=True,) 
    
    parser.add_argument(
        "--maxdist",
        type=int,
        required=True,) 
    
    parser.add_argument(
        "--subset",
        default=0,
        type=int,
        required=False,)
    
    parser.add_argument(
        "--seed",
        default=None,
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
    parser.add_argument(
        "--TAD_file",
        type=str,
        required=True,
    )
    return parser

def main():
    parser = parse_args_byTAD()
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
        
    if args.seed is not None:
        np.random.seed(args.seed)    
        
    TADs = pd.read_table(args.TAD_file, sep="\t")    
    features_TADoverlap = bioframe.overlap(features, TADs).dropna(subset=["chrom", "TAD_"])
    features_TADoverlap["TAD_"] = features_TADoverlap["TAD_"].astype(int)
    #features_TADoverlap = features_TADoverlap[["chrom", "start", "end", "TAD_"]]
    
    outname = args.outname
    
    if args.nproc == 0:
        nproc = -1
    else:
        nproc = args.nproc
    
    cc = CoordCreator(features_TADoverlap, resolution=int(clr.binsize), flank=100_000, 
                      mindist=args.mindist, maxdist=args.maxdist, subset=args.subset,
                      nshifts=args.nshifts, seed=args.seed)
    pu = PileUpper(clr, cc, control=True, expected=expected, 
                   clr_weight_name=args.clr_weight_name)
    pup = pu.pileupsWithControl(modify_2Dintervals_func=TAD_distance, 
                                groupby=["TAD"], 
                                nproc=nproc)
    
    pup = pup.reset_index()
    
    pup = pup.loc[pup["TAD"] != "all",:]
    
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