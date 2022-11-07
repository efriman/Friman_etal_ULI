#!/bin/bash

#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=16G

set -e

# Setup the environment modules command 
source /etc/profile.d/modules.sh

# Load modules if required
module load anaconda
source activate coolpuppy_trans

dir=/exports/igmm/eddie/wendy-lab/elias/Friman2022/Peaks/mm10/CRE;

cd $dir

papermill $dir/combine_remap_cistromeDB_CRE_ES_input.ipynb $dir/combine_remap_cistromeDB_CRE_ES.ipynb
