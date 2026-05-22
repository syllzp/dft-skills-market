# Quantum ESPRESSO 7.x Geometry Optimization Quick Reference

## Input Namelist & Card Summary

| Section | Purpose |
|---|---|
| `&CONTROL` | Job control: calculation type, directories, verbosity, convergence |
| `&SYSTEM` | System parameters: lattice, species, cutoffs, smearing, spin, U |
| `&ELECTRONS` | SCF control: mixing, threshold, diagonalization |
| `&IONS` | Ion dynamics: BFGS, damped MD, convergence |
| `&CELL` | Cell dynamics: variable-cell relaxation control |
| `ATOMIC_SPECIES` | Element, atomic mass, pseudopotential file |
| `ATOMIC_POSITIONS` | Atom labels and coordinates |
| `K_POINTS` | k-point mesh or list |

### Key `&CONTROL` Keywords

| Keyword | Default | Description |
|---|---|---|
| `calculation` | `'scf'` | `'relax'` (ion relaxation), `'vc-relax'` (cell+ion), `'scf'` |
| `prefix` | `'pwscf'` | Output file prefix |
| `outdir` | `'./'` | Working directory for temporary files |
| `pseudo_dir` | `'./'` | Pseudopotential directory |
| `verbosity` | `'low'` | `'high'` for detailed output |
| `etot_conv_thr` | 1.0D-4 | Energy convergence (Ry) for relaxation |
| `forc_conv_thr` | 1.0D-3 | Force convergence (Ry/Bohr) for relaxation |
| `nstep` | 50/100 | Max ionic steps (200 for relax, 50 for vc-relax) |

### Key `&SYSTEM` Keywords

| Keyword | Description |
|---|---|
| `ibrav` | Bravais lattice index (0 = user-supplied cell vectors) |
| `nat` | Total number of atoms |
| `ntyp` | Number of atomic species |
| `ecutwfc` | Wavefunction cutoff energy (Ry) |
| `ecutrho` | Charge density/potential cutoff (Ry) |
| `occupations` | `'smearing'`, `'fixed'`, `'tetrahedra'` |
| `smearing` | `'marzari-vanderbilt'`, `'gaussian'`, `'cold'`, `'methfessel-paxton'` |
| `degauss` | Gaussian broadening (Ry) |
| `vdw_corr` | Van der Waals correction: `'DFT-D3'`, `'dftd3'`, `'none'` |
| `tot_charge` | Total charge of the system |
| `nspin` | 1 (non-magnetic), 2 (collinear spin) |
| `starting_magnetization(i)` | Initial magnetization for species i |
| `lda_plus_u` | Enable LDA+U (`.true.` / `.false.`) |
| `Hubbard_U(i)` | U value (eV) for species i |
| `input_dft` | Override XC functional (`'PBE'`, `'PBEsol'`, `'SCAN'`, `'HSE06'`) |

### Key `&ELECTRONS` Keywords

| Keyword | Default | Description |
|---|---|---|
| `conv_thr` | 1.0D-6 | SCF convergence threshold (Ry) |
| `mixing_beta` | 0.7 | Charge density mixing parameter |
| `mixing_mode` | `'plain'` | `'plain'`, `'TF'`, `'local-TF'` |
| `electron_maxstep` | 100 | Max SCF iterations |
| `diagonalization` | `'david'` | `'david'` (Davidson), `'cg'` (conjugate gradient) |
| `diago_thr_init` | 1.0D-2 | Initial diagonalization threshold |

### Key `&IONS` / `&CELL` Keywords

| Keyword | Default | Description |
|---|---|---|
| `ion_dynamics` | `'damp'` | `'bfgs'` (recommended), `'damp'`, `'verlet'` |
| `upscale` | 100 | BFGS scaling factor for trust radius |
| `cell_dynamics` | `'damp'` | `'bfgs'`, `'damp'` |
| `cell_dofree` | `'all'` | `'all'`, `'xyz'`, `'volume'`, `'z'` etc. |
| `press` | 0.0 | External pressure (kbar) |

## Functional Recommendations

| System | Functional | Pseudopotential | Notes |
|---|---|---|---|
| Organic molecules | PBE-D3 | SSSP-PBE (efficiency) | Good geometries, cheap |
| Organic (accuracy) | SCAN | SSSP-SCAN | Superior for non-covalent |
| Bulk crystals (lattice) | PBEsol | SSSP-PBEsol | Best for solids |
| Bulk (accuracy) | SCAN | SSSP-SCAN | Meta-GGA quality |
| Transition metal oxides | PBE+U | SSSP-PBE | Add Hubbard U (3–6 eV) |
| Surfaces / adsorption | PBE-D3 | SSSP-PBE | DFT-D3 essential |
| Band gaps | HSE06 | SSSP-PBE | Hybrid, expensive |
| vdW-dominated systems | vdW-DF2 (B86bPBE) | SSSP-PBE | Non-local vdW functional |

