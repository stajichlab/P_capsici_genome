#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 24 --mem 16gb  -p short
#SBATCH --time 2:00:00 -J gmapSRA --out logs/gmapSRA.%a.log
module load gmap/2018-07-04
IDXDIR=genome
GENOME=P_capsici_LT1534
CPU=2
THREADCOUNT=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
 THREADCOUNT=$(expr $CPU - 2)
 if [ $THREADCOUNT -lt 1 ]; then
  THREADCOUNT=1
 fi
fi

N=${SLURM_ARRAY_TASK_ID}
INDIR=fastq_other
OUTDIR=aln
SAMPLEFILE=other_samples.csv
mkdir -p $OUTDIR

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit
fi
#SAMPLE CONDITION REP
sed -n ${N}p $SAMPLEFILE | while read EXP PAIRED
do
    # OUTFILE=$OUTDIR/${EXP}.gsnap_${GENOME}.sam
    # OUTFILE=$OUTDIR/${SAMPLE}_${CONDITION}.r${REP}.gsnap_${GENOME}.sam
    # READS=$(ls $INDIR/${EXP}_*.fastq.gz | perl -p -e 's/\s+/ /g')
    OUTFILE=$OUTDIR/${EXP}.gsnap.sam
    if [ ! -s $OUTFILE ]; then  
	#
	#  echo "module load gmap/2018-02-12" > job_${EXP}.sh
	
	# echo "gsnap -t $THREADCOUNT -s splicesites -D $IDXDIR --gunzip \
	# -d $GENOME --read-group-id=$EXP --read-group-name=$SAMPLE -N 1 \
	# -A sam --force-single-end $READS > $OUTFILE" >> job_${EXP}.sh
	
	# bash job_${EXP}.sh
	# unlink job_${EXP}.sh
	if [[ "$PAIRED" == "YES" ]]; then
    	    READSFWD=$INDIR/${EXP}_1.fastq.gz
    	    READSREV=$INDIR/${EXP}_2.fastq.gz
	    gsnap -t $THREADCOUNT -s splicesites -D $IDXDIR --gunzip -d $GENOME --read-group-id=$EXP --read-group-name=$EXP -N 1 \
	    -A sam $READSFWD $READSREV  > $OUTFILE
	else 
	    READSFWD=$INDIR/${EXP}.fastq.gz
	    gsnap -t $THREADCOUNT -s splicesites -D $IDXDIR --gunzip -d $GENOME --read-group-id=$EXP --read-group-name=$EXP -N 1 \
	    -A sam --force-single-end $READSFWD  > $OUTFILE
	fi
    fi
done
