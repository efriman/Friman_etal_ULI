#!/bin/bash

#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-3

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
GSE95014_Hap1_res5000_hg19
GSE95014_Hap1_res5000_hg19
GSE95014_Hap1_res5000_hg19
)

peaks=( zero
GPseq_third_1_hg19_CAP-CGI_noH3K27me3_HAP1.bed
GPseq_third_2_hg19_CAP-CGI_noH3K27me3_HAP1.bed
GPseq_third_3_hg19_CAP-CGI_noH3K27me3_HAP1.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};
expected=$expecteddir/$coolpup'_expected_5kb_cis.tsv'

coolpup.py $dir/$coolpup'.cool' $peakdir/$peak --expected $expected \
--mindist 100000 --maxdist 100000000 \
--by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_cisbalanced_expected.clpy' --nproc 4 \
--clr_weight_name "cis_weight"
