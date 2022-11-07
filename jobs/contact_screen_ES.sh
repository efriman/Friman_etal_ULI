#!/bin/bash

#$ -cwd
#$ -l h_rt=96:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-9

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

inputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
scriptdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/scripts;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10/CRE;
dir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/contact_screen;

coolpups=( zero
Hsieh_mESCs_microC.mm10.mapq_30.1000_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
Hsieh2021_CTCF-AID_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
Hsieh2021_CTCF-UT_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
Hsieh2021_RAD21-AID_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
Hsieh2021_RAD21-UT_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
Hsieh2021_WAPL-AID_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
Hsieh2021_WAPL-UT_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
Boyle_WT.mm10.mapq_30.1000_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
Boyle_KO.mm10.mapq_30.1000_mm10-cCREs_ESC_DNase_merged5kb_mm10.bed_expected_noflank_10kbres_100kbto10Mb_stripe.clpy
)

peaksets=( zero
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed 
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed
mm10-cCREs_ESC_DNase_merged5kb_mm10_cistromeDB_ReMap2020_filtered.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peakset=${peaksets[${SGE_TASK_ID}]};

$scriptdir/./contact_screen.py $inputdir/$coolpup $peakdir/$peakset $dir/$coolpup'_'$peakset'_shortrange.txt' $dir/$coolpup'_'$peakset'_longrange.txt'
