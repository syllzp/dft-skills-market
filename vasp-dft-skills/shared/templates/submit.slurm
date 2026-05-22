#!/bin/bash
#SBATCH -J <JOB_NAME>
#SBATCH -N 1
#SBATCH -n <N_CORES>
#SBATCH --mem=<MEMORY_MB>MB
#SBATCH -p <PARTITION>

module purge
module load vasp/6

mpirun vasp_std
