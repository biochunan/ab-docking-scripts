# ab-docking-scripts

This is my repository for scripts relating to my MSci project with the working title 'Evaluating Protein-Protein Docking Algorithms for Predicting Antibody-Antigen Binding'.

## Abstract

The high specificity and affinity of antibodies for their antigens make them attractive targets for the development of therapeutics, a huge market that is expected to expand through 2026. The rational design of antibody therapeutics is limited by the knowledge of the epitope bound by the antibody, with conventional epitope mapping approaches such as alanine scanning and X-ray crystallography being both time-consuming and labor-intensive. The in silico determination of antibody-antigen complexes is therefore of value.

There exist numerous protein ‘docking’ algorithms, many of which have been assessed by the Critical Assessment of PRedicted Interactions. This assessment lacks a comprehensive evaluation of docking accuracy with regard to antibody-antigen complexes, with only 7 of 107 target complexes featuring antibody-antigen complexes. Here we describe an evaluation of four docking algorithms: Megadock, PIPER, HADDOCK, and RosettaDock, on 39 antibody-antigen complexes.

We show that, despite utilizing a less complicated approach to docking, Megadock produces complex structures at a similar accuracy to PIPER and RosettaDock, while producing results in a substantially shorter period of time. These results present Megadock as a useful tool for the development of antibody therapeutics, as well as antibody research generally.

## Content

