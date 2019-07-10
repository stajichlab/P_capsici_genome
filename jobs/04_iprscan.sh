#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --job-name=iprscan
#SBATCH --time=6:00:00
#SBATCH --mem-per-cpu=3G
#SBATCH --out=iprscan.%A_%a.out

module load interproscan
INTERVAL=100
if [ ! -f config.txt ]; then
 echo "need a config file for parameters"
 exit
fi

source config.txt

if [ ! $ODIR ]; then
 ODIR=$(basename `pwd`)."funannot"
fi

CPUS=$SLURM_CPUS_ON_NODE
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
 if [ ! $N ]; then 
  echo "no N provided on cmdline, using 1"
  N=1
 fi
fi

if [ ! -d $ODIR/annotate_misc ]; then
 echo "Need an initial run of annotate"
 exit
fi

IPRDIR=$ODIR/annotate_misc/iprscan
if [ ! -d $IPRDIR ]; then
 mkdir -p $IPRDIR
 pushd $IPRDIR
 bp_seqretsplit.pl ../genome.proteins.fasta 
 popd
fi

JOBFILE=$ODIR/annotate_misc/iprscan_to_run.lst
if [ ! -f $JOBFILE ]; then
 pushd $IPRDIR
 for nm in $(find . -name '*.fa')
 do
  m=$(basename $nm .fa)
  if [ ! -f $m.xml ]; then
    basename $nm >> ../iprscan_to_run.lst 
  fi
 done
 popd
fi

STARTN=$(python -c "print ($N-1)*$INTERVAL+1")
ENDN=$(python -c "print ($N*$INTERVAL)")
FILELEN=$(wc -l $JOBFILE | perl -p -e 's/\s*(\d+)\s+.+/$1/')

if [ "$STARTN" -gt "$FILELEN" ]; then
 echo "STARTN ($STARTN) largerthan $FILELEN"
 exit
fi

if [ "$ENDN" -gt "$FILELEN" ]; then
# echo "too big ENDN"
 ENDN=$FILELEN
fi
echo "For job $N, interval is: $STARTN $ENDN"
for RN in $(seq $STARTN 1 $ENDN); do
 RUN=$(sed -n ${RN}p $JOBFILE )
 RUNBASE=$(basename $RUN .fa)
 echo "running $RUNBASE"
 if [ ! -f $IPRDIR/$RUNBASE.xml ]; then
  interproscan.sh -b $IPRDIR/$RUNBASE --iprlookup --goterms -i $IPRDIR/$RUN
 else 
  echo "skipping $RUNBASE already completed"
 fi
done
