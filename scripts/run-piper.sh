#!/bin/zsh

set -e

# Aim: run piper on a single abdbid

##############################################################################
# FUNCTION                                                                   #
##############################################################################
function usage() {
  echo "Usage: $(basename $0)  --abdbfile|-f <abdbfile>  --outdir|-o <outdir>"
  echo "  --abdbfile|-f <abdbfile> : AbDb file       "
  echo "  --outdir|-o <outdir>     : Output directory (default to ${PIPER_OUTDIR})"
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


##############################################################################
# INPUT                                                                      #
##############################################################################
# default values
outDir=$PIPER_OUTDIR
inDir=$PIPER_INDIR
# Parse command line options
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --abdbfile|-f)
      abdbFile="$2"
      shift 2;;  # past argument and value
    --outdir|-o)
      outDir="$2"
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
print_msg "Activating conda environment" "INFO"
conda init zsh >/dev/null 2>&1
source $HOME/.zshrc
conda activate abagdocking

print_msg "Processing AbDb file: $(basename $abdbFile)" "INFO"

# create the interim directory
interimDir=$outDir/interim
mkdir -p $interimDir

name=${$(basename $abdbFile)%.*}
# 1. split the complex structure into ab and ag
split_abag_chains $abdbFile \
  -o $interimDir #> $outDir/$name.log 2>&1

# 2. run piper
python /home/vscode/docking/abagdocking/piper/run_piper.py \
  -c $abdbFile \
  -r $interimDir/${name}_ab.pdb \
  -l $interimDir/${name}_ag.pdb \
  -o $outDir #>> $outDir/$name.log 2>&1
