#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem 24G
#SBATCH --time=3-00:15:00   
#SBATCH --output=annot_02.%A.log
#SBATCH --job-name="Funnannotate"
module unload miniconda2
module load funannotate/1.8.1

export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
which augustus
CPUS=$SLURM_CPUS_ON_NODE

if [ ! $CPUS ]; then
 CPUS=2
fi

if [ ! -f config.txt ]; then
 echo "need a config file for parameters"
 exit
fi

which python
which augustus
source config.txt
if [ ! $MASKED ]; then 
 echo "NEED TO EDIT CONFIG FILE TO SPECIFY THE INPUT GENOME AS VARIABLE: MASKED=GENOMEFILEFFASTA"
 exit
fi

if [ ! "$EXTRA" ]; then
 EXTRA="--ploidy 1"
fi
if [ ! $ODIR ]; then
 ODIR=$(basename `pwd`)."funannot"
fi

# condition genemark?
funannotate predict -i $MASKED -s "$SPECIES" -o $ODIR --isolate "$ISOLATE"  --name $PREFIX --busco_db $BUSCO $AUGUSTUSOPTS \
 --transcript_evidence $TRANSCRIPTS --cpus $CPUS $EXTRA
