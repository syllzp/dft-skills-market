# VASP 6.x DFT Skills

VASP 6.x computational chemistry skill suite for input generation, error diagnosis, and output parsing. All sub-skills follow VASP 6.x best practices and produce publication-ready results.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| geo-opt-input | Generate VASP geometry optimization input files | `../skills/geo-opt-input/SKILL.md` |

## Dispatch Logic

When a user requests VASP-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: optimize, relax, minimize geometry, VASP relaxation, ion motion) → `../skills/geo-opt-input/SKILL.md`
- **Single-point energy input** → Not yet available
- **NEB/transition state search** → Not yet available
- **Phonon/frequency calculation** → Not yet available
- **Error diagnosis (OUTCAR errors, SCF failures)** → Not yet available
- **Output parsing** → Not yet available

If a request does not match any available sub-skill, inform the user and list what is available.

## General Guidelines

- All inputs follow VASP 6.x best practices: appropriate XC functionals, consistent ENCUT, correct POTCAR selection, proper k-point sampling.
- Outputs are ready for academic research and publications.
- Each sub-skill is self-contained and portable.
- Always check POTCAR compatibility: ensure all pseudopotentials come from the same VASP POTCAR version (e.g., PBE_54, SCAN_54).
- For spin-polarized systems, explicitly set `ISPIN = 2` and provide `MAGMOM`.

## Running VASP

After a sub-skill generates the input file set:
```bash
# Prepare all required files
# INCAR, POSCAR, POTCAR, KPOINTS must all be in the working directory

# Submit via SLURM (recommended)
sbatch submit.slurm

# Or run interactively on a cluster node
mpirun -np <N_CORES> vasp_std
```
