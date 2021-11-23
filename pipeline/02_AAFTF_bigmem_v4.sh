#!/bin/bash
#SBATCH --nodes 1 --ntasks 32 --mem 192gb -J PcapASM --out logs/AAFTF_asm.v4.log -p intel --time 72:00:00

hostname
MEM=192
CPU=$SLURM_CPUS_ON_NODE
N=${SLURM_ARRAY_TASK_ID}
MIN_LEN=1000

module load AAFTF/git-live


BASE=AV1
PILONITER=10
ASM=genome
ASMFILE=$ASM/Phytophthora_capsici_20190508_masurca_3_3_1.fasta
WORKDIR=working_AAFTF
VECCLEAN=$ASM/Phytophthora_capsici_v4.vecscreen.fasta
PURGE=$ASM/Phytophthora_capsici_v4.sourpurge.fasta
CLEANDUP=$ASM/Phytophthora_capsici_v4.rmdup.fasta
PILON=$ASM/Phytophthora_capsici_v4.pilon.fasta
SORTED=$ASM/Phytophthora_capsici_v4.sorted.fasta
STATS=$ASM/Phytophthora_capsici_v4.sorted.stats.txt

if [ -z $CPU ]; then
    CPU=1
fi


LEFT=$WORKDIR/${BASE}_filtered_1.fastq.gz
RIGHT=$WORKDIR/${BASE}_filtered_2.fastq.gz

mkdir -p $WORKDIR

echo "$BASE"
if [ ! -f $ASMFILE ]; then    
    echo "No assembly"
    exit
fi

if [ ! -f $VECCLEAN ]; then
    AAFTF vecscreen -i $ASMFILE -c $CPU -o $VECCLEAN 
fi

#PHYLUM=
#if [ ! -f $PURGE ]; then
#    AAFTF sourpurge -i $VECCLEAN -o $PURGE -c $CPU --phylum Oomycetes --left $LEFT  --right $RIG#HT
#fi

if [ ! -f $CLEANDUP ]; then
   AAFTF rmdup -i $VECCLEAN -o $CLEANDUP -c $CPU -m $MIN_LEN
fi
exit
if [ ! -f $PILON ]; then
   AAFTF pilon -i $CLEANDUP -o $PILON -c $CPU --left $LEFT  --right $RIGHT --iterations $PILONITER
fi

if [ ! -f $PILON ]; then
    echo "Error running Pilon, did not create file. Exiting"
    exit
fi

if [ ! -f $SORTED ]; then
    AAFTF sort -i $PILON -o $SORTED
fi

if [ ! -f $STATS ]; then
    AAFTF assess -i $SORTED -r $STATS
fi
