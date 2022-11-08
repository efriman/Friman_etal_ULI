#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import bioframe
import os
import dask.dataframe as dd
import numpy as np


cres = pd.read_csv('/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38/CRE/hg38-cCREs_GM12878_DNase_merged5kb.bed', 
                   names=['chrom', 'start', 'end'], sep="\t", 
                   dtype={'chrom': str, 'start': int, "end": int},
                   usecols = [i for i in range(3)])

#Load ReMap2022 data in chunks
chunks = pd.read_csv('/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38/CRE/remap2022_all_macs2_hg38_v1_0.bed', 
                    sep="\s+|\.", header=None, engine="python", usecols = [i for i in range(6)],
                    names=["chrom", "start", "end", "ID", "Factor", "Cell_type"],
                    dtype={'chrom': str, 'start': int, "end": int,
                           "ID": str, "Factor": str, "Cell_type": str}, 
                    chunksize=10**6)
remap = pd.DataFrame()
for chunk in chunks:
    chunk = chunk[chunk["Cell_type"] == "GM12878"]
    remap = pd.concat([remap, chunk])

#Overlap with CREs
remap = bioframe.overlap(cres, remap, how='left', suffixes=['_cres', '']).fillna(0)

remap = remap.rename(columns = {"ID": "GSEID"})

remap["ID_Factor"] = remap["GSEID"].astype(str) + "_" + remap["Factor"].astype(str)

remap = remap[remap["ID_Factor"] != "0_0"]
remap = remap.dropna()

#Removing datasets that have been revoked from ENCODE
revoked = ["ENCSR679FAB_RNF2", "ENCSR744XTG_SUZ12", "ENCSR769ZTN_GTF2F1", "ENCSR785OKZ_RB1", 
           "ENCSR517QHU_BHLHE40", "ENCSR237YZZ_MAFF", "ENCSR904YPP_NR3C1", "ENCSR725LYT_ARID3A",
           "ENCSR585CVE_BACH1"]
remap = remap[~remap["ID_Factor"].isin(revoked)]

# Manually annotated blacklist to remove datasets with perturbations in cistromeDB
blacklist = [45221] #H2AZ

# human_factor files downloaded as batch from cistromeDB. mouse_factor_ES.txt generated using GEO_query_GM12878.R
factors = pd.read_csv('/exports/igmm/eddie/wendy-lab/elias/scripts/human_factor_GM12878.txt', sep='\t')

factors = factors[(factors['FastQC'] > 25) & (factors['UniquelyMappedRatio'] > 0.6) & (factors['PBC'] > 0.8) &
                  (factors['PeaksFoldChangeAbove10'] > 500) & (factors['FRiP'] > 0.01) & (factors['PeaksUnionDHSRatio'] > 0.7)]

gm = factors[(factors['Cell_line']=='GM12878') & (~factors['DCid'].isin(blacklist))]

namedict_gm = dict(zip(gm['DCid'], gm['Factor']))

gm_factortable = pd.concat([bioframe.read_table(f'/exports/igmm/eddie/wendy-lab/ilia/human_factor/human_factor/{fid}_sort_peaks.narrowPeak.bed', schema='narrowPeak').assign(id=fid, factor=factor).rename(columns={'chrom':'peak_chrom', 'start':'peak_start', 'end':'peak_end'}) for fid, factor in namedict_gm.items()])

gm_factortable = bioframe.overlap(cres, gm_factortable, how='left', suffixes=['_cres', ''], cols2=['peak_chrom', 'peak_start', 'peak_end']).fillna(0)

gm_factortable[['start_cres', 'end_cres', 'peak_start','peak_end']] = gm_factortable[['start_cres', 'end_cres', 'peak_start','peak_end']].astype(int)

gm_factortable = gm_factortable.dropna()

gm_factortable = gm_factortable[["chrom_cres", "start_cres", "end_cres", "factor", "id", 
                                 "peak_chrom", "peak_start", "peak_end"]]

gm_factortable.columns = ["chrom_cres", "start_cres", "end_cres", "Factor", "DCid",
                          "chrom", "start" , "end"]

gm_factortable["DCid"] = gm_factortable["DCid"].astype(int)

gm_factortable = pd.merge(gm_factortable, factors[["DCid", "GSEID"]], on="DCid")

gm_factortable["ID_Factor"] = gm_factortable["GSEID"].astype(str) + "_" + gm_factortable["Factor"].astype(str)

#Combine cistromeDB and ReMap2022
cistrome_remap = pd.concat([remap[["chrom_cres", "start_cres", "end_cres", "ID_Factor", "Factor"]], 
                            gm_factortable[["chrom_cres", "start_cres", "end_cres", "ID_Factor", "Factor"]]])

cistrome_remap["coords_cre"] = cistrome_remap["chrom_cres"] + "_" + cistrome_remap["start_cres"].astype(str) + "_" + cistrome_remap["end_cres"].astype(str)

cistrome_remap = cistrome_remap.drop_duplicates(subset=["coords_cre", "ID_Factor"])

cistrome_remap.to_csv("/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38/CRE/hg38-cCREs_GM12878_DNase_merged5kb_cistromeDB_ReMap2020_filtered.bed", sep="\t", index=False, header=True)