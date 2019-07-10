#!/usr/bin/bash
#SBATCH --time 2:00:00 --mem 2G 

module load gmap/2018-07-04
cd genome
gmap_build -D=. -d P_capsici_LT1534 Phytophthora_capsici_LT1534.scaffolds.fa
gff3_splicesites < Phytophthora_capsici_LT1534.gff3 > Phytophthora_capsici_LT1534.splicesites.txt
iit_store -o P_capsici_LT1534/P_capsici_LT1534.maps/splicesites.iit < Phytophthora_capsici_LT1534.splicesites.txt