- [ab-docking-scripts](#ab-docking-scripts)
  - [Abstract](#abstract)
  - [Content](#content)
  - [Usage](#usage)
    - [PIPER](#piper)
  - [Docking Architecture](#docking-architecture)
  - [Directories](#directories)
    - [test](#test)
  - [BiopTools](#bioptools)
  - [Scripts](#scripts)
    - [common/dockingtools\_lib.py](#commondockingtools_libpy)
    - [common/split\_abag\_chains.py](#commonsplit_abag_chainspy)
    - [megadock/run\_megadock\_ranked.py](#megadockrun_megadock_rankedpy)
    - [piper/run\_piper.py](#piperrun_piperpy)
    - [haddock/run\_haddock.py](#haddockrun_haddockpy)
    - [rosetta/run\_rosetta.py](#rosettarun_rosettapy)
    - [run\_profit\_single.py](#run_profit_singlepy)
    - [evaluate\_interface.py](#evaluate_interfacepy)
    - [test\_docking\_progs\_master.py](#test_docking_progs_masterpy)
    - [get\_summary\_results.py](#get_summary_resultspy)
    - [run\_test\_docking\_progs\_master.sh](#run_test_docking_progs_mastersh)
    - [extract\_results.py](#extract_resultspy)
  - [reproduce data](#reproduce-data)
  - [config yaml setup](#config-yaml-setup)

---

## Usage

### PIPER

This requires `sblu` which requires `cc1plus`, to install via conda

```bash
# create env
envName="abagdocking"
conda create -n $envName python=3.10 -y
conda activate $envName
# install gcc
conda install gcc -y
conda install gcc_linux-64 -y
conda install gxx_linux-64 -y
```

## Docking Architecture

<img width="336" alt="image" src="https://user-images.githubusercontent.com/51133654/165328484-beb152a2-34fe-4cab-8404-970530b93097.png">

This figure shows the architecture of the docking evaluation analysis. Solved antibody-antigen complexes are split into their antibody and antigen components by `split_abag_chains.py`. The split structures are used as input for the docking algorithms, the output of which is a single docked complex structure. This structure is evaluated by comparison to the native complex using ProFit.

## Directories

### test

Contains test files for some functions written in Python scripts.
A ReadMe file describing the contents and expected result for each test is provided.

## BiopTools

Many of the scripts in this repository call on programs in the BiopTools collection of tools built on the BiopLib library written by Andrew Martin. The library and tools are available from (<https://github.com/ACRMGroup/bioptools/releases>). The programs used must be in the path on a local machine for the scripts to run as intended. Alternatively, scripts can be modified to define the location of the programs.

## Scripts

### common/dockingtools_lib.py

A library of tools frequently used by scripts in `ab-docking-scripts`.

### common/split_abag_chains.py

This script was written to split an input antibody-antigen complex into its antibody and antigen components, randomly rotating and translating the antigen chain by up to 8 degrees and 3 angstroms. The script filters input files for the number of antigen chains present, skipping files that have no antigen or that have multiple antigen chains.

### megadock/run_megadock_ranked.py

Script to run the Megadock docking program, followed by the ZRANK ranking program, available from (<https://www.bi.cs.titech.ac.jp/megadock/archives/megadock-4.1.1.tgz>) and (<https://zdock.umassmed.edu/software/download/>), respectively. This script takes up to 3 command line arguments:

- Path to the receptor (antibody) file
- Path to the ligand (antigen) file
- Output directory (optional)
The output is a single file with the suffix '_MegadockRanked_result.pdb'.

### piper/run_piper.py

Script to run the PIPER docking program, available from (<https://cluspro.bu.edu/downloads.php>). This script calls on maskNIres.py to write a mask file of non-interface residues for input to PIPER which in turn calls on `findif.pl` to define interface residues. This script takes up to 4 command line arguments:

- Path to the original complex file
- Path to the receptor (antibody) file
- Path to the ligand (antigen) file
- Output directory (optional)
The output is a single file with the suffix '_Piper_result.pdb'.

### haddock/run_haddock.py

Script to run the HADDOCK docking program, available from (<https://www.bonvinlab.org/software/haddock2.4/download/>). HADDOCK relies on the CNS program, available from (<http://cns-online.org/v1.3/>). This script takes up to 4 command line arguments:

- Path to the antibody file
- Path to the antigen file
- Length of docking run (long or short, default=short)
- Output directory (optional)
The output is two files with the suffixes '_Haddock_nowaters_result.pdb' and '_Haddock_waters_result.pdb'.

### rosetta/run_rosetta.py

Script to run the RosettaDock docking program, available from (<https://www.rosettacommons.org/software/academic>). This script takes up to 5 command line arguments:

- Path to the original complex file
- Path to the antibody file
- Path to the antigen file
- Number of output structures (default=10)
- Output directory (optional)
The output is a single file with the suffix '_Rosetta_result.pdb'.

### run_profit_single.py

Script to evaluate the complexes predicted by docking programs using ProFit, available from (<http://www.bioinf.org.uk/software/profit/>). This script takes up to 3 command line arguments:

- Path to the original complex file
- Path to the predicted complex file
- Output directory (optional)
The output is two lines on the command line:
- 'All atoms RMSD:  '
- 'CA atoms RMSD:   '

### evaluate_interface.py

Script to evaluate the complexes predicted by docking programs by the proportion of correctly predicted interface residues. This script takes up to 3 command line arguments:

- Path to the original complex file
- Path to the predicted complex file
- Output directory (optional)
The output is five lines on the command line:
- 'Proportion of correctly predicted interface residues (0-1):'
- '============================================================'
- 'Correctly predicted residue pairs:       '
- 'Correctly predicted residues (antibody): '
- 'Correctly predicted residues (antigen):  '

### test_docking_progs_master.py

Wrapper script to run the scripts described above, following the architecture shown above. This script takes up to 2 command line arguments:

- Path to the original complex file
- Output directory (optional)
The output includes multiple lines of code specifying what script is being run, that script's standard input/output, markers for the completion of a script, and multiple results files.

### get_summary_results.py

Defunct script to extract summary results from result files generated by `test_docking_progs_master.py`.

Replaced with `extract_results.py`.

### run_test_docking_progs_master.sh

Wrapper script calling the `test_docking_progs_master.py` script and the `get_summary_results.py` script. (N.b. getsummaryresults.py did not work as intended and was replaced with the extract_results.py script, though it is still called by this wrapper).

### extract_results.py

Script to extract the result values for a docking run if it has been completed. This script takes up to 2 command line arguments:

- Path to the logfile written with the testdockingprogs_master.py script
- Output directory (optional)
The output is a JSON file with the suffix '_results.json'.

## reproduce data

calling piper

```shell
python script.py config.yml
```

## config yaml setup

```yaml
executable:
  megadock: """
```

- `megadock`: path to megadock binary executable
