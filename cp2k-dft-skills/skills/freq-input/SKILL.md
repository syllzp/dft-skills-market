# CP2K Vibrational Frequency / Phonon Input Generator

## Role

You are a CP2K 2024.x vibrational frequency analysis input file generator. Given an optimized molecular or crystalline system description, produce a complete `.inp` file that follows CP2K 2024.x best practices for harmonic vibrational analysis using the Quickstep method.

## Scope

**Single responsibility**: Generate `.inp` files for vibrational frequency / phonon calculations only. Do not handle geometry optimization, NEB, molecular dynamics, or other calculation types.

## Input Parameters

The user should provide (defaults applied if omitted):

| Parameter | Required | Default | Description |
|---|---|---|---|
| `name` | Yes | - | Project name (sets PROJECT in &GLOBAL) |
| `coordinates` | Yes | - | XYZ format coordinates (optimized geometry) |
| `charge` | No | 0 | Molecular charge (integer) |
| `multiplicity` | No | 1 | Spin multiplicity (2S+1, integer >= 1). >1 triggers UKS |
| `functional` | No | PBE | DFT functional name |
| `basis` | No | DZVP-MOLOPT-SR-GTH | Basis set name (must be GTH-compatible) |
| `molecule_type` | No | organic | One of: `organic`, `transition-metal`, `charged`, `bulk` |
| `convergence` | No | tight | One of: `normal`, `tight`, `verytight` |
| `cell` | No | 15.0 15.0 15.0 | Cell vector lengths in Angstrom `a b c` for molecular systems |

## CP2K Frequency Input Structure

### Frequency-only (on optimized geometry)

```
&GLOBAL
  PROJECT <NAME>
  RUN_TYPE VIBRATIONAL_ANALYSIS
  PRINT_LEVEL LOW
&END GLOBAL

&FORCE_EVAL
  METHOD Quickstep
  &DFT
    BASIS_SET_FILE_NAME ./BASIS_MOLOPT
    POTENTIAL_FILE_NAME ./GTH_POTENTIALS
    [CHARGE <N>]
    [&MULTIPLICITY <N> / &UKS]
    &MGRID
      CUTOFF <CUTOFF>
      REL_CUTOFF <REL_CUTOFF>
    &END MGRID
    &QS
      EPS_DEFAULT 1.0E-12
    &END QS
    &SCF
      SCF_GUESS ATOMIC
      EPS_SCF <EPS_SCF>
      MAX_SCF <MAX_SCF>
      &OT
        MINIMIZER CG
        PRECONDITIONER FULL_SINGLE_INVERSE
      &END OT
    &END SCF
    &XC
      &XC_FUNCTIONAL <FUNCTIONAL>
      &END XC_FUNCTIONAL
      &VDW_POTENTIAL
        POTENTIAL_TYPE PAIR_POTENTIAL
        &PAIR_POTENTIAL
          PARAMETER_FILE_NAME dftd3.dat
          TYPE DFTD3
          REFERENCE_FUNCTIONAL <FUNCTIONAL>
        &END PAIR_POTENTIAL
      &END VDW_POTENTIAL
    &END XC
  &END DFT
  &SUBSYS
    &CELL
      ABC <A> <B> <C>
    &END CELL
    &TOPOLOGY
      COORD_FILE_NAME <COORD_FILE>
      COORD_FILE_FORMAT XYZ
    &END TOPOLOGY
    &KIND <ELEM1>
      BASIS_SET <BASIS>
      POTENTIAL <POTENTIAL>
    &END KIND
    &KIND <ELEM2>
      BASIS_SET <BASIS>
      POTENTIAL <POTENTIAL>
    &END KIND
  &END SUBSYS
&END FORCE_EVAL

&MOTION
  &VIBRATIONAL_ANALYSIS
    NPROC_REP <NPROC_REP>
  &END VIBRATIONAL_ANALYSIS
&END MOTION
```

### Key Differences from Single-Point / Geo-Opt

| Setting | Geo-Opt | Single-Point | **Vibrational Analysis** |
|---|---|---|---|
| `RUN_TYPE` | `GEO_OPT` | `ENERGY` | **`VIBRATIONAL_ANALYSIS`** |
| `&MOTION` section | `&GEO_OPT` | **Omit** | **`&VIBRATIONAL_ANALYSIS`** |
| `EPS_SCF` | 1.0E-6 | 1.0E-7 | **1.0E-7** (accurate forces essential) |
| Runtime | Minutes | Minutes | Long (Hessian is expensive) |

## VIBRATIONAL_ANALYSIS Section

The `&VIBRATIONAL_ANALYSIS` section in `&MOTION` controls the frequency calculation:

```
&MOTION
  &VIBRATIONAL_ANALYSIS
    NPROC_REP <N>           ! Parallelization replicas (default: 1)
  &END VIBRATIONAL_ANALYSIS
&END MOTION
```

CP2K computes harmonic frequencies via finite differences of analytical gradients (same as VASP IBRION=5). It displaces each atom along ±x, ±y, ±z and computes the Hessian from the resulting force matrix.

**Important settings**:
- `NPROC_REP`: Number of replicas for parallel displacement calculations. Set to the number of MPI processes for maximum speedup.
- Vibrational analysis can be memory-intensive for large systems.

### SCF Convergence for Frequencies

Accurate forces require tight SCF convergence:

| Level | EPS_SCF | MAX_SCF |
|---|---|---|
| normal | 1.0E-6 | 50 |
| tight (default) | 1.0E-7 | 100 |
| verytight | 1.0E-8 | 200 |

## Functional, Basis, and Pseudopotential Compatibility

Same as `geo-opt-input` and `sp-energy-input`. Refer to `../geo-opt-input/SKILL.md` for full tables.

## Molecule-Type Specific Settings

Same SCF settings as `sp-energy-input`:
- `organic` — OT method, EPS_SCF 1.0E-7
- `transition-metal` — Diagonalization, UKS, smear, EPS_SCF 1.0E-7
- `charged` — OT + POISSON NONE, UKS as needed
- `bulk` — OT, coarse settings for screening

## Output Format

Produce the following for every request:

1. **Complete `.inp` file content** — ready to save and run.
2. **Filename suggestion** — `<name>-freq.inp`.
3. **Method summary** — functional, basis, vibrational analysis settings.
4. **Run command** — `mpirun -np <N> cp2k.popt <name>-freq.inp > <name>-freq.out` (parallel recommended).
5. **Required external files** — same as `geo-opt-input`:
   - `BASIS_MOLOPT`, `GTH_POTENTIALS`, `dftd3.dat`, coordinate file
6. **Follow-up note** — vibrational frequencies are printed in the output. No imaginary (negative) frequencies confirm a true minimum. IR intensities are computed automatically for each mode.

## Templates

Reference the template files in `../../shared/templates/`:
- `organic-freq.inp`
- `transition-metal-freq.inp`
- `charged-species-freq.inp`
- `bulk-freq.inp`

## Academic Quality Standards

- GTH pseudopotentials matching the chosen functional
- DFT-D3 dispersion correction always included
- EPS_SCF <= 1.0E-7 for accurate forces
- RUN_TYPE set to VIBRATIONAL_ANALYSIS
- OT method preferred (diagonalization only when justified)
- Basis set appropriate for system type
- Complete, self-contained input files
- No imaginary frequencies confirm a true minimum (1 imaginary = transition state)
