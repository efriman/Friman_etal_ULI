#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

cooldir=/exports/igmm/eddie/wendy-lab/ilia/interactions_screen_human_quaich/inputs/coolers;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38;
expected=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files/GM12878.hg38.expected.5000.tsv;
dir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/scripts;

coolpups=( zero
GM12878.hg38.1000
)

peaks=( zero
GM12878_H3K27ac_MYC_plus_noMYC_minus_hg38.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};

$dir/./flipstrand_bydistance.py $cooldir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak $outputdir/$coolpup'_'$peak'_flipstrand_expected_cisbalanced.clpy' \
--nproc 4 --expected $expected --clr_weight_name "cis_weight"
