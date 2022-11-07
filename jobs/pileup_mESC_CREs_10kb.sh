#!/bin/bash

#$ -cwd
#$ -l h_rt=120:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-9

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/ilia/interactions_screen_quaich/inputs/coolers;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10/CRE;
expected=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files/expected_Hsieh_10kb.tsv;

cd $dir

coolpups=( zero
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh2021_CTCF-AID
Hsieh2021_CTCF-UT
Hsieh2021_RAD21-AID
Hsieh2021_RAD21-UT
Hsieh2021_WAPL-AID
Hsieh2021_WAPL-UT
Boyle_WT.mm10.mapq_30.1000
Boyle_KO.mm10.mapq_30.1000
)

peaks=( zero
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};

coolpup.py $dir/$coolpup'.mcool::/resolutions/10000' $peakdir/$peak --store_stripes --flank 0 \
--expected $expected --mindist 100000 --maxdist 10000000 --by_distance 100000 1000000 10000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_noflank_10kbres_100kbto10Mb_stripe.clpy' --n_proc 4
