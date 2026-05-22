# CP2K 2024.x Geometry Optimization Quick Reference

## Input Section Overview

| Section | Purpose |
|---|---|
| `&GLOBAL` | Job configuration: project name, run type, print level |
| `&FORCE_EVAL` | Main calculation settings: method, DFT, subsystem |
| `&DFT` | DFT parameters: functional, basis sets, pseudopotentials, SCF |
| `&MGRID` | Multigrid settings: CUTOFF, REL_CUTOFF (key accuracy/speed knobs) |
| `&QS` | Quickstep settings: EPS_DEFAULT |
| `&SCF` | SCF control: solver, convergence thresholds, guess, max iterations |
| `&OT` | Orbital Transformation solver (recommended for most systems) |
| `&XC` | Exchange-correlation: functional and VDW correction |
| `&POISSON` | Electrostatic solver: periodic/non-periodic treatment |
| `&SUBSYS` | System definition: cell, topology, atomic kinds |
| `&CELL` | Periodic cell vectors |
| `&TOPOLOGY` | Coordinate file specification |
| `&KIND` | Element-specific basis set and pseudopotential |
| `&MOTION` | Geometry optimization or MD settings |
| `&GEO_OPT` | Geometry optimization parameters |

## Functional / Basis / Pseudopotential Compatibility

| Functional | Pseudopotential | Recommended Basis | Notes |
|---|---|---|---|
| PBE | GTH-PBE | DZVP-MOLOPT-SR-GTH | Default GGA, best general purpose |
| BLYP | GTH-BLYP | DZVP-MOLOPT-SR-GTH | Good for H-bonded systems |
| B3LYP | GTH-BLYP | DZVP-MOLOPT-SR-GTH | Hybrid; OT needs FULL_KINETIC precond |
| PBE0 | GTH-PBE | DZVP-MOLOPT-SR-GTH | Hybrid; same preconditioner note |
| SCAN | GTH-SCAN | DZVP-MOLOPT-SR-GTH | Meta-GGA; GAPW method recommended |
| r2SCAN | GTH-r2SCAN | TZVP-MOLOPT-GTH | Meta-GGA; improved stability |
| TPSS | GTH-TPSS | DZVP-MOLOPT-SR-GTH | Meta-GGA |
| HSE06 | GTH-PBE | DZVP-MOLOPT-SR-GTH | Range-separated hybrid |

**Basis sets** (CP2K MOLOPT family):
- `DZVP-MOLOPT-SR-GTH` — default double-zeta, short-range optimized
- `DZVP-MOLOPT-GTH` — double-zeta, standard (larger than SR)
- `TZVP-MOLOPT-GTH` — triple-zeta, high accuracy
- `TZV2P-MOLOPT-GTH` — triple-zeta with extra polarization
- `QZVP-MOLOPT-GTH` — quadruple-zeta, highest accuracy

## GPW vs GAPW Method Selection

| Method | Setting | Use Case |
|---|---|---|
| **GPW** | `METHOD GPW` | Default. Pseudopotential + PW expansion of density. Fast. |
| **GAPW** | `METHOD GAPW` | All-electron calculations. Core spectroscopy. Meta-GGAs (SCAN) with all-electron treatment. Slower. |

Rule of thumb: Use GPW unless you need all-electron results.

## OT vs Diagonalization SCF

| Solver | When to Use |
|---|---|
| **OT** (Orbital Transformation) | **Default.** Closed-shell organics, semiconductors, insulators. Faster. Not for metallic systems. |
| **Diagonalization** | Metallic systems, small gap, charged periodic cells, magnetic systems where OT fails. Use `&DIAGONALIZATION` or `ALMO_SCF`. |

### OT Settings

```
&OT
  MINIMIZER CG          # Conjugate gradient (default, robust)
  # OR MINIMIZER DIIS   # Direct inversion, faster when close to convergence
  PRECONDITIONER FULL_SINGLE_INVERSE  # Default, for GGAs and meta-GGAs
  # OR PRECONDITIONER FULL_KINETIC    # For hybrid functionals
  ENERGY_GAP 0.1        # Gap estimate for OT preconditioner (eV)
&END OT
```

### Diagonalization Settings

```
&SCF
  &DIAGONALIZATION
    ALGORITHM STANDARD   # or JACOBI
  &END DIAGONALIZATION
  &SMEAR
    METHOD FERMI_DIRAC
    ELECTRONIC_TEMPERATURE [K] 500
  &END SMEAR
  ADDED_MOS 20           # Extra MOs for convergence
&END SCF
```

## Convergence Criteria

### SCF Convergence

| Level | EPS_SCF | MAX_SCF | Notes |
|---|---|---|---|
| Normal | 1.0E-5 | 30 | Screening only |
| Tight (default) | 1.0E-6 | 50 | Publication quality |
| Very tight | 1.0E-7 | 100 | High accuracy |

### Geometry Optimization Convergence (GEO_OPT)

