#!/bin/bash
#SBATCH -p batch --time 2-0:00:00 --ntasks 8 --nodes 1 --mem 24G --out logs/mask.%A.log

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

if [ -f config.txt ]; then
	source config.txt
else
	echo "need config.txt"
	exit
fi
LIBRARY=Pcap_v1.repeatmodeler.lib.fa
if [ ! -f $MASKED ]; then

    module load funannotate/1.8.1
    module unload rmblastn
    module load ncbi-rmblast/2.9.0-p2
    export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config

    LIBRARY=$(realpath $LIBRARY)
    funannotate mask --cpus $CPU -i $SORTED -o $MASKED -l $LIBRARY
else 
    echo "Skipping ${name} as masked already"
fi
