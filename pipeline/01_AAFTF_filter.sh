#!/bin/bash
#SBATCH --nodes 1 --ntasks 16 --mem 64gb -p stajichlab -J PcapAFTF1 --out logs/AAFTF_filter.log --time 12:00:00

hostname
MEM=64
CPU=$SLURM_CPUS_ON_NODE

module load AAFTF/git-live

if [ -z $CPU ]; then
    CPU=1
fi

BASE=AV1
WORKDIR=working_AAFTF
OUTDIR=illumina
LEFTTRIM=$WORKDIR/${BASE}_1P.fastq.gz
RIGHTTRIM=$WORKDIR/${BASE}_2P.fastq.gz
LEFT=$WORKDIR/${BASE}_filtered_1.fastq.gz
RIGHT=$WORKDIR/${BASE}_filtered_2.fastq.gz

mkdir -p $WORKDIR

if [ ! -f $LEFT ]; then
    echo "$OUTDIR/${BASE}_1.fq.gz $OUTDIR/${BASE}_2.fq.gz"
    if [ ! -f $LEFTTRIM ]; then
	AAFTF trim --method bbduk --memory $MEM --left $OUTDIR/${BASE}_1.fq.gz --right $OUTDIR/${BASE}_2.fq.gz -c $CPU -o $WORKDIR/${BASE}
    fi
    echo "$LEFTTRIM $RIGHTTRIM"
    AAFTF filter -c $CPU --memory $MEM -o $WORKDIR/${BASE} --left $LEFTTRIM --right $RIGHTTRIM --aligner bbduk
    #
    echo "$LEFT $RIGHT"
    if [ -f $LEFT ]; then
	unlink $LEFTTRIM
	unlink $RIGHTTRIM
    else
	echo "Error in AAFTF filter"
    fi
fi
