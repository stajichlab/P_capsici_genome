#!/bin/bash
#SBATCH --ntasks 48 --nodes 1 --mem 128G -p intel --time 36:00:00 --out iprscan.%A.log
module unload miniconda2
module load funannotate/1.8.1
module load iprscan
DIR=funannot
if [ ! -f $DIR/annotate_misc/iprscan.xml ]; then
	funannotate iprscan -i $DIR -m local -c 48 --iprscan_path $(which interproscan.sh)
fi
