# CP2K 2024.x DFT Skills

CP2K 2024.x computational chemistry skill suite for input generation, error diagnosis, and output parsing. All sub-skills follow CP2K 2024.x best practices using the Quickstep (GPW/GAPW) method and produce publication-ready results.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| geo-opt-input | Generate CP2K geometry optimization input files | `../skills/geo-opt-input/SKILL.md` |
| sp-energy-input | Generate CP2K single-point energy input files | `../skills/sp-energy-input/SKILL.md` |
| freq-input | Generate CP2K vibrational frequency analysis input files | `../skills/freq-input/SKILL.md` |
| output-parse | Parse CP2K output files and extract results | `../skills/output-parse/SKILL.md` |
| error-diagnosis | Diagnose CP2K calculation errors and suggest fixes | `../skills/error-diagnosis/SKILL.md` |

## Dispatch Logic

When a user requests CP2K-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: optimize, relax, minimize geometry, GEO_OPT) → `../skills/geo-opt-input/SKILL.md`
- **Generate single-point energy input** (keywords: single-point, SP, energy, SCF energy, static calculation) → `../skills/sp-energy-input/SKILL.md`
- **Generate vibrational frequency input** (keywords: frequency, freq, vibrational, VIBRATIONAL_ANALYSIS, IR, phonon) → `../skills/freq-input/SKILL.md`
- **Parse CP2K output** (keywords: parse, extract, read output, results, energy from output, analyze output) → `../skills/output-parse/SKILL.md`
- **Diagnose CP2K errors** (keywords: error, failed, SCF not converged, OT failed, GEO_OPT, crash, debug) → `../skills/error-diagnosis/SKILL.md`
- **NEB/transition state input** → Not yet available
- **Molecular dynamics (MD) input** → Not yet available

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