| Level | MAX_FORCE (Eh/bohr) | RMS_FORCE (Eh/bohr) | MAX_DR (bohr) | RMS_DR (bohr) | MAX_ITER |
|---|---|---|---|---|---|
| Normal | 1.0E-3 | 5.0E-4 | 3.0E-3 | 1.5E-3 | 50 |
| Tight | 4.5E-4 | 3.0E-4 | 3.0E-3 | 1.5E-3 | 100 |
| Very tight | 1.5E-4 | 1.0E-4 | 1.0E-3 | 5.0E-4 | 200 |

### CP2K keywords for GEO_OPT convergence:

```
&GEO_OPT
  MAX_ITER     100       # Maximum geometry optimization steps
  MAX_FORCE    4.5E-4    # Max force component (tight)
  RMS_FORCE    3.0E-4    # RMS force (tight)
  MAX_DR       3.0E-3    # Max atomic displacement (tight)
  RMS_DR       1.5E-3    # RMS atomic displacement (tight)
  OPTIMIZER    BFGS      # BFGS (default), CG, or LBFGS
&END GEO_OPT
```

## MGRID Settings

```
&MGRID
  CUTOFF 400          # PW cutoff in Ry (300-600 typical)
  REL_CUTOFF 60       # Relative cutoff in Ry (40-80 typical)
  NGRIDS 5            # Number of multigrids (auto if not set)
&END MGRID
```

CUTOFF guidelines:
- 280-300 Ry: Quick pre-optimization
- 400 Ry: Standard accuracy (default)
- 500-600 Ry: High accuracy, sensitive properties
- Above 600 Ry: Rarely needed with pseudopotentials

## DFT-D3 Dispersion

Always include DFT-D3 dispersion for molecular systems:

```
&XC
  &XC_FUNCTIONAL PBE
  &END XC_FUNCTIONAL
  &VDW_POTENTIAL
    POTENTIAL_TYPE PAIR_POTENTIAL
    &PAIR_POTENTIAL
      PARAMETER_FILE_NAME dftd3.dat
      TYPE DFTD3
      REFERENCE_FUNCTIONAL PBE
    &END PAIR_POTENTIAL
  &END VDW_POTENTIAL
&END XC
```

The `REFERENCE_FUNCTIONAL` must match the main xc functional. The `dftd3.dat` parameter file ships with CP2K (in `data/`).

## Common Pitfalls

| Problem | Symptoms | Solution |
|---|---|---|
| **SCF not converging** | SCF cycles hit MAX_SCF | Try OT method. If OT fails, switch to diagonalization with SMEAR. Increase MAX_SCF. |
| **OT convergence failure** | OT not converging | Use `MINIMIZER DIIS`, adjust `ENERGY_GAP`, or switch to diagonalization. |
| **Geo opt not converging** | GEO_OPT cycles hit MAX_ITER | Longer MAX_ITER. Check if SCF is converged tightly enough. Try CG optimizer. |
| **Wrong multiplicity** | High-spin vs low-spin energy ordering | Check UKS, MULTIPLICITY, and initial guess. Use RESTART for problematic cases. |
| **Charged system errors** | Large energy oscillations or SCF fails | Add `&POISSON PERIODIC NONE`. Increase cell size. |
| **Linear dependencies in basis** | Warning about linear dependencies | Remove diffuse basis functions or use `&BS` section. |
| **Cell too small** | Energy changes dramatically | Increase cell by 2-3 Angstrom for molecular systems. |
| **Missing external files** | CP2K crashes on startup | Ensure BASIS_MOLOPT, GTH_POTENTIALS, dftd3.dat are in run directory. |
| **Imaginary frequencies** | Not a true minimum | Re-optimize with tighter SCF, then run vibrational analysis. |

## Required External Data Files

Every CP2K run requires these files in the working directory (symlink from `$CP2K_DATA_DIR`):

- `BASIS_MOLOPT` — Molecularly optimized basis sets (GTH)
- `GTH_POTENTIALS` — Goedecker-Teter-Hutter pseudopotentials
- `dftd3.dat` — DFT-D3 dispersion parameters (only needed with VDW_POTENTIAL)

Standard location: `$CP2K_ROOT/data/`

## Run Commands

```bash
# Serial
cp2k input.inp > input.out

# MPI parallel
mpirun -np 8 cp2k.popt input.inp > input.out

# OpenMP parallel (hybrid)
export OMP_NUM_THREADS=2
mpirun -np 4 cp2k.psmp input.inp > input.out

# GPU acceleration (CUDA)
mpirun -np 4 cp2k.popt input.inp > input.out   # with CP2K compiled with CUDA
```

## References

- CP2K Official Documentation: https://manual.cp2k.org/
- CP2K 2024.x Release Notes: https://www.cp2k.org/2024-1
- Goedecker, Teter, Hutter, Phys. Rev. B 54, 1703 (1996) — GTH pseudopotentials
- VandeVondele et al., J. Chem. Phys. 122, 014101 (2005) — Quickstep method
- Grimme et al., J. Chem. Phys. 132, 154104 (2010) — DFT-D3 dispersion
- Perdew, Burke, Ernzerhof, Phys. Rev. Lett. 77, 3865 (1996) — PBE functional
- CP2K Input Reference: https://manual.cp2k.org/trunk/CP2K_INPUT.html
