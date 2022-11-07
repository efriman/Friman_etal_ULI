#!/bin/bash

#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -t 1-14

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/ilia/interactions_screen_quaich/inputs/coolers;
outputdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/pileups;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10;
expecteddir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/expected_files;


coolpups=( zero
Boyle_KO.mm10.mapq_30.1000
Boyle_WT.mm10.mapq_30.1000
Hsieh2021_CTCF-AID
Hsieh2021_CTCF-UT
Hsieh2021_RAD21-AID
Hsieh2021_RAD21-UT
Hsieh2021_WAPL-AID
Hsieh2021_WAPL-UT
Hsieh2021_YY1-AID
Hsieh2021_YY1-UT
Hsieh_mESCs_FLV.mm10.mapq_30.1000
Hsieh_mESCs_TRP.mm10.mapq_30.1000
Rhodes_Scc1+Aux.mm10.mapq_30.1000
Rhodes_Tir1+Aux.mm10.mapq_30.1000
)

peaks=( zero
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed
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
