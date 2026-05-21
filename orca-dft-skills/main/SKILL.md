# ORCA 5+ DFT Skills

ORCA 5+ computational chemistry skill suite for input generation, error diagnosis, and output parsing. All sub-skills follow ORCA 5+ best practices and produce publication-ready results.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| geo-opt-input | Generate geometry optimization input files | `../skills/geo-opt-input/SKILL.md` |

## Dispatch Logic

When a user requests ORCA-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: optimize, relax, minimize geometry, Opt) → `../skills/geo-opt-input/SKILL.md`
- **Frequency calculation input** → Not yet available
- **TDDFT/excitation input** → Not yet available
- **Single-point energy input** → Not yet available
- **Error diagnosis** → Not yet available
- **Output parsing** → Not yet available

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
