#!/bin/bash
#SBATCH --nodes 1 --ntasks 24 --mem 128G -p intel --out train.%A.log -J trainFun

MEM=128G
module unload miniconda2
module load miniconda3
module load funannotate/1.8.1
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
export PASAHOME=`dirname $(which Launch_PASA_pipeline.pl)`
export PASACONF=$HOME/pasa.CONFIG.template

CPUS=$SLURM_CPUS_ON_NODE

if [ ! $CPUS ]; then
    CPUS=2
fi

if [ ! -f config.txt ]; then
    echo "need a config file for parameters"
    exit
fi

source config.txt
if [ ! $SORTED ]; then
    echo "NEED TO EDIT CONFIG FILE TO SPECIFY THE INPUT GENOME AS VARIABLE: SORTED=GENOMEFILEFFASTA"
    exit
fi

if [ ! $ODIR ]; then
     ODIR=$(basename `pwd`)."funannot"
fi

funannotate train -i $SORTED --species "$SPECIES" --isolate $ISOLATE --cpus $CPUS \
    -o funannot --max_intronlen 4000 --stranded no \
    --single rnaseq/single_AC-7-4-28.fastq  --pasa_db mysql --memory $MEM
