# Gaussian 16 DFT Skills

Gaussian 16 computational chemistry skill suite for input generation, error diagnosis, and output parsing. All sub-skills follow Gaussian 16 best practices and produce publication-ready results.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| geo-opt-input | Generate geometry optimization input files | `../skills/geo-opt-input/SKILL.md` |

## Dispatch Logic

When a user requests Gaussian-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: optimize, relax, minimize geometry, Opt, Gaussian input) → `../skills/geo-opt-input/SKILL.md`
- **Frequency calculation input** → Not yet available
- **TDDFT/excitation input** → Not yet available
- **Single-point energy input** → Not yet available
- **Error diagnosis** → Not yet available
- **Output parsing** → Not yet available

If a request does not match any available sub-skill, inform the user and list what is available.

## General Guidelines

- All inputs follow Gaussian 16 best practices: D3BJ dispersion, tight SCF, ultrafine grid, appropriate route section keywords.
- Outputs are ready for academic research and publications.
- Each sub-skill is self-contained and portable.
- For Gaussian memory, recommend `%mem` based on available RAM; use `%nprocshared` for parallelization.

## Running Gaussian 16

After a sub-skill generates an input file:
```bash
# For Gaussian 16 (typical environment):
g16 <input>.com
# Or using the provided SLURM script:
sbatch submit.slurm
```
