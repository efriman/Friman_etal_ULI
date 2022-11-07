#!/bin/bash

#$ -cwd
#$ -l h_rt=96:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

inputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
scriptdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/scripts;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38/CRE;
dir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/contact_screen;

coolpups=( zero
GM12878.hg38.1000_hg38-cCREs_GM12878_DNase_merged5kb.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
)

peaksets=( zero
hg38-cCREs_GM12878_DNase_merged5kb_cistromeDB_ReMap2020_filtered.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peakset=${peaksets[${SGE_TASK_ID}]};

$scriptdir/./contact_screen.py $inputdir/$coolpup $peakdir/$peakset $dir/$coolpup'_'$peakset'_shortrange.txt' $dir/$coolpup'_'$peakset'_longrange.txt'
