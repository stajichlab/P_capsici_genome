#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 48 -p stajichlab --mem 196G --out logs/bwa_realign.log
MEM=196g
module load bwa/0.7.17
module unload java
module load java/8
module load picard
module load gatk/3.7

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi


INDIR=working_AAFTF
RUN=AV1
PAIR1=$INDIR/${RUN}_filtered_1.fastq.gz
PAIR2=$INDIR/${RUN}_filtered_2.fastq.gz
STRAIN=LT1534
TOPOUTDIR=tmp
ALNFOLDER=bam
HTCEXT=bam
REFGENOME=genome/Phytophthora_capsici_v3.sorted.fasta
TEMP=tmp
SAMFILE=$TOPOUTDIR/$RUN.unsrt.sam
SRTED=$TOPOUTDIR/${RUN}.srt.bam
DDFILE=$TOPOUTDIR/${RUN}.DD.bam
REALIGN=$TOPOUTDIR/${RUN}.realign.bam
INTERVALS=$TOPOUTDIR/${RUN}.intervals
FINALFILE=$ALNFOLDER/${RUN}.$HTCEXT
CENTER=UCR
READGROUP="@RG\tID:$RUN\tSM:$STRAIN\tLB:$RUN\tPL:illumina\tCN:$CENTER"
mkdir -p $TEMP $TOPOUTDIR
if [ ! -f $REFGENOME.pac ]; then
	bwa index $REFGENOME
fi
if [ ! -f $REFGENOME.fai ]; then
	samtools faidx $REFGENOME
fi
DICT=$(echo $REFGENOME | perl -p -e 's/\.fasta$/.dict/')
if [[ ! -f $DICT || $REFGENOME -nt $DICT ]]; then
	rm -f $DICT
	picard CreateSequenceDictionary R=$REFGENOME O=$DICT
	ln -s $(basename $DICT) $REFGENOME.dict
fi


if [ ! -f $DDFILE ]; then
    if [ ! -f $SRTED ]; then
	bwa mem -t $CPU -R $READGROUP $REFGENOME $PAIR1 $PAIR2 > $SAMFILE
	samtools fixmate --threads $CPU -O bam $SAMFILE $TEMP/${RUN}.fixmate.bam
	samtools sort --threads $CPU -O bam -o  $SRTED -T $TEMP $TEMP/${RUN}.fixmate.bam
	/usr/bin/rm $TEMP/${RUN}.fixmate.bam $SAMFILE
    fi
    
    picard MarkDuplicates I=$SRTED O=$DDFILE \
	METRICS_FILE=logs/$RUN.dedup.metrics CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT READ_NAME_REGEX=null
    if [ -f $DDFILE ]; then
	rm -f $SRTED
    fi
    if [ ! -f $DDFILE.bai ]; then
	picard BuildBamIndex I=$DDFILE TMP_DIR=/scratch
    fi # DDFILE is created after this or already exists
fi

if [ ! -f $INTERVALS ]; then
    time java -Xmx$MEM -jar $GATK \
	-T RealignerTargetCreator \
	-R $REFGENOME \
	-I $DDFILE \
	-o $INTERVALS
fi
if [ ! -f $FINALFILE ]; then
    time java -Xmx$MEM -jar $GATK \
	-T IndelRealigner \
	-R $REFGENOME \
	-I $DDFILE \
	-targetIntervals $INTERVALS \
	-o $FINALFILE
fi

samtools index $FINALFILE
if [ -f $FINALFILE ]; then
    rm -f $DDFILE 
    rm -f $(echo $DDFILE | sed 's/bam$/bai/')
    rm -f $INTERVALS
fi

 #FINALFILE created or already exists
