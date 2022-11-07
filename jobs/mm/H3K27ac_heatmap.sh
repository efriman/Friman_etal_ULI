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
$peakdir/H3K27ac_DE_ESC_higher_mm10.bed \
$peakdir/H3K27ac_DE_NPC_higher_mm10.bed \
-S $dir/ENCFF583WVZ_ESC_H3K27ac.bigWig \
$dir/GSE96107_NPC_H3K27ac.bw \
-out $dir/H3K27ac_ESC_NPC.gz -a 5000 -b 5000

plotHeatmap -m $dir/H3K27ac_ESC_NPC.gz -out $dir/H3K27ac_ESC_NPC.svg --colorMap inferno \
--whatToShow 'heatmap and colorbar' --refPointLabel '' --regionsLabel '' '' \
--samplesLabel '' '' --xAxisLabel '' --startLabel '' --endLabel '' --heatmapHeight 9 --heatmapWidth 2 \
--zMax 12 2 --zMin 0 0 
