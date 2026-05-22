# Gaussian 16 DFT Skills

Gaussian 16 computational chemistry skill suite for input generation, error diagnosis, and output parsing. All sub-skills follow Gaussian 16 best practices and produce publication-ready results.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| geo-opt-input | Generate geometry optimization input files | `../skills/geo-opt-input/SKILL.md` |
| sp-energy-input | Generate single-point energy input files | `../skills/sp-energy-input/SKILL.md` |
| freq-input | Generate frequency calculation input files | `../skills/freq-input/SKILL.md` |
| tddft-input | Generate TDDFT excited-state calculation input files | `../skills/tddft-input/SKILL.md` |
| basis-reference | Recommend basis sets for Gaussian calculations | `../skills/basis-reference/SKILL.md` |
| relativistic-reference | Recommend relativistic methods for Gaussian calculations | `../skills/relativistic-reference/SKILL.md` |
| output-parse | Parse Gaussian output files and extract results | `../skills/output-parse/SKILL.md` |
| error-diagnosis | Diagnose Gaussian calculation errors and suggest fixes | `../skills/error-diagnosis/SKILL.md` |

## Dispatch Logic

When a user requests Gaussian-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: optimize, relax, minimize geometry, Opt, Gaussian input) → `../skills/geo-opt-input/SKILL.md`
- **Generate single-point energy input** (keywords: single-point, SP, energy, SCF energy, single point) → `../skills/sp-energy-input/SKILL.md`
- **Generate frequency calculation input** (keywords: frequency, freq, vibrational, harmonic, IR, Raman, opt+freq) → `../skills/freq-input/SKILL.md`
- **Generate TDDFT/excited-state input** (keywords: TDDFT, excited-state, excitation, UV-Vis, spectrum, NStates, Root, TD) → `../skills/tddft-input/SKILL.md`
- **Recommend basis sets** (keywords: basis, basis set, basis function, Pople, Dunning, Ahlrichs, def2, ECP, which basis, LANL2DZ, 6-31G) → `../skills/basis-reference/SKILL.md`
- **Recommend relativistic methods** (keywords: relativistic, ECP, pseudopotential, DKH, Douglas-Kroll, X2C, spin-orbit, SOC, heavy element, LANL2DZ, SDD, lanthanide, actinide) → `../skills/relativistic-reference/SKILL.md`
- **Parse Gaussian output** (keywords: parse, extract, read output, results, energy from output, analyze output) → `../skills/output-parse/SKILL.md`
- **Diagnose Gaussian errors** (keywords: error, failed, SCF failed, Link died, L301, L502, crash, debug) → `../skills/error-diagnosis/SKILL.md`

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
