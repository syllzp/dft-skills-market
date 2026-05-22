#!/bin/bash
#SBATCH --job-name=<NAME>
#SBATCH --nodes=<NODES>
#SBATCH --ntasks-per-node=<NTASKS>
#SBATCH --cpus-per-task=1
#SBATCH --time=<HH:MM:SS>
#SBATCH --partition=<PARTITION>
#SBATCH --output=<NAME>.slurm.out
#SBATCH --error=<NAME>.slurm.err

module purge
module load qe/<QE_VERSION>

export OMP_NUM_THREADS=1
export I_MPI_PIN=1

mpirun pw.x -in <FILE>.in > <FILE>.out
