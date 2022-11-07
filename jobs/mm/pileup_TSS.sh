ll #!/bin/bash

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
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10;
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
ESC_4SU_refGene_exon1_quartile_1_TSS_mm10_noRING1B.bed
ESC_4SU_refGene_exon1_quartile_2_TSS_mm10_noRING1B.bed
ESC_4SU_refGene_exon1_quartile_3_TSS_mm10_noRING1B.bed
ESC_4SU_refGene_exon1_quartile_4_TSS_mm10_noRING1B.bed
ESC_4SU_refGene_exon1_quartile_3_TSS_mm10_noRING1B_CGI_shuf732.bed
ESC_4SU_refGene_exon1_quartile_3_TSS_mm10_noRING1B_noCGI_shuf732.bed
ESC_4SU_refGene_exon1_quartile_4_TSS_mm10_noRING1B_CGI_shuf732.bed
ESC_4SU_refGene_exon1_quartile_4_TSS_mm10_noRING1B_noCGI_shuf732.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};

coolpup.py $dir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak \
--expected $expected --mindist 100000 --maxdist 100000000 --by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --n_proc 4 \
--clr_weight_name "cis_weight"
