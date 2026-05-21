# ORCA 5+ Geometry Optimization Quick Reference

## Keyword Summary

| Keyword | Purpose |
|---|---|
| `Opt` | Trigger geometry optimization |
| `TightOpt` | Tight convergence (recommended for publications) |
| `VeryTightOpt` | Very tight convergence (benchmarks, spectroscopy) |
| `D3BJ` | Grimme D3 dispersion with Becke-Johnson damping |
| `RIJCOSX` | RI approximation with COSX (hybrids, ORCA 5+ default) |
| `RIJ` | RI approximation for Coulomb only (GGAs) |
| `DefGrid2` | Standard integration grid (ORCA 5+ default) |
| `DefGrid3` | Fine grid (Minnesota functionals, heavy elements, anions) |
| `TightSCF` | Tight SCF convergence (required for clean gradients) |

## Functional and Basis Set Recommendations

| System | Functional | Basis | Notes |
|---|---|---|---|
| Organic (closed-shell) | B3LYP, PBE0 | def2-TZVP | Standard publication quality |
| Organic (large, speed) | BP86 | def2-SVP | GGA + RIJ, fast pre-optimization |
| Transition metal (1st row) | PBE0, TPSS | def2-TZVP | Tight SCF essential |
| Transition metal (heavy) | PBE0 | def2-TZVP + def2-ECP | ECP required for 2nd/3rd row |
| Anions | wB97X-D, B3LYP | def2-TZVPD, def2-SVPD | Diffuse functions essential |
| Cations | B3LYP, PBE0 | def2-TZVP | Standard basis sufficient |
| Minnesota (M06-2X, etc.) | M06-2X | def2-TZVP | Must use DefGrid3 |

## Grid Settings

| Grid | Use Case |
|---|---|
| `DefGrid2` | Default -- most optimizations |
| `DefGrid3` | Minnesota functionals, heavy elements (3rd row+), anions, imaginary frequency noise |
| `Grid5` | ORCA 4.x compatibility (equivalent to DefGrid2) |

## Convergence Criteria

| Level | Energy (Eh) | RMS Grad | Max Grad | RMS Disp | Max Disp |
|---|---|---|---|---|---|
| NormalOpt (default) | 5e-6 | 1e-4 | 3e-4 | 2e-3 | 4e-3 |
| TightOpt | 1e-6 | 3e-5 | 1e-4 | 6e-4 | 1e-3 |
| VeryTightOpt | 1e-7 | 1e-5 | 3e-5 | 2e-4 | 4e-4 |

## %geom Block Options

```
%geom
  Calc_Hess true          # Calculate exact initial Hessian (recommended)
  Recalc_Hess N           # Recalculate Hessian every N steps (3-10)
  IntraCoord true         # Redundant internal coordinates (default)
  MaxIter N               # Maximum optimization cycles (default 200)
  Constraints             # Optional: freeze bonds, angles, dihedrals
    {B 0 1 C}             # Fix bond between atoms 0 and 1
    {A 0 1 2 C}           # Fix angle
    {D 0 1 2 3 C}         # Fix dihedral
  end
end
```

## Common Pitfalls

- **SCF convergence failures**: Increase `MaxIter` in %scf, try `smear` or `levelshift`
- **Imaginary frequencies after opt**: Re-optimize with `VeryTightOpt` or `DefGrid3`
- **Flat potential energy surface**: Use `VeryTightOpt` and tighter SCF
- **Linear dependencies**: Remove diffuse functions or switch to `def2-SVP`
- **Open-shell instability**: Try `NOSOSCF` in %scf or increase SCF damping

## Memory Recommendation

```
%maxcore <N>    # N = available RAM in MB / 1000, e.g., 8000 for 8 GB
```

Set this in the input file or via `ORCA_MAXCORE` environment variable.

## References

- ORCA 5+ Manual: https://orca-manual.mpi-muelheim.mpg.de/
- Bursch et al., Angew. Chem. Int. Ed. 2022, 61, e202205735 (best-practice DFT protocols)
- ORCA Input Library: https://sites.google.com/site/orcainputlibrary/
