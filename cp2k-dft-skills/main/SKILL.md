# CP2K 2024.x DFT Skills

CP2K 2024.x computational chemistry skill suite for input generation, error diagnosis, and output parsing. All sub-skills follow CP2K 2024.x best practices using the Quickstep (GPW/GAPW) method and produce publication-ready results.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| geo-opt-input | Generate CP2K geometry optimization input files | `../skills/geo-opt-input/SKILL.md` |

## Dispatch Logic

When a user requests CP2K-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: optimize, relax, minimize geometry, GEO_OPT) → `../skills/geo-opt-input/SKILL.md`
- **Single-point energy input** → Not yet available
- **NEB/transition state input** → Not yet available
- **Molecular dynamics (MD) input** → Not yet available
- **Error diagnosis** → Not yet available
- **Output parsing** → Not yet available

If a request does not match any available sub-skill, inform the user and list what is available.

## General Guidelines

- All inputs use CP2K's Quickstep method (GPW/GAPW) with GTH pseudopotentials, MOLOPT basis sets, and DFT-D3 dispersion.
- The Orbital Transformation (OT) method is the recommended SCF solver for most systems; diagonalization is used only for metallic or charged periodic systems.
- Outputs are ready for academic research and publications.
- Each sub-skill is self-contained and portable.

## Running CP2K

After a sub-skill generates an input file:

```bash
# Serial
cp2k <input>.inp > <input>.out

# MPI parallel
mpirun -np <N> cp2k.popt <input>.inp > <input>.out

# GPU acceleration (CP2K 2024.x with CUDA)
mpirun -np <N> cp2k.sopt <input>.inp > <input>.out
```

Recommended: use the SLURM submission script at `../shared/templates/submit.slurm` for HPC deployments.
