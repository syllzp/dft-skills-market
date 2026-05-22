#!/bin/bash
#SBATCH --job-name=<NAME>
#SBATCH --output=<NAME>.out
#SBATCH --error=<NAME>.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=<NPROC>
#SBATCH --cpus-per-task=1
#SBATCH --mem=<MEMORY_MB>MB
#SBATCH --time=<HH:MM:SS>
#SBATCH --partition=<PARTITION>

# Load CP2K module (adjust for your HPC environment)
module purge
module load cp2k/2024.1

# CP2K input file
INPUT="<NAME>.inp"

# Run CP2K (MPI parallel)
echo "Starting CP2K job: $(date)"
mpirun -np $SLURM_NTASKS cp2k.popt "$INPUT" > "${INPUT%.inp}.out"
echo "Job finished: $(date)"

# Check convergence
grep -q "OPTIMIZATION CONVERGED" "${INPUT%.inp}.out" && \
  echo "GEO_OPT converged successfully." || \
  echo "WARNING: GEO_OPT did NOT converge. Check output."
