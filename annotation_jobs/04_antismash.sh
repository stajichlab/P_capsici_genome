#!/usr/bin/bash

#SBATCH --ntasks 1 --nodes 1 --time 3-0:0:0 -p batch --out antismash_remote.%A.log
source config.txt
funannotate remote -i funannot -m antismash -e $EMAIL

