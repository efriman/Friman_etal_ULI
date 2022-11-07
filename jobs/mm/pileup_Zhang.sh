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

dir=/exports/igmm/eddie/wendy-lab/elias/Zhang2019_HiC/results/coolers_library_group;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10;
expecteddir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files;

coolpups=( zero
Hi-C-prometa.mm10.mapq_30.1000
Hi-C-ana.telo.mm10.mapq_30.1000
Hi-C-early-G1.mm10.mapq_30.1000
Hi-C-late-G1.mm10.mapq_30.1000
Hi-C-mid-G1.mm10.mapq_30.1000
)

peaks=( zero
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
)

coolpup=${coolpups[${SGE_TASK_ID}]};
peak=${peaks[${SGE_TASK_ID}]};
expected=$expecteddir/$coolpup'_expected_5kb_cis.tsv'

coolpup.py $dir/$coolpup'.mcool::/resolutions/5000' $peakdir/$peak \
--expected $expected --mindist 100000 --maxdist 100000000 --by_distance 100000 1000000 10000000 25000000 100000000 \
--outname $outputdir/$coolpup'_'$peak'_expected_cisbalanced.clpy' --n_proc 4 \
--clr_weight_name "cis_weight"
