#!/bin/bash

#$ -cwd
#$ -l h_rt=120:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/ilia/interactions_screen_quaich/inputs/coolers;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10;
expected=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files/expected_Hsieh_5kb_trans.tsv;

coolpups=( zero
Hsieh_mESCs_microC.mm10.mapq_30.1000
)

peaks=( zero
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};

coolpup.py $dir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak \
--expected $expected --trans \
--outname $outputdir/$coolpup'_'$peak'_expected_trans.clpy' --n_proc 4 \
--clr_weight_name "weight_trans"
