"""
Program: runhaddock
File:    runhaddock.py

Version:  V1.0
Date:     15.02.2022
Function: Run input antibody and antigen files through the haddock protein docking algorithm, output a single result file.

Author: Oliver E. C. Hood

--------------------------------------------------------------------------

Description:
============
This program takes an antibody file and an antigen file as input for the haddock protein docking program, a single PDB file will be extracted as a result with waters included and without waters included (waters should be better?).

--------------------------------------------------------------------------

Usage:
======
runhaddock.py antibody antigen length OUTPath

--------------------------------------------------------------------------

Revision History:
=================
V1.0   15.02.22   Original   By: OECH

"""

# *************************************************************************

import argparse
import os
import subprocess
import sys
import textwrap
from pathlib import Path

import yaml
from loguru import logger

from .run_haddock_lib import (clean_inputs, edit_run_cns, extract_best_results,
                              fix_chain_labelling, generate_run_param,
                              generate_unambig_tbl, rewrite_unambig_tbl)

# ==================== Configuration ====================


# ==================== Function ====================


def cli() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        description="Filter out problematic AbM numbered file identifiers.",
        epilog=textwrap.dedent(
            """
        Example usage:
            python # TDOO
        """
        ),
    )
    parser.add_argument("-ab", "--antibody_path", type=Path, help="antibody file path")
    parser.add_argument("-ag", "--antigen_path", type=Path, help="antigen file path")
    parser.add_argument(
        "-l",
        "--length",
        type=str,
        default="short",
        choices=["short", "long"],
        help="CNS argument: 'short' or 'long' run; default to short run",
    )
    parser.add_argument(
        "-outdir",
        "--output_directory",
        type=Path,
        default=Path.cwd(),
        help="output directory, default to $PWD",
    )

    args = parser.parse_args()

    return args


def validate_args(args: argparse.Namespace) -> None:
    """
    Validate input arguments.

    Args:
        args (argparse.Namespace): argparse.Namespace object

    Raises:
        FileNotFoundError: raise if either antibody or antigen file not found
    """
    # assert file exist
    try:
        assert args.antibody_path.exists()
    except AssertionError as e:
        raise FileNotFoundError(f"File not found: {args.antibody_path}")
    try:
        assert args.antigen_path.exists()
    except AssertionError as e:
        raise FileNotFoundError(f"File not found: {args.antigen_path}")

    # create output directory if not exist
    args.output_directory.mkdir(parents=True, exist_ok=True)


# ==================== Main ====================

# def main(args: argparse.Namespace) -> None:
args = cli()
validate_args(args)

antibody = args.antibody_path.as_posix()
antigen = args.antigen_path.as_posix()
ab_filename: str = args.antibody_path.stem
ag_filename: str = args.antigen_path.stem


# Clean input files
clean_inputs(antibody, antigen, ab_filename, ag_filename)

# *************************************************************************

# Generate unambig_tbl file
generate_unambig_tbl(ab_filename)

# Define unambig_tbl filename
unambig_tbl = "./antibody-antigen-unambig.tbl"

# Rewrite unambig_tbl file to include segIDs
rewrite_unambig_tbl(unambig_tbl)

# *************************************************************************

# Generate run.param file
generate_run_param(ab_filename, ag_filename, OUTPath)

# *************************************************************************

# Run haddock2.4 for first time
subprocess.run(
    [f"/home/oliverh/DockingSoftware/haddock2.4/Haddock/RunHaddock.py"], shell=True
)

# *************************************************************************

# Edit CNS file
# Determine whether the run should be long or short
long = False
if length.lower() == "long":
    long = True
# Edit file
edit_run_cns(long)

# *************************************************************************

# Move to run1 directory, run haddock2.4 again
subprocess.run(
    ["cd run1; /home/oliverh/DockingSoftware/haddock2.4/Haddock/RunHaddock.py"],
    shell=True,
)

# *************************************************************************

# Move back to start directory
subprocess.run(["pwd"], shell=True)

# Extract result files

# Get base input filename
inputfilename = ab_filename.split("_ab")[0]

# Extract files
extract_best_results(inputfilename)

# *************************************************************************

# Split antibody chains and relabel chains for final result file

# Define nowaters resultfile
resultfile_nowaters = f"{inputfilename}_Haddock_nowaters_result.pdb"

# Define waters resultfile
resultfile_waters = f"{inputfilename}_Haddock_waters_result.pdb"

# Run fix_chain_labelling on nowaters file
fix_chain_labelling(antigen, resultfile_nowaters)

# Run fix_chain_labelling on waters file
fix_chain_labelling(antigen, resultfile_waters)

# *************************************************************************
