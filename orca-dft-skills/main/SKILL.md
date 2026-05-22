# ORCA 5+ DFT Skills

ORCA 5+ computational chemistry skill suite for input generation, error diagnosis, and output parsing. All sub-skills follow ORCA 5+ best practices and produce publication-ready results.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| geo-opt-input | Generate geometry optimization input files | `../skills/geo-opt-input/SKILL.md` |
| sp-energy-input | Generate single-point energy input files | `../skills/sp-energy-input/SKILL.md` |
| freq-input | Generate frequency calculation input files | `../skills/freq-input/SKILL.md` |
| tddft-input | Generate TDDFT excited-state calculation input files | `../skills/tddft-input/SKILL.md` |
| basis-reference | Recommend basis sets for ORCA calculations | `../skills/basis-reference/SKILL.md` |
| output-parse | Parse ORCA output files and extract results | `../skills/output-parse/SKILL.md` |
| error-diagnosis | Diagnose ORCA calculation errors and suggest fixes | `../skills/error-diagnosis/SKILL.md` |

## Dispatch Logic

When a user requests ORCA-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: optimize, relax, minimize geometry, Opt) → `../skills/geo-opt-input/SKILL.md`
- **Generate single-point energy input** (keywords: single-point, SP, energy, SCF energy, single point) → `../skills/sp-energy-input/SKILL.md`
- **Generate frequency calculation input** (keywords: frequency, freq, vibrational, harmonic, IR, Raman, opt+freq) → `../skills/freq-input/SKILL.md`
- **Generate TDDFT/excited-state input** (keywords: TDDFT, TDA, excited-state, excitation, UV-Vis, spectrum, root, NRoots) → `../skills/tddft-input/SKILL.md`
- **Recommend basis sets** (keywords: basis, basis set, basis function, def2, Dunning, Ahlrichs, Pople, ECP, effective core potential, which basis) → `../skills/basis-reference/SKILL.md`
- **Parse ORCA output** (keywords: parse, extract, read output, results, energy from output, analyze output) → `../skills/output-parse/SKILL.md`
- **Diagnose ORCA errors** (keywords: error, failed, SCF not converged, abort, fatal, crash, debug) → `../skills/error-diagnosis/SKILL.md`

If a request does not match any available sub-skill, inform the user and list what is available.

## General Guidelines

- All inputs follow ORCA 5+ best practices: D3BJ dispersion, RIJCOSX/RIJ approximation, TightSCF, appropriate grids.
- Outputs are ready for academic research and publications.
- Each sub-skill is self-contained and portable.
- For ORCA memory settings, recommend `%maxcore` based on available RAM.

## Running ORCA

After a sub-skill generates an input file:
```bash
export ORCA_MAXCORE=4000    # MB of RAM, adjust as needed
orca <input>.inp > <input>.out
```
