#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-4

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/elias/Processed_HiC_data_external/GSE134055_Yang;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/zv10;
expecteddir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files;

coolpups=( zero
GSM4662081_YueLab-HiC-Brain_merged_zv10
GSM4662081_YueLab-HiC-Brain_merged_zv10 
GSM4662083_YueLab-HiC-Muscle_merged_zv10
GSM4662083_YueLab-HiC-Muscle_merged_zv10
)

peaks=( zero
GSE134055_Yang_H3K27ac_muscle_enriched.bed
GSE134055_Yang_H3K27ac_brain_enriched.bed
GSE134055_Yang_H3K27ac_muscle_enriched.bed
GSE134055_Yang_H3K27ac_brain_enriched.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};
expected=$expecteddir/$coolpup'_expected_5kb_cis.tsv'

coolpup.py $dir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak \
--expected $expected --mindist 100000 --maxdist 100000000 --by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --n_proc 4 \
--clr_weight_name "cis_weight"
