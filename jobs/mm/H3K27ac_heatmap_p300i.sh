#!/bin/bash

#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=16G
#$ -m ae
#$ -pe sharedmem 8

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate deeptools

dir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/heatmaps;
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10;

computeMatrix reference-point --referencePoint center -R \
$peakdir/CAP-CGI_CpG_density_quartile_4_mm10_merged5kb_noRING1B.bed -S \
$dir/GSM5007850_asynda.bw \
$dir/GSM5007852_asynpa.bw \
-out $dir/H3K27ac_CpGQ4_p300i.gz -a 5000 -b 5000

plotProfile -m $dir/H3K27ac_CpGQ4_p300i.gz -out $dir/H3K27ac_CpGQ4_p300i.svg \
--perGroup --refPointLabel '' --regionsLabel '' --samplesLabel '' '' --startLabel '' \
--endLabel '' --plotHeight 3 --plotWidth 3.5 --colors '#e41a1c' '#377eb8'
