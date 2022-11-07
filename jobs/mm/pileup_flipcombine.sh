#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-2

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

cooldir=/exports/igmm/eddie/wendy-lab/ilia/interactions_screen_quaich/inputs/coolers;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10;
expected=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files/expected_Hsieh_5kb_cis.tsv;
dir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/scripts;

coolpups=( zero
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
)

peaks=( zero
TSS_noRING1B_A_within_50kb_compartmentswitch_signAB_mm10.bed
TSS_Q4_noRING1B_A_atleast_100kb_from_compartmentswitch_signAB_mm10.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};

$dir/./flipstrand_combine.py $cooldir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak $outputdir/$coolpup'_'$peak'_flipstrand_expected_cisbalanced.clpy' \
--nproc 4 --expected $expected --clr_weight_name "cis_weight" --mindist 1000000 --maxdist 100000000
