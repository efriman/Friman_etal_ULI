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
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/zv10;

computeMatrix reference-point --referencePoint center -R \
$peakdir/GSE134055_Yang_H3K27ac_brain_enriched.bed \
$peakdir/GSE134055_Yang_H3K27ac_muscle_enriched.bed -S \
$dir/brain.h3k27ac.merge.nodup.tagAlign_x_brain.input.merge.nodup.modify.tagAlign.fc.signal.bw \
$dir/muscle.h3k27ac.merge.nodup.tagAlign_x_muscle.input.merge.nodup.modify.tagAlign.fc.signal.bw \
-out $dir/H3K27ac_Zebrafish.gz -a 5000 -b 5000

computeMatrix reference-point --referencePoint center -R \
$peakdir/GSE134055_Yang_H3K27ac_brain_enriched.bed \
$peakdir/GSE134055_Yang_H3K27ac_muscle_enriched.bed -S \
$dir/GSM4662071_YueLab-WGBS-brain.CG.bw \
$dir/GSM4662077_YueLab-WGBS-muscle.CG.bw \
-out $dir/WGBS_Zebrafish.gz -a 5000 -b 5000

plotHeatmap -m $dir/H3K27ac_Zebrafish.gz -out $dir/H3K27ac_Zebrafish.svg --colorMap inferno \
--whatToShow 'heatmap and colorbar' --refPointLabel '' --regionsLabel '' '' \
--samplesLabel '' '' --xAxisLabel '' --startLabel '' --endLabel '' \
--heatmapHeight 3 --heatmapWidth 2 --zMax 10 6 --zMin 0 0

plotProfile -m $dir/WGBS_Zebrafish.gz -out $dir/WGBS_Zebrafish.svg \
--perGroup --numPlotsPerRow 1 --refPointLabel '' --regionsLabel '' '' \
--samplesLabel '' '' --startLabel '' --endLabel '' --plotHeight 3 \
--plotWidth 3.5 --yMin 0.2 0.2 --yMax 0.9 0.9 --colors '#e41a1c' '#377eb8' 
