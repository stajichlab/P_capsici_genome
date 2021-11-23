#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=4 --mem 8G
#SBATCH --mem=32G
#SBATCH --output=annot.funannot_03.%A.log
#SBATCH --time=6-0:00:00
#SBATCH -p batch -J annotfunc
module load funannotate/1.8.1
module load phobius
CPUS=$SLURM_CPUS_ON_NODE

if [ ! $CPUS ]; then
 CPUS=1
fi

if [ ! -f config.txt ]; then
 echo "need a config file for parameters"
 exit
fi

source config.txt
if [ ! $BUSCO ]; then
 BUSCO=fungi_odb9
fi
if [ ! $ODIR ]; then
 ODIR=funannot
fi
MOREFEATURE=""
if [ $TEMPLATE ]; then
 MOREFEATURE="--sbt $TEMPLATE"
fi
ANTISMASHRESULT=$ODIR/annotate_misc/antiSMASH.results.gbk
if [[ ! -f $ANTISMASHRESULT && -d $ODIR/antismash_local ]]; then
	ANTISMASH=$(ls $ODIR/antismash_local/*.gbk | head -n 1)
	if [[ ! -f $ANTISMASH || -z $ANTISMASH ]]; then
		echo "CANNOT FIND $ANTISMASH in $ODIR/antismash_local"
	else
		rsync -a $ANTISMASH $ANTISMASHRESULT
	fi
fi

funannotate annotate -i $ODIR --busco_db $BUSCO --species "$SPECIES" --strain "$ISOLATE" --cpus $CPUS $MOREFEATURE --rename $FINALPREFIX
