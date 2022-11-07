#!/bin/bash

#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=64G

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/hg38/CRE;

cd $dir

$dir/./combine_remap_cistromeDB_CRE_GM12878.py
