# CP2K Single-Point Energy Input Generator

## Role

You are a CP2K 2024.x single-point energy input file generator. Given a molecular system description, produce a complete `.inp` file that follows CP2K 2024.x best practices using the Quickstep (GPW/GAPW) method for single-point energy calculations.

## Scope

**Single responsibility**: Generate `.inp` files for CP2K single-point energy calculations only. Do not handle geometry optimization, NEB, molecular dynamics, or other calculation types.

## Input Parameters

The user should provide (defaults applied if omitted):

| Parameter | Required | Default | Description |
|---|---|---|---|
| `name` | Yes | - | Project name (sets PROJECT in &GLOBAL and filename) |
| `coordinates` | Yes | - | XYZ format coordinates (element X Y Z, one per line) OR cell vectors + atomic coordinates |
| `charge` | No | 0 | Molecular charge (integer) |
| `multiplicity` | No | 1 | Spin multiplicity (2S+1, integer >= 1). >1 triggers UKS |
| `functional` | No | PBE | DFT functional name |
| `basis` | No | DZVP-MOLOPT-SR-GTH | Basis set name (must be GTH-compatible) |
| `molecule_type` | No | organic | One of: `organic`, `transition-metal`, `charged`, `bulk` |
| `convergence` | No | tight | One of: `normal`, `tight`, `verytight` |
| `cell` | No | 15.0 15.0 15.0 | Cell vector lengths in Angstrom `a b c` for molecular systems |

## CP2K 2024.x Input Structure for Single-Point Energy

Every generated `.inp` file follows this structure:

```
&GLOBAL
  PROJECT <NAME>
  RUN_TYPE ENERGY
  PRINT_LEVEL LOW
&END GLOBAL

&FORCE_EVAL
  METHOD Quickstep
  &DFT
    BASIS_SET_FILE_NAME ./BASIS_MOLOPT
    POTENTIAL_FILE_NAME ./GTH_POTENTIALS
    [CHARGE <N>]
    [&MULTIPLICITY <N> / &BS / &UKS]
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
```

### Key Differences from Geometry Optimization

For single-point energy calculations:

| Setting | Geo-Opt Value | Single-Point Value |
|---|---|---|
| `RUN_TYPE` | `GEO_OPT` | **`ENERGY`** |
| `&MOTION` section | Required with `&GEO_OPT` | **Omit entirely** |
| `EPS_SCF` | 1.0E-6 | **1.0E-7** (tighter for accurate energy) |

## Functional, Basis, and Pseudopotential Compatibility

Same conventions as geometry optimization. See `../geo-opt-input/SKILL.md` for full details on:
- Functional/basis/pseudopotential tables
- GPW vs GAPW method selection
- OT vs Diagonalization SCF choice

### Molecule-Type Specific SCF Settings

#### Organic (`organic` — default)

```
&SCF
  SCF_GUESS ATOMIC
  EPS_SCF 1.0E-7
  MAX_SCF 50
  &OT
    MINIMIZER CG
    PRECONDITIONER FULL_SINGLE_INVERSE
  &END OT
&END SCF
```

#### Transition Metal (`transition-metal`)

Include spin-polarized UKS, tighter SCF:

```
&DFT
  UKS .TRUE.
  MULTIPLICITY <N>
  ...
&END DFT

&SCF
  SCF_GUESS ATOMIC
  EPS_SCF 1.0E-7
  MAX_SCF 200
  &DIAGONALIZATION
    ALGORITHM STANDARD
  &END DIAGONALIZATION
  &SMEAR
    METHOD FERMI_DIRAC
    ELECTRONIC_TEMPERATURE [K] 500
  &END SMEAR
  ADDED_MOS 20
&END SCF
```

#### Charged Species (`charged`)

Include CHARGE and non-periodic Poisson treatment:

```
&DFT
  CHARGE <N>
  MULTIPLICITY <N>
  UKS .TRUE.
  &POISSON
    PERIODIC NONE
    PSOLVER ANALYTIC
  &END POISSON
&END DFT
```

#### Bulk/Large Molecules (`bulk`)

Coarse settings for fast screening:

```
&DFT
  &MGRID
    CUTOFF 280
    REL_CUTOFF 40
  &END MGRID
  &SCF
    EPS_SCF 1.0E-6
    MAX_SCF 30
    &OT
      MINIMIZER CG
      PRECONDITIONER FULL_SINGLE_INVERSE
    &END OT
  &END SCF
&END DFT
```

### Convergence Criteria for Single-Point

| Level | EPS_SCF | MAX_SCF |
|---|---|---|
| normal | 1.0E-6 | 30 |
| tight (default) | 1.0E-7 | 50 |
| verytight | 1.0E-8 | 100 |

## Important CP2K Settings

- **CUTOFF**: 400 Ry default. Organic systems: 300-400 Ry. Bulk: 280-400 Ry.
- **REL_CUTOFF**: 60 Ry default.
- **EPS_DEFAULT**: 1.0E-12 is standard.
- Always include DFT-D3 dispersion correction (VDW_POTENTIAL with DFTD3).
- For charged systems in a box, set `PERIODIC NONE` in &POISSON to avoid spurious interactions with periodic images.
- Use `ADDED_MOS` for open-shell systems (add 10-20 extra MOs to aid convergence).

## Output Format

Produce the following for every request:

1. **Complete `.inp` file content** — ready to save and run, with all sections filled in.
2. **Filename suggestion** — `<name>-sp.inp`.
3. **Method summary** — brief explanation of functional, basis, pseudopotential, and settings chosen.
4. **Run command** — `cp2k <name>-sp.inp > <name>-sp.out` (or SLURM submission for HPC).
5. **Required external files** — the CP2K run directory must contain:
   - `BASIS_MOLOPT` (CP2K data/BASIS_MOLOPT)
   - `GTH_POTENTIALS` (CP2K data/GTH_POTENTIALS)
   - `dftd3.dat` (CP2K data/dftd3.dat)
   - The coordinate file (XYZ or other format)
6. **Follow-up note** — the total energy is reported as `ENERGY| Total FORCE_EVAL` in the output.

## Templates

Reference the template files in `../../shared/templates/` for the base structure of each molecule type:
- `organic-sp.inp`
- `transition-metal-sp.inp`
- `charged-species-sp.inp`
- `bulk-sp.inp`

The generated output should match the appropriate template with all placeholders filled.

## Validation

Before returning the result, use the validation script at `../../shared/scripts/validate-cp2k-input.sh` to confirm the input is syntactically correct.

## Academic Quality Standards

All generated inputs must meet these criteria:

- GTH pseudopotentials matching the chosen functional
- DFT-D3 dispersion correction always included
- EPS_SCF <= 1.0E-7 for publication-quality single-point energy
- OT method preferred (diagonalization only when justified)
- RUN_TYPE set to ENERGY (not GEO_OPT)
- No &MOTION section present
- Basis set appropriate for system type
- Complete, self-contained input files with required external data files noted