## Pseudopotential Sources

| Library | Type | Coverage | Recommendation |
|---|---|---|---|
| **SSSP (efficiency)** | PS (ultrasoft) | All elements up to Rn | **Default** — pre-verified, optimal balance |
| **SSSP (precision)** | NC (norm-conserving) | Most elements | Higher accuracy, more expensive |
| **SG15** (ONCV) | NC | Most elements | Good for band structures, Wannier |
| **GBRV** | US | sp elements, some TM | Fast, less accurate |
| **PSLibrary** | US | Full periodic table | Legacy, being superseded by SSSP |
| **Dojo** | NC | Wide coverage | Good for high-throughput |

- SSSP library: https://www.materialscloud.org/discover/sssp/
- SG15 (ONCV): http://www.quantum-simulation.org/potentials/sg15_oncv/
- Pseudopotential generation: `ld1.x` (included in QE)

## Convergence Criteria for Relaxation

| Level | `conv_thr` (SCF) | `etot_conv_thr` | `forc_conv_thr` |
|---|---|---|---|
| Quick screening | 1.0D-5 | 1.0D-4 | 1.0D-3 |
| Standard (default) | 1.0D-6 | 1.0D-5 | 1.0D-4 |
| Tight (frequencies) | 1.0D-7 | 1.0D-6 | 5.0D-5 |
| Very tight (benchmark) | 1.0D-8 | 1.0D-7 | 1.0D-5 |

## Common Pitfalls

1. **SCF does not converge**
   - Reduce `mixing_beta` (try 0.3 or 0.1).
   - Switch to `mixing_mode = 'local-TF'`.
   - Increase `electron_maxstep` to 300–500.
   - Try `diagonalization = 'cg'` if Davidson fails.
   - Add `startingpot = 'atomic'` in `&SYSTEM`.

2. **Relaxation oscillates / does not converge**
   - Ensure initial Hessian is reasonable (start from good geometry).
   - Reduce `upscale` in `&IONS` (try 10–50).
   - Use tighter SCF convergence (`conv_thr = 1.D-8`).
   - Switch to `ion_dynamics = 'damp'` as fallback.

3. **Forces not converging**
   - Increase `ecutwfc` by 20–30%.
   - Add more k-points.
   - Check pseudopotential consistency with functional.

4. **VC-relax breaks symmetry**
   - Use `cell_dofree = 'xyz'` to constrain cell shape.
   - Start from a well-converged `scf` calculation.
   - Use `ibrav` with proper lattice type instead of 0.

5. **Unphysical geometry (bonds too short/long)**
   - Verify pseudopotentials are correct for the functional.
   - Check that `vdw_corr` is appropriate.
   - For transition metals, add LDA+U.
   - Check spin state (nspin=2, starting_magnetization).

6. **Negative frequencies in phonon calculation**
   - Relax to tighter criteria (`forc_conv_thr = 1.D-5`).
   - Ensure true minimum, not saddle point.
   - Increase k-point density.

7. **Memory / disk issues**
   - Reduce `outdir` disk usage: `disk_io = 'low'` in `&CONTROL`.
   - Use a smaller `ecutrho` (minimum 4× ecutwfc).
   - Reduce k-points or use symmetry (`nosym = .false.`).

## Post-Processing Notes

- **Total energy**: Check `!    total energy              =` in stdout.
- **Forces**: Check `Forces acting on atoms` section.
- **Final structure**: Output in `ATOMIC_POSITIONS` format in stdout.
- **Convergence check**: Verify `convergence has been achieved` in output.
- **Next step**: Single-point (scf), band structure (bands.x), or phonon (ph.x).

## References

- P. Giannozzi et al., *J. Phys.: Condens. Matter* **21**, 395502 (2009) — QE initial paper.
- P. Giannozzi et al., *J. Phys.: Condens. Matter* **29**, 465901 (2017) — QE 6.x update.
- QE 7.x User Manual: https://www.quantum-espresso.org/Doc/user_guide/
- QE Input Documentation: https://www.quantum-espresso.org/Doc/INPUT_PW.html
- SSSP Library: G. Prandini et al., *npj Comput. Mater.* **4**, 72 (2018).
- SSSP Precision Benchmark: G. Prandini et al., *J. Chem. Theory Comput.* **15**, 6857 (2019).
- SG15 Pseudopotentials: K. Lejaeghere et al., *Nature* **546**, 109 (2017) (Delta benchmark).
- D3 Dispersion: S. Grimme et al., *J. Chem. Phys.* **132**, 154104 (2010).
- LDA+U: V. I. Anisimov et al., *Phys. Rev. B* **44**, 943 (1991).
- Theochem SCAN: J. Sun et al., *Phys. Rev. Lett.* **115**, 036402 (2015).
