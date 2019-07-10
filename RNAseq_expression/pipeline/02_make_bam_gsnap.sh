#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 1 --mem 16gb --time 2:00:00 -p short -J gsnap.makebam --out logs/gsnap_makebam.%a.log

IDXDIR=genome
GENOME=P_capsici_LT1534
module load picard
MEM=16
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

N=$SLURM_ARRAY_TASK_ID
INDIR=aln
OUTDIR=aln
SAMPLEFILE=samples.csv
if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit
fi

IFS=,
#SAMPLE CONDITION REP

tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read EXP 
do
 echo $EXP 
infile=${INDIR}/${EXP}.gsnap.sam
bam=${INDIR}/$(basename $infile .sam).bam

echo "$infile $bam"
if [ ! -f $bam -a ! -z $bam ]; then
 java -Xmx${MEM}g -jar $PICARD AddOrReplaceReadGroups SO=coordinate I=$infile O=${bam} CREATE_INDEX=true TMP_DIR=/scratch/${USER} RGID=$EXP RGSM=$EXP RGPL=NextSeq RGPU=UCR RGLB=$EXP VALIDATION_STRINGENCY=LENIENT
fi
    
done
