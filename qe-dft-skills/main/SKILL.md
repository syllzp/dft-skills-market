# Quantum ESPRESSO 7.x DFT Skills

Quantum ESPRESSO (QE) 7.x skill suite for input generation, error diagnosis, and output parsing of plane-wave DFT calculations. All sub-skills follow QE 7.x best practices and the SSSP pseudopotential library conventions.

## Available Sub-Skills

| Sub-Skill | Purpose | Path |
|---|---|---|
| `geo-opt-input` | Generate geometry optimization (relaxation) input files for pw.x | `../skills/geo-opt-input/SKILL.md` |

## Dispatch Logic

When a user requests QE-related work, route to the appropriate sub-skill:

- **Generate geometry optimization input** (keywords: relax, optimize, minimize, geometry optimization, pw.x) → `../skills/geo-opt-input/SKILL.md`
- **Single-point energy input** → Not yet available
- **Band structure / DOS input** → Not yet available
- **Phonon / vibrational input** → Not yet available
- **NEB / transition state input** → Not yet available
- **Error diagnosis** → Not yet available
- **Output parsing** → Not yet available

If a request does not match any available sub-skill, inform the user and list what is available.

## General Guidelines

- All inputs follow QE 7.x best practices: SSSP pseudopotentials, proper plane-wave cutoffs, appropriate k-point sampling.
- Dispersion correction (DFT-D3) is included by default for molecular/surface systems.
- Outputs are ready for academic research and publications.
- Each sub-skill is self-contained and portable.
- Pseudopotentials should be downloaded from the SSSP library (https://www.materialscloud.org/discover/sssp/).

## Running pw.x

After a sub-skill generates an input file:

```bash
mpirun -np <NPROC> pw.x -in <input>.in > <input>.out
```

For serial execution:

```bash
pw.x < <input>.in > <input>.out
```
