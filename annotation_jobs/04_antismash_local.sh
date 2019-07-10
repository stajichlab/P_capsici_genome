#!/bin/bash
#SBATCH --nodes 1 --ntasks 24 --mem 96G --out antismash.%A.log -J antismash

module unload perl
module unload perl
module load antismash/4.1.0
module unload python/3
source activate antismash
CPU=$SLURM_CPUS_ON_NODE

TOPDIR=funannot
antismash --taxon fungi --outputfolder antismash \
     --asf --full-hmmer --cassis --clusterblast --smcogs --subclusterblast --knownclusterblast -c $CPU \
     $TOPDIR/predict_results/*.gbk
