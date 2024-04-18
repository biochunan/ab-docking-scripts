# Benchmark antibody-antigen docking programs

This is based on Oliver Hood's repository ([@oliverhood](https://github.com/oliverhood)) for scripts related to his MSci project 'Evaluating Protein-Protein Docking Algorithms for Predicting Antibody-Antigen Binding'.

We described the evaluation of four docking algorithms: `Megadock`, `PIPER`, `HADDOCK`, and `RosettaDock`, on a set of non-redundant antibody-antigen (AbAg) complexes.

- `Megadock` was benchmarked using the full set composed of `1797` complexes since it is pretty fast, ~3 seconds to complete docking for a pair of antibodies and antigens using a GPU (NVIDIA RTX3090).
- The other three methods were benchmarked using a further reduced set of `540` complexes because they are computationally expensive. For example, on average, `PIPER` took on average ~14 minutes to complete docking for a pair using 128 CPU threads (it also depends on the antibody and antigen sizes).

## 👀 TL;DR

- All methods need improvement on AbAg docking
- `Megadock`: easier, faster, showed similar accuracy with `PIPER` and `RosettaDock,` better than `HADDOCK.`

<img width="800" alt="image" src=figures/superimpose-decoy-native.png>

Example: superimpose the docked antigen structure (green, blue, magenta, yellow) on the native antigen structure (white). `A`-`D`: `High`, `Medium`, `Acceptable`, and `Incorrect` quality (these are `DockQ` categories) of the docked antigen structure, respectively. PDB code: `3RU8`.

## 🤝 Collaboration

Let us know:

- If you want to test your method on our dataset
- If you want to dock your antibody and antigen structures (Academic research only; Commercial use is subject to the LICENSE of each program).

---

## Content

- [Benchmark antibody-antigen docking programs](#benchmark-antibody-antigen-docking-programs)
  - [👀 TL;DR](#-tldr)
  - [🤝 Collaboration](#-collaboration)
  - [Content](#content)
  - [Usage](#usage)
    - [PIPER](#piper)
  - [Docking Architecture](#docking-architecture)
  - [Dependencies](#dependencies)
    - [BiopLib and BiopTools](#bioplib-and-bioptools)

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

## Dependencies

### BiopLib and BiopTools

Many of the scripts in this repository call on programs in the BiopTools collection of tools built on the BiopLib library written by Andrew Martin. The library and tools are available from (<https://github.com/ACRMGroup/bioptools/releases>). The programs used must be in the path on a local machine for the scripts to run as intended. Alternatively, scripts can be modified to define the location of the programs.

## TODOs

- [ ] Obtain Datasets
- [ ] Dependency Installation
- [ ] Usage of each program with examples
