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
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38;

computeMatrix reference-point --referencePoint center -R \
$peakdir/THP1_H3K27ac_up.bed \
$peakdir/THP1_H3K27ac_down.bed -S \
$dir/GSM6061743_LIMA_ChIP_h3k27ac_THP1_WT_LPIF_S_0000_1.1.1.bw \
$dir/GSM6061745_LIMA_ChIP_h3k27ac_THP1_WT_LPIF_S_0030_1.1.1.bw \
$dir/GSM6061747_LIMA_ChIP_h3k27ac_THP1_WT_LPIF_S_0060_1.1.1.bw \
$dir/GSM6061749_LIMA_ChIP_h3k27ac_THP1_WT_LPIF_S_0090_1.1.1.bw \
$dir/GSM6061751_LIMA_ChIP_h3k27ac_THP1_WT_LPIF_S_0120_1.1.1.bw \
$dir/GSM6061753_LIMA_ChIP_h3k27ac_THP1_WT_LPIF_S_0240_1.1.1.bw \
$dir/GSM6061755_LIMA_ChIP_h3k27ac_THP1_WT_LPIF_S_0360_1.1.1.bw \
$dir/GSM6061757_LIMA_ChIP_h3k27ac_THP1_WT_LPIF_S_1440_1.1.1.bw \
-out $dir/H3K27ac_THP1.gz -a 5000 -b 5000

plotHeatmap -m $dir/H3K27ac_THP1.gz -out $dir/H3K27ac_THP1.svg --colorMap inferno \
--whatToShow 'heatmap and colorbar' --refPointLabel '' --regionsLabel '' '' \
--samplesLabel '' '' '' '' '' '' '' '' --xAxisLabel '' --startLabel '' --endLabel '' --heatmapHeight 3 --heatmapWidth 1
