#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-16

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_dev

dir=/exports/igmm/eddie/wendy-lab/elias/Processed_HiC_data_external/GSE201376_Reed2022;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38;
expecteddir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files;

coolpups=( zero
GSE201353_LIMA_THP1_WT_LPIF_0000_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0030_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0060_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0090_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0120_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0240_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0360_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_1440_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0000_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0030_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0060_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0090_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0120_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0240_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_0360_S_0.0.0_megaMap_inter_res5000
GSE201353_LIMA_THP1_WT_LPIF_1440_S_0.0.0_megaMap_inter_res5000
)

peaks=( zero
THP1_H3K27ac_down.bed
THP1_H3K27ac_down.bed
THP1_H3K27ac_down.bed
THP1_H3K27ac_down.bed
THP1_H3K27ac_down.bed
THP1_H3K27ac_down.bed
THP1_H3K27ac_down.bed
THP1_H3K27ac_down.bed
THP1_H3K27ac_up.bed
THP1_H3K27ac_up.bed
THP1_H3K27ac_up.bed
THP1_H3K27ac_up.bed
THP1_H3K27ac_up.bed
THP1_H3K27ac_up.bed
THP1_H3K27ac_up.bed
THP1_H3K27ac_up.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};
expected=$expecteddir/$coolpup'_expected_5kb_cis.tsv'

coolpup.py $dir/$coolpup'.cool' $peakdir/$peak \
--expected $expected --mindist 100000 --maxdist 100000000 --by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --n_proc 4 \
--clr_weight_name "cis_weight"
