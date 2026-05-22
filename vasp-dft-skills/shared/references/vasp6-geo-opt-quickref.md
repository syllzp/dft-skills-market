# VASP 6.x Geometry Optimization Quick Reference

## Essential INCAR Tags

| Tag | Typical Value | Description |
|---|---|---|
| `PREC` | Normal / Accurate | Precision mode; Accurate recommended for final runs |
| `ENCUT` | 1.3 x max(ENMAX) | Plane-wave cutoff; check `grep ENMAX POTCAR` |
| `EDIFF` | 1E-5 | Electronic convergence (eV); 1E-6 for precise work |
| `EDIFFG` | -0.01 / -0.02 | Ionic force convergence (eV/A); negative = RMS force |
| `IBRION` | 1 (RMM-DIIS), 2 (CG) | Ionic relaxation algorithm |
| `ISIF` | 2 (ions only), 3 (ions+cell) | Stress/optimization control |
| `NSW` | 100-200 | Maximum number of ionic steps |
| `ISMEAR` | 0 (Gaussian), 1 (MP), -5 (tetra) | Smearing method |
| `SIGMA` | 0.05 (insulator), 0.20 (metal) | Smearing width (eV) |
| `LREAL` | Auto | Real-space projection for large systems |
| `ISPIN` | 1 (none), 2 (spin-polarized) | Spin polarization |
| `MAGMOM` | per-atom values | Initial magnetic moments (ISPIN=2 only) |
| `IVDW` | 11 (D3-zero), 12 (D3-BJ) | Dispersion correction |
| `LASPH` | .TRUE. | Non-spherical corrections (improves forces) |
| `LWAVE` | .FALSE. | Suppress WAVECAR output |
| `LCHARG` | .FALSE. | Suppress CHGCAR output |

## Functional / POTCAR Mapping

| Functional | POTCAR Directory | Notes |
|---|---|---|
| PBE | PBE_54 | Default GGA; widely applicable |
| PBEsol | PBE_54 | Select "Pb" variants in POTCAR |
| SCAN | SCAN_54 | meta-GGA; use SCAN pseudopotentials |
| HSE06 | PBE_54 | Hybrid; set LHFCALC=.TRUE., AEXX=0.25 |
| PBE0 | PBE_54 | Hybrid; set LHFCALC=.TRUE., AEXX=0.25 |
| RPBE | PBE_54 | RPBE pseudopotentials |
| optB88-vdW | PBE_54 | Set GGA = BO; requires non-local vdW kernel |
| rev-vdW-DF2 | PBE_54 | Set GGA = MK; requires non-local vdW kernel |

POTCAR files are grouped by functional family. Mixing families (e.g., PBE POTCAR with SCAN functional) will give wrong results.

## Generating POTCAR

```bash
# Using VASPKIT (recommended)
vaspkit -task 103
# Select functional family, then elements

# Manual concatenation
cat ~/potpaw_PBE_54/POTCAR_A ~/potpaw_PBE_54/POTCAR_B > POTCAR

# Validate
grep -E "TITEL|ENMAX|VRHFIN" POTCAR
```

## Convergence Criteria

| Level | EDIFF (eV) | EDIFFG (eV/A) | Use Case |
|---|---|---|---|
| Quick | 1E-4 | -0.05 | Pre-relaxation, screening |
| Normal | 1E-5 | -0.02 | Standard calculations |
| Production | 1E-5 | -0.01 | Publication quality |
| Precise | 1E-6 | -0.005 | High-accuracy benchmarks |

After each ionic step, VASP checks:
- RMS force < EDIFFG in eV/A (when EDIFFG < 0)
- OR energy change < |EDIFFG| (when EDIFFG > 0)

## Algorithm Recommendations

| System | IBRION | NSW | Notes |
|---|---|---|---|
| Organic molecule (gas) | 2 (CG) | 100 | Robust for general use |
| Metal cluster | 2 (CG) | 100 | Good potential surface |
| Bulk crystal | 2 (CG) | 100-200 | Slow convergence near minimum |
| Surface slab | 2 (CG) | 100-200 | Many soft modes possible |
| Quick pre-relaxation | 1 (DIIS) | 50 | Fast but less robust |
| Unstable starting geometry | 3 (damped MD) | 200 | Most stable for bad guesses |

