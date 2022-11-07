#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-8

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/ilia/interactions_screen_quaich/inputs/coolers;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10/CRE;
expected=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files/expected_Hsieh_5kb_cis.tsv;

cd $dir

coolpups=( zero
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
)

peaks=( zero
ENCFF048WDN_DNase_quartile_1_mm10_1kbwithinTSS_shuf2705.bed
ENCFF048WDN_DNase_quartile_1_mm10_5kbfromTSS_shuf2705.bed
ENCFF048WDN_DNase_quartile_2_mm10_1kbwithinTSS_shuf2705.bed
ENCFF048WDN_DNase_quartile_2_mm10_5kbfromTSS_shuf2705.bed
ENCFF048WDN_DNase_quartile_3_mm10_1kbwithinTSS_shuf2705.bed
ENCFF048WDN_DNase_quartile_3_mm10_5kbfromTSS_shuf2705.bed
ENCFF048WDN_DNase_quartile_4_mm10_1kbwithinTSS_shuf2705.bed
ENCFF048WDN_DNase_quartile_4_mm10_5kbfromTSS_shuf2705.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};

coolpup.py $dir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak \
--expected $expected --mindist 100000 --maxdist 100000000 --by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --n_proc 4 \
--clr_weight_name "cis_weight"
