#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-2

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_dev

dir=/exports/igmm/eddie/wendy-lab/elias/Processed_HiC_data_external/GSE131463_Hu;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm9;
expecteddir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files;


coolpups=( zero
GSE131463_Hu2019_Ctrl_merged_5kbres_mm9
GSE131463_Hu2019_shSrrm2_merged_5kbres_mm9
)

peaks=( zero
CAP-CGI_CpG_density_quartile_4_mm9_merged5kb_noRING1B_nochr.bed
CAP-CGI_CpG_density_quartile_4_mm9_merged5kb_noRING1B_nochr.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};
expected=$expecteddir/$coolpup'_expected_5kb_cis.tsv'

coolpup.py $dir/$coolpup'.cool' $peakdir/$peak \
--expected $expected --mindist 100000 --maxdist 100000000 --by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --n_proc 4 \
--clr_weight_name "cis_weight"
