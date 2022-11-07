#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-5

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
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
Hsieh_mESCs_microC.mm10.mapq_30.1000
)

peaks=( zero
ESC_4SU_refGene_exon1_quartile_1_TSS_mm10_noRING1B_minus_quartile_4_plus.bed
ESC_4SU_refGene_exon1_quartile_2_TSS_mm10_noRING1B_minus_quartile_4_plus.bed
ESC_4SU_refGene_exon1_quartile_3_TSS_mm10_noRING1B_minus_quartile_4_plus.bed
ENCFF519QMV_H3K27ac_no_CGI_TSS_RING1B_quartile_4_minus_ESC_4SU_refGene_exon1_quartile_4_TSS_mm10_noRING1B_plus.bed
ENCFF519QMV_H3K27ac_no_CGI_TSS_RING1B_quartile_4_minus_CAP-CGI_CpG_density_quartile_4_merged5kb_noRING1B_plus_mm10.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};

$dir/./flipstrand_bydistance.py $cooldir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak $outputdir/$coolpup'_'$peak'_flipstrand_expected_cisbalanced.clpy' \
--nproc 4 --expected $expected --clr_weight_name "cis_weight"
