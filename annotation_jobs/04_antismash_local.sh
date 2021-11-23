#!/bin/bash
#SBATCH --nodes 1 --ntasks 24 --mem 96G --out antismash.%A.log -J antismash

module unload miniconda2
module unload miniconda3
module load anaconda3
module load antismash/5
which conda
which python
source activate antismash5
which python
which antismash
hostname
CPU=$SLURM_CPUS_ON_NODE

OUTDIR=funannot
INPUTFOLDER=update_results
antismash --taxon fungi --output-dir $OUTDIR/antismash_local \
	 --genefinding-tool none --fullhmmer --clusterhmmer --cb-general --cf-create-clusters --cb-subclusters --cb-knownclusters \
		 --pfam2go -c $CPU --skip-zip-file $OUTDIR/$INPUTFOLDER/*.gbk
