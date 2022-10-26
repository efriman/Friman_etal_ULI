#!/usr/bin/env python3
from scipy import stats
from coolpuppy.lib import io
import bioframe
import logging
import argparse
import numpy as np
import pandas as pd
import warnings

logging.basicConfig(format="%(message)s", level='INFO')

def process_pup(pup):
    pup = pup[pup["separation"] != "all"]
    contact_freq = pd.DataFrame({"chrom": [item[0] for sublist in pup["coordinates"] for item in sublist],
                                 "start1": [int(item[1]) for sublist in pup["coordinates"] for item in sublist],
                                 "end1": [int(item[2]) for sublist in pup["coordinates"] for item in sublist],
                                 "start2": [int(item[4]) for sublist in pup["coordinates"] for item in sublist],
                                 "end2": [int(item[5]) for sublist in pup["coordinates"] for item in sublist],
                                 "distance_band": ''.join([str(item)*pup.loc[pup["distance_band"] == item, "vertical_stripe"].reset_index(drop=True)[0].shape[0] for item in pup["distance_band"]]).split(")("),                    
                                 "contact": [item[0] for sublist in pup["vertical_stripe"] for item in sublist]})
    contact_freq["distance_band"] = contact_freq["distance_band"].str.replace('(','', regex=False)
    contact_freq["distance_band"] = contact_freq["distance_band"].str.replace(')','', regex=False)
    contact_freq["coord1"] = contact_freq["chrom"] + "_" + contact_freq["start1"].astype(str) + "_" + contact_freq["end1"].astype(str)
    contact_freq["coord2"] = contact_freq["chrom"] + "_" + contact_freq["start2"].astype(str) + "_" + contact_freq["end2"].astype(str)
    contact_freq = contact_freq.dropna()
    return contact_freq

def contact_screen(contact_df, peakset):
    store_data = {"ID_Factor": [], "p_value": [], "F_value": []}
    coord1 = set(contact_df["coord1"].unique())
    coord2 = set(contact_df["coord2"].unique())
    ids = peakset["ID_Factor"].unique()
    ids = ids[(ids != "0_0")] 
    i = 1
    counter = 0
    for id in ids:
        percent = (i / len(ids))*100
        i += 1
        if (percent>counter) & (np.floor(percent)%10 == 0):
            logging.info(str(np.floor(percent))+"% finished")
            counter += 10
        regions = set(peakset.loc[peakset["ID_Factor"] == id, "coords_cre"])
        if len(regions) < 500:
            continue
        left = coord1.intersection(regions)
        right = coord2.intersection(regions)
        none = contact_df.loc[~(contact_df["coord1"].isin(left)) & 
                              ~(contact_df["coord2"].isin(right)), "contact"]
        both = contact_df.loc[(contact_df["coord1"].isin(left)) & 
                              (contact_df["coord2"].isin(right)), "contact"]
        if (len(both)>50) & (len(none)>50):
            MannWhitney = stats.mannwhitneyu(y = none, x = both)
            store_data['ID_Factor'].append(id)
            store_data['p_value'].append(MannWhitney[1])
            store_data['F_value'].append(MannWhitney[0] / (len(none) * len(both)))
    logging.info("100.0% finished")
    store_data = pd.DataFrame(store_data)
    return store_data

def parse_args_contact_screen():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("coolpup", type=str)
    parser.add_argument("features",type=str)
    parser.add_argument("outname_short",type=str)
    parser.add_argument("outname_long",type=str)

    return parser

def main():
    parser = parse_args_contact_screen()
    args = parser.parse_args()

    logging.info(args)
    
    pup_data = io.load_pileup_df(args.coolpup)
    
    contact_freq = process_pup(pup_data)
        
    peakset = pd.read_csv(args.features, sep="\t", dtype={"chrom_cres": str, 
                                                          "start_cres": int, 
                                                          "end_cres": int, 
                                                          "ID": str})
    
    logging.info("Performing short-range analysis")
    shortrange = contact_screen(contact_freq.loc[contact_freq["distance_band"] == "100000, 1000000"], peakset)
    shortrange.to_csv(args.outname_short, sep="\t", index=False, header=True)
    logging.info(f"Saved as {args.outname_short}")
    
    logging.info("Performing long-range analysis")
    longrange = contact_screen(contact_freq.loc[contact_freq["distance_band"] == "1000000, 10000000"], peakset)
    longrange.to_csv(args.outname_long, sep="\t", index=False, header=True)
    logging.info(f"Saved as {args.outname_long}")

if __name__ == '__main__':
    main()