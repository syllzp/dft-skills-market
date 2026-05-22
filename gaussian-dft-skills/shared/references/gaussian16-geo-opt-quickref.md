# Gaussian 16 Geometry Optimization Quick Reference

## Route Section Keywords

| Keyword / Pattern | Purpose |
|---|---|
| `# <METHOD>/<BASIS> Opt` | Geometry optimization (default convergence) |
| `Opt=Tight` | Tight convergence criteria (recommended for publications) |
| `Opt=Loose` | Loose convergence (screening, pre-optimization) |
| `Opt=(Tight,MaxCycles=N)` | Tight convergence with custom max cycles |
| `scf=tight` | Tight SCF convergence (default for DFT in G16) |
| `scf=(xqc,tight)` | Extra-quadratic convergence for difficult SCF (transition metals, open-shell) |
| `scf=(tight,nosymm)` | Tight SCF without symmetry (charged species, floppy molecules) |
| `int=ultrafine` | Ultrafine integral grid (default for modern DFT in G16) |
| `int=superfine` | Superfine grid (Minnesota functionals: M06-2X, M06-L, etc.) |
| `int=(ultrafine,acc2e=12)` | Ultrafine grid with tighter 2e- integral accuracy (anions) |
| `empiricaldispersion=gd3bj` | Grimme D3 dispersion with Becke-Johnson damping |
| `scrf=(smd,solvent=<SOLVENT>)` | SMD solvation model |
| `Freq` | Frequency calculation (add to route for opt+freq) |
| `geom=(connectivity)` | Output connectivity information |
| `pop=none` | Suppress population analysis (speeds up large jobs) |

## Functional and Basis Set Recommendations

| System | Functional | Basis | Notes |
|---|---|---|---|
| Organic (closed-shell) | B3LYP | 6-31G(d) | Standard, cost-effective |
| Organic (publication) | B3LYP, PBE0 | 6-311+G(d,p) | Triple-zeta + diffuse + polarization |
| Organic (large, speed) | B3LYP | 3-21G | Fast pre-optimization |
| Transition metal (1st row) | PBE0, B3LYP | def2-TZVP | TZV quality, effective core potential available |
| Transition metal (heavy) | PBE0 | def2-TZVP + def2-ECP | ECP required for 2nd/3rd row |
| Anions | wB97XD, B3LYP | 6-311+G(d,p) | Diffuse functions essential |
| Cations | B3LYP, PBE0 | 6-31G(d) | Standard basis sufficient |
| Minnesota functionals | M06-2X | 6-311+G(d,p) | Must use int=superfine |

## Convergence Criteria

### Geometry Optimization (Opt)

| Level | Max Force | RMS Force | Max Displacement | RMS Displacement |
|---|---|---|---|---|
| Loose | 2.5e-3 | 1.7e-3 | 2.0e-2 | 1.0e-2 |
| Default (Opt) | 4.5e-4 | 3.0e-4 | 1.8e-3 | 1.2e-3 |
| Tight | 1.5e-5 | 1.0e-5 | 6.0e-5 | 4.0e-5 |
| VeryTight | 2.0e-6 | 1.0e-6 | 1.8e-6 | 1.2e-6 |

### SCF Convergence

| Level | RMS Density Matrix Change |
|---|---|
| Default (scf=conventional) | 1.0e-8 |
| Tight | 1.0e-10 |
| VeryTight | 1.0e-12 |

## % block Options

### Memory and Parallelization
```
%chk=<filename>.chk     # Checkpoint file (save wavefunction)
%mem=4GB                 # Dynamic memory allocation
%nprocshared=16          # Number of shared-memory processors
```

### SCF Options (optional %scf block)
```
%scf
  MaxCycle 500           # Maximum SCF iterations (default 128 for DFT)
  DirectAcc                # Direct SCF (disk-saving)
end
```

### Geometry Optimization Options
```
%geom
  MaxStep 30             # Max. step size (0.01 au default, 0.3 au max)
  Trust 0.1              # Trust radius
  Distance true          # Use distance matrix for initial guess
end
```

## Common Pitfalls

- **SCF convergence failures**: Add `scf=(xqc,tight)` or increase `MaxCycle` in `%scf`. Try `scf=(xqc,tight,novaracc)` if still failing.
- **Imaginary frequencies after opt**: Switch to `Opt=Tight` with `int=ultrafine` and re-optimize, or check if geometry is at a saddle point.
- **Linear dependencies**: Remove diffuse functions or use `5D 7F` to use cartesian d/f functions.
- **Anion SCF trouble**: Use `scf=(tight,nosymm)` with `int=(ultrafine,acc2e=12)` and a diffuse basis.
- **Transition metal SCF difficulty**: Use `scf=(xqc,tight)` with good initial guess. Consider `guess=mix` for open-shell cases.
- **High spin contamination**: Check `<S**2>` in output. If > expected + 0.1, consider broken symmetry or different functional.
- **Wrong charge/multiplicity**: Validate electron count parity. Even electrons → singlet (1), triplet (3), etc. Odd electrons → doublet (2), quartet (4), etc.
- **Disk space overflow**: Use `%rwf` to delete files during run, or add `NoSymm` to symmetry.

## Gaussian 16 Input File Template

```
%chk=jobname.chk
%mem=4GB
%nprocshared=16
# B3LYP/6-31G(d) Opt=Tight scf=tight int=ultrafine empiricaldispersion=gd3bj

Title line for job

0 1
C        0.0        0.0        0.0
C        0.0        0.0        1.4
H        0.0        1.0        2.0
          (blank line)
```

## References

- Gaussian 16 User's Reference: https://gaussian.com/manuals/
- Gaussian 16 Keywords: https://gaussian.com/keywords/
- F. Jensen, "Introduction to Computational Chemistry", 3rd Ed., Wiley (2017)
- J. B. Foresman, Æ. Frisch, "Exploring Chemistry with Electronic Structure Methods", 3rd Ed., Gaussian Inc. (2015)
- S. Grimme et al., J. Chem. Phys. 2010, 132, 154104 (D3 dispersion)
- A. V. Marenich et al., J. Phys. Chem. B 2009, 113, 6378 (SMD solvation)