## K-Point Convergence

```bash
# Target spacing: 0.03-0.05 A^-1 for production
# 0.05-0.08 A^-1 for screening

# Calculate from lattice vectors:
# N_i = ceil(2*pi / (spacing * |b_i|))
# where b_i = reciprocal lattice vectors
```

| System | Mesh | Method |
|---|---|---|
| Molecule or cluster in box | 1 1 1 | Gamma |
| Bulk (3D), len ~ 4-6 A | 9x9x9 -> 11x11x11 | Gamma-centered |
| Bulk (3D), len ~ 8-12 A | 5x5x5 -> 7x7x7 | Gamma-centered |
| Surface slab | Nx x Ny x 1 | Gamma (z = 1 only) |
| 1D (nanotube, wire) | 1 x 1 x Nz | Gamma |

## Common Pitfalls

- **POTCAR mismatch**: POTCAR files must match the functional used. Mixing PBE pseudopotentials with SCAN will produce wrong results.
- **POTCAR order**: POTCAR species must be concatenated in the exact order they appear in POSCAR.
- **ISIF=3 for molecules**: Never use ISIF=3 for molecules in a box; the cell will distort. Use ISIF=2.
- **Too small box**: Molecules need at least 10-12 A of vacuum in each direction to avoid periodic interactions.
- **Insufficient ENCUT**: Defaults from POTCAR ENMIN are too low. Always scale by at least 1.3.
- **Push-pull of conjugate gradient**: IBRION=2 (CG) can oscillate near minimum. Check OUTCAR for oscillations.
- **Empty bands**: If insufficient empty bands, optical properties and hybrid calculations may fail.
- **Symmetry issues**: VASP uses symmetry by default. For molecules in boxes, symmetry can cause issues. Use `ISYM = 0` or `ISYM = 2` carefully.
- **Entropy check**: After convergence with ISMEAR=1, check that EENTRO < 1 meV/atom in OUTCAR.
- **NSW not reached**: If the optimization stops at exactly NSW steps, the geometry may not be converged. Increase NSW or check forces.
- **Spin contamination**: For spin-polarized systems, check `<S^2>` or the spin moment in OUTCAR.

## Typical Workflow

```
1. Build initial structure (POSCAR)
   └── Use Avogadro, ASE, or experimental CIF/aflow

2. Select functional and generate POTCAR
   └── vaspkit -task 103

3. Set INCAR parameters
   └── ENCUT, EDIFF, EDIFFG, IBRION, ISIF, ISMEAR, SIGMA

4. Choose KPOINTS
   └── Gamma-only for isolated systems; converged mesh for periodic

5. Submit calculation
   └── sbatch submit.slurm

6. Check convergence in OUTCAR
   └── "reached required accuracy" + EENTRO < 1 meV/atom

7. Post-processing
   └── vaspkit, VASPKIT, pymatgen, or manual OUTCAR parsing
```

## Example INCAR Production Template

```
# VASP 6.x input file -- generated for academic use
PREC = Normal
ENCUT = 520
EDIFF = 1E-5
EDIFFG = -0.01
IBRION = 2
ISIF = 2
NSW = 100
ISMEAR = 1
SIGMA = 0.20
LREAL = Auto
ISPIN = 2
MAGMOM = 5.0 5.0 5.0 5.0
LORBIT = 11
IVDW = 12
LASPH = .TRUE.
LWAVE = .FALSE.
LCHARG = .FALSE.
```

## References

- VASP Wiki (official documentation): https://www.vasp.at/wiki/
- VASP 6.3.0 Release Notes: https://www.vasp.at/wiki/index.php/VASP_6.3.0
- VASPKIT toolkit: https://vaspkit.com/
- Materials Project (pseudopotential recommendations): https://docs.materialsproject.org/methodology/pseudopotentials
- Sun et al., "The VASP Guide", npj Comput. Mater. 2021
- Kresse & Furthmuller, Phys. Rev. B 54, 11169 (1996)
- Kresse & Joubert, Phys. Rev. B 59, 1758 (1999)
