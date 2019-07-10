#!/bin/bash 
#SBATCH --nodes 1 --ntasks 8 --mem 12G -J subreadcount -p short
#SBATCH --time 2:00:00 --out logs/subread_count_exons.%a.log

module load subread/1.6.0

GENOME=genome/Phytophthora_capsici_LT1534.scaffolds.fa
# transcript file was updated to recover missing genes
GFF=genome/Phytophthora_capsici_LT1534.gtf
OUTDIR=results/featureCountsExons
INDIR=aln
EXTENSION=gsnap.bam
mkdir -p $OUTDIR
TEMP=/scratch
SAMPLEFILE=samples.txt

CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPUS ]; then
    CPUS=1
fi
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "cannot run without a number provided either cmdline or --array in sbatch"
 exit
fi


IFS=,
sed -n ${N}p $SAMPLEFILE | while read SAMPLE
do
    OUTFILE=$OUTDIR/$SAMPLE.gsnap_exon_reads.tab
    INFILE=$INDIR/$SAMPLE.$EXTENSION
    if [ ! -f $OUTFILE ]; then
	featureCounts -g gene_id -T $CPUS -G $GENOME -s 1 -a $GFF \
            --tmpDir $TEMP -f  \
	    -o $OUTFILE -F GTF $INFILE
    fi

    OUTFILE=$OUTDIR/$SAMPLE.gsnap_exon_reads.nostrand.tab
    INFILE=$INDIR/$SAMPLE.$EXTENSION
    if [ ! -f $OUTFILE ]; then
	featureCounts -g gene_id -T $CPUS -G $GENOME -s 0 -a $GFF \
            --tmpDir $TEMP -f \
	    -o $OUTFILE -F GTF $INFILE
    fi

    OUTFILE=$OUTDIR/$SAMPLE.gsnap_exon_frags.tab
    INFILE=$INDIR/$SAMPLE.$EXTENSION
    if [ ! -f $OUTFILE ]; then
	featureCounts -g gene_id -T $CPUS -G $GENOME -s 2 -a $GFF \
            --tmpDir $TEMP -f \
	    -o $OUTFILE -F GTF -p $INFILE
    fi
done

