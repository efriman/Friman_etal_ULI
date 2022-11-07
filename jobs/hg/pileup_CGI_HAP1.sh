#!/bin/bash

#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-5

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/elias/Processed_HiC_data_external/GSE95014_Haarhuis;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg19;
expecteddir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files;

coolpups=( zero
GSE95014_DKO_3.3_res5000_hg19
GSE95014_Hap1_res5000_hg19
GSE95014_SCC4KO_res5000_hg19
GSE95014_WaplKO_1.14_res5000_hg19
GSE95014_WaplKO_3.3_res5000_hg19
)

peaks=( zero
CAP-CGI_CpG_density_quartile_4_hg19.bed
CAP-CGI_CpG_density_quartile_4_hg19.bed
CAP-CGI_CpG_density_quartile_4_hg19.bed
CAP-CGI_CpG_density_quartile_4_hg19.bed
CAP-CGI_CpG_density_quartile_4_hg19.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};
expected=$expecteddir/$coolpup'_expected_5kb_cis.tsv'

coolpup.py $dir/$coolpup'.cool' $peakdir/$peak --expected $expected \
--mindist 100000 --maxdist 100000000 \
--by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --nproc 4 \
--clr_weight_name "cis_weight"
