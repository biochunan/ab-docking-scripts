#!/bin/bash

set -e

# Aim: run piper on a single abdbid

##############################################################################
# FUNCTION                                                                   #
##############################################################################
function usage() {
  echo "Usage: $(basename $0)  --abdbfile|-f <abdbfile>  --outdir|-o <outdir>"
  echo "  --abdbfile|-f <abdbfile> : AbDb file       "
  echo "  --outdir|-o <outdir>     : Output directory"
  echo "  --help|-h                : Help            "
  # add example
  echo "Example:"
  echo "  $(basename $0) --abdbfile pdb1a2p.mar --outdir /path/to/outdir"
}

# Function to print timestamp
print_timestamp() {
  date +"%Y%m%d-%H%M%S"  # e.g. 20240318-085729
}

# print message with time
print_msg() {
  # level: INFO, WARNING, ERROR default INFO
  level=${2:-INFO}
  >&2 echo "[$level] $(print_timestamp): $1"  # send to stderr
}

##############################################################################
# CONFIG                                                                     #
##############################################################################
BASE=$(dirname $(dirname $(realpath $0)))  # ab-docking-scripts
SCRIPT=$BASE/abagdocking/piper/run_piper.py


##############################################################################
# INPUT                                                                      #
##############################################################################
# default value
OUTDIR=$(dirname $(realpath $0))
# Parse command line options
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --abdbfile|-f)
      abdbFile="$2"
      shift 2;;  # past argument and value
    --outdir|-o)
      OUTDIR="$2"
      shift 2;; # past argument and value
    --help|-h)
      usage
      shift # past argument
      exit 1;;
    *)
      echo "Illegal option: $key"
      usage
      exit 1;;
  esac
done

# assert required arguments
if [ -z "$abdbFile" ]; then
  echo "ag_chain is not set"
  usage
  exit 1
fi

##############################################################################
# MAIN                                                                       #
##############################################################################
# activate conda environment
conda init bash >/dev/null 2>&1
source ~/.bashrc
conda activate abagdocking

print_msg "Processing AbDb file: $(basename $abdbFile)" "INFO"

# create the interim directory
outDir=$OUTDIR
interimDir=$outDir/interim
mkdir -p $interimDir

# 1. split the complex structure into ab and ag
split_abag_chains $ABDB/pdb${abdbid}.mar \
  -o $interimDir > $outDir/$abdbid.log 2>&1

# 2. run piper
python $SCRIPT \
  -c $abdbFile \
  -r $interimDir/pdb${abdbid}_ab.pdb \
  -l $interimDir/pdb${abdbid}_ag.pdb \
  -o $outDir >> $outDir/$abdbid.log 2>&1
