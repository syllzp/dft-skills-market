#!/bin/bash
#SBATCH --job-name=<NAME>-opt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=<N_CORES>
#SBATCH --mem=<MEMORY_MB>MB
#SBATCH --time=<WALLTIME>
#SBATCH --output=<NAME>_%j.log
#SBATCH --error=<NAME>_%j.err
#SBATCH --partition=<PARTITION>

# Gaussian 16 environment (site-specific)
module load gaussian/g16

# Run Gaussian
g16 <NAME>.com
