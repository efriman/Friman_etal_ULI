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

dir=/exports/igmm/eddie/wendy-lab/ilia/interactions_screen_human_quaich/inputs/coolers;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38/CRE;
expected=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files/GM12878.hg38.expected.10000.tsv;

cd $dir

coolpups=( zero
GM12878.hg38.1000
)

peaks=( zero
hg38-cCREs_GM12878_DNase_merged5kb.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};

coolpup.py $dir/$coolpup'.mcool::/resolutions/10000' $peakdir/$peak --store_stripes --flank 0 \
--expected $expected --mindist 100000 --maxdist 10000000 --by_distance 100000 1000000 10000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_noflank_10kbres_100kbto10Mb_stripe.clpy' --n_proc 4
