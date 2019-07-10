#!/usr/bin/bash
#SBATCH -N 1 -n 24 --mem 96gb -p stajichlab --time 24:00:00 --out smudge.log

MEM=96
module load KMC/3.1.1
CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPUS ]; then
    CPUS=2
fi
# smudgepot is installed locally in ~jstajich/bin
if [ -z $SLURM_JOB_ID ]; then
    SLURM_JOB_ID=$$
fi
TEMP=/scratch/$USER/$SLURM_JOB_ID
ls ../illumina/AV1_*.gz > FILES
if [ ! -f kmer_k21.hist ]; then
    mkdir -p $TEMP
    # kmer 21, 16 threads, 64G of memory, counting kmer coverages between 1 and 10000x
    kmc -k21 -t$CPUS -m$MEM -ci1 -cs10000 @FILES kmer_counts $TEMP
    kmc_tools transform kmer_counts histogram kmer_k21.hist -cx10000
    rm -rf $TEMP
fi

if [ ! -f kmer_k21.dump ]; then
    L=$(smudgeplot cutoff kmer_k21.hist L)
    U=$(smudgeplot cutoff kmer_k21.hist U)
    echo $L $U # these need to be sane values
    #L=32
    #U=2300
    # L should be like 20 - 200
    # U should be like 500 - 3000
    kmc_tools transform kmer_counts -ci$L -cx$U dump -s kmer_k21.dump
fi

if [ ! -f kmer_pairs ]; then
    smudgeplot hetkmers -o kmer_pairs < kmer_k21.dump
fi

smudgeplot plot kmer_pairs_coverages.tsv

Rscript genomescope/genomescope.R kmer_k21.hist 21 150 smudgepot.k21
