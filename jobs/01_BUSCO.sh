#!/bin/bash
#SBATCH --nodes 1 --ntasks 16 --mem 16G --time 36:00:00 --out logs/busco.log -J busco

module load busco

# for augustus training
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config

CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}
if [ ! $CPU ]; then
     CPU=2
fi

LINEAGE=/srv/projects/db/BUSCO/v9/protists_ensembl
OUTFOLDER=BUSCO
TEMP=/scratch/${SLURM_ARRAY_JOB_ID}_${N}
mkdir -p $TEMP
GENOMEFILE=Phytophthora_capsici_v3.fasta
NAME=$(basename $GENOMEFILE .fasta)
SEED_SPECIES=phytophthora_capsici_lt1534
LINEAGE=$(realpath $LINEAGE)

if [ -d "$OUTFOLDER/run_${NAME}" ];  then
    echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
    exit
else
    pushd $OUTFOLDER
    busco.py -i $GENOMEFILE -l $LINEAGE -o $NAME -m geno --cpu $CPU --tmp $TEMP --long -sp $SEED_SPECIES
    popd
fi

rm -rf $TEMP
