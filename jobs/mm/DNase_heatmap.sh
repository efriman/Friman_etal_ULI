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
peakdir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10/CRE;

computeMatrix reference-point --referencePoint center -R \
$peakdir/ENCFF048WDN_DNase_quartile_1_mm10_1kbwithinTSS_shuf2705.bed \
$peakdir/ENCFF048WDN_DNase_quartile_1_mm10_5kbfromTSS_shuf2705.bed \
$peakdir/ENCFF048WDN_DNase_quartile_2_mm10_1kbwithinTSS_shuf2705.bed \
$peakdir/ENCFF048WDN_DNase_quartile_2_mm10_5kbfromTSS_shuf2705.bed \
$peakdir/ENCFF048WDN_DNase_quartile_3_mm10_1kbwithinTSS_shuf2705.bed \
$peakdir/ENCFF048WDN_DNase_quartile_3_mm10_5kbfromTSS_shuf2705.bed \
$peakdir/ENCFF048WDN_DNase_quartile_4_mm10_1kbwithinTSS_shuf2705.bed \
$peakdir/ENCFF048WDN_DNase_quartile_4_mm10_5kbfromTSS_shuf2705.bed \
-S $dir/ENCFF672DJH.bigWig \
-out $dir/ENCODE_DNase_quartiles_TSS.gz -a 5000 -b 5000

plotHeatmap -m $dir/ENCODE_DNase_quartiles_TSS.gz -out $dir/ENCODE_DNase_quartiles_TSS.svg --colorMap inferno \
--whatToShow 'heatmap and colorbar' --refPointLabel '' --regionsLabel '' '' '' '' '' '' '' '' \
--samplesLabel '' --xAxisLabel '' --startLabel '' --endLabel '' --heatmapHeight 11 --heatmapWidth 2
