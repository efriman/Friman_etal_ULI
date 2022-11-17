#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-3

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/elias/Processed_HiC_data_external/Nagano2017;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm9;
expecteddir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files;


coolpups=( zero
G1_cells.1000.cool_mm9
early-S_cells.1000.cool_mm9
late-S-G2_cells.1000.cool_mm9
)

peaks=( zero
CAP-CGI_CpG_density_quartile_4_mm9_merged5kb.bed
CAP-CGI_CpG_density_quartile_4_mm9_merged5kb.bed
CAP-CGI_CpG_density_quartile_4_mm9_merged5kb.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};
expected=$expecteddir/$coolpup'_expected_5kb_cis.tsv'

coolpup.py $dir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak \
--expected $expected --mindist 100000 --maxdist 100000000 --by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --n_proc 4 \
--clr_weight_name "cis_weight"