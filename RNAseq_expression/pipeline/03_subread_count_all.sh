#!/bin/bash 
#SBATCH --nodes 1 --ntasks 8 --mem 12G -J subreadcount -p short
#SBATCH --time 2:00:00 --out logs/subread_count_all.%A.log

module load subread/1.6.0

GENOME=genome/Phytophthora_capsici_LT1534.scaffolds.fa
# transcript file was updated to recover missing genes
GFF=genome/Phytophthora_capsici_LT1534.gtf
OUTDIR=results/allfeatureCountsExons
INDIR=aln
EXTENSION=gsnap.bam
mkdir -p $OUTDIR
TEMP=/scratch
SAMPLEFILE=samples.txt

CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPUS ]; then
    CPUS=1
fi

IFS=,
OUTFILE=$OUTDIR/gsnap_all_exon_reads.tab
if [ ! -f $OUTFILE ]; then
	featureCounts -g gene_id -T $CPUS -G $GENOME -s 1 -a $GFF \
            --tmpDir $TEMP -f  \
	    -o $OUTFILE -F GTF $INDIR/*.bam
    fi
OUTFILE=$OUTDIR/gsnap_all_exon_reads.nostrand.tab
if [ ! -f $OUTFILE ]; then
	featureCounts -g gene_id -T $CPUS -G $GENOME -s 0 -a $GFF \
            --tmpDir $TEMP -f \
	    -o $OUTFILE -F GTF $INDIR/*.bam
    fi
OUTFILE=$OUTDIR/gsnap_exon_frags.tab
if [ ! -f $OUTFILE ]; then
	featureCounts -g gene_id -T $CPUS -G $GENOME -s 2 -a $GFF \
            --tmpDir $TEMP -f \
	    -o $OUTFILE -F GTF -p $INDIR/*.bam
    fi

