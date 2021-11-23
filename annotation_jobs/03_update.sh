#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem 24G
#SBATCH --time=2-00:00:00   
#SBATCH --output=annotupdate_02.%A.log
#SBATCH --job-name="funannot_update"
module unload miniconda2
module load funannotate/1.8.1

export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
export PASAHOME=`dirname $(which Launch_PASA_pipeline.pl)`
export PASACONF=$HOME/pasa.CONFIG.template

which augustus
CPUS=$SLURM_CPUS_ON_NODE

if [ ! $CPUS ]; then
 CPUS=2
fi

if [ ! -f config.txt ]; then
 echo "need a config file for parameters"
 exit
fi

which python
source config.txt

if [ ! $ODIR ]; then
 ODIR=$(basename `pwd`)."funannot"
fi
funannotate update -i $ODIR --cpus $CPUS --sbt Pcap_v2.sbt  --pasa_db mysql   --pasa_config $PASACONF
