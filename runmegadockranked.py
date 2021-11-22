#!/usr/bin/env python3
"""
Program: runmegadockranked
File:    runmegadockranked.py

Version: V1.0
Date:    18.11.21 
Function: Run input antibody and antigen files through the Megadock docking algorithm and extract the top-ranked docked ligand into a new PDB file.

Author: Oliver E. C. Hood

--------------------------------------------------------------------------

Description:
============
This program takes a receptor (antibody), ligand (antigen), and their bound complex as input. The residues at the binding interface between the proteins is determined and non-interface residues are 'blocked' using the blockNIres program

--------------------------------------------------------------------------

Usage:
======
runmegadockranked.py receptorfile ligandfile OUTPath

--------------------------------------------------------------------------

Revision History:
=================
V1.0   19.11.2021   Original   By: OECH


"""

#*************************************************************************

#Import Libraries

import sys
import os
import subprocess

#*************************************************************************
# Run Megadock

# Define receptor (antibody) file
receptor = sys.argv[1]
# Define ligand (antigen) file
ligand = sys.argv[2]
# Get output path from command line (if present)
OUTPath = ''
try:
   OUTPath = sys.argv[3] + '/'
except IndexError:
   OUTPath = './'
# Run Megadock
subprocess.run(["~/DockingSoftware/megadock-4.1.1/megadock -R " + receptor + " -L " + ligand + " -o megadock.out"], shell=True)
# Get input file basename
filenamecontents = os.path.basename(receptor).split('.')[0].split('_')
inputfilename = filenamecontents[0] + "_" + filenamecontents[1]
# Define output filename
outfile = OUTPath+inputfilename + "_rank_Dag.pdb"

#*************************************************************************
# Run ZRank on megadock outfileq
subprocess.run(["~/DockingSoftware/zdock3.0.2/zrank megadock.out 1 200"], shell=True)

# Extracting top ranked output
# Initiate max out variable
max_out = 0

# Read Zrank out file
with open('megadock.out.zr.out') as file:
   # Read lines
   rows = file.readlines()
   # Identify highest scoring output
   for line in rows:
      contents = line.split()
      if float(contents[1]) > max_out:
         max_out = float(contents[1])
         # Get number of the top hit
         top_hit = contents[0]

# Extract top docking result from megadock using decoygen
subprocess.run(["~/DockingSoftware/megadock-4.1.1/decoygen " + outfile + " " + ligand + " megadock.out " + top_hit], shell=True)

# Remove megadock.out and megadock.out.zr.out files
subprocess.run(["rm megadock.out megadock.out.zr.out"], shell=True)