#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-7

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/elias/Processed_HiC_data_external/GSE126985_Loubiere;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/dm6;
expecteddir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files;

coolpups=( zero
ED.allValidPairs
ED.allValidPairs
ED.allValidPairs
ED.allValidPairs
ED.allValidPairs
ED.allValidPairs
ED.allValidPairs
)

peaks=( zero
ED_H3K27ac_noPRC1_dm6.bed
ED_PRC1_noH3K27ac_dm6.bed
ED_H3K27ac_PRC1_dm6.bed
Loubiere_RNAseq_quartile_1_dm6.bed
Loubiere_RNAseq_quartile_2_dm6.bed
Loubiere_RNAseq_quartile_3_dm6.bed
Loubiere_RNAseq_quartile_4_dm6.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};
expected=$expecteddir/$coolpup'_expected_5kb_cis.tsv'

coolpup.py $dir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak \
--expected $expected --mindist 100000 --maxdist 25000000 --by_distance 100000 1000000 10000000 25000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --n_proc 4 \
--clr_weight_name "cis_weight"
