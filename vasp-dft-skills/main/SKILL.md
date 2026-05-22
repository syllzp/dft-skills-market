# VASP 6.x DFT Skills

VASP 6.x computational chemistry skill suite for input generation, error diagnosis, and output parsing. All sub-skills follow VASP 6.x best practices and produce publication-ready results.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| geo-opt-input | Generate VASP geometry optimization input files | `../skills/geo-opt-input/SKILL.md` |
| sp-energy-input | Generate single-point energy input files | `../skills/sp-energy-input/SKILL.md` |
| freq-input | Generate phonon/frequency calculation input files | `../skills/freq-input/SKILL.md` |
| output-parse | Parse VASP OUTCAR/OSZICAR output and extract results | `../skills/output-parse/SKILL.md` |
| error-diagnosis | Diagnose VASP calculation errors and suggest fixes | `../skills/error-diagnosis/SKILL.md` |

## Dispatch Logic

When a user requests VASP-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: optimize, relax, minimize geometry, VASP relaxation, ion motion) → `../skills/geo-opt-input/SKILL.md`
- **Generate single-point energy input** (keywords: single-point, SP, energy, SCF energy, static calculation) → `../skills/sp-energy-input/SKILL.md`
- **Generate phonon/frequency input** (keywords: phonon, frequency, freq, vibrational, Hessian, IBRION=5, DFPT) → `../skills/freq-input/SKILL.md`
- **Parse VASP output** (keywords: parse, extract, read OUTCAR, results, energy from output, analyze output) → `../skills/output-parse/SKILL.md`
- **Diagnose VASP errors** (keywords: error, failed, SCF error, POSCAR error, POTCAR, crash, debug, OUTCAR error) → `../skills/error-diagnosis/SKILL.md`
- **NEB/transition state search** → Not yet available

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
