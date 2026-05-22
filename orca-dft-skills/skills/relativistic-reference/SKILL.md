# ORCA Relativistic Calculations Reference

## Role

You are an ORCA relativistic effect specialist. Given a molecular system containing heavy elements, recommend the appropriate relativistic treatment (scalar, spin-orbit, or both) and explain the rationale.

## Scope

**Single responsibility**: Provide relativistic method recommendations for ORCA calculations only. Do not generate complete input files (use the dedicated input sub-skills) or handle basis set selection (see `basis-reference`).

## Input Parameters

| Parameter | Required | Default | Description |
|---|---|---|---|
| `elements` | Yes | - | List of elements (especially heavy ones: 4d, 5d, 4f, 5f) |
| `property` | No | energy | One of: `energy`, `geometry`, `freq`, `excitation`, `nmr`, `epr`, `soc` |
| `accuracy` | No | production | One of: `screening`, `production`, `benchmark` |
| `molecule_type` | No | organic | One of: `organic`, `transition-metal`, `heavy-element`, `lanthanide`, `actinide` |

## Relativistic Methods in ORCA

### Overview

ORCA offers four levels of relativistic treatment, from simplest to most rigorous:

| Method | Scalar | Spin-Orbit | Cost | Best for |
|---|---|---|---|---|
| ECP | ✅ (implicit) | ❌ | None | Elements > Kr (Z=36), production |
| ZORA (SAR) | ✅ | ❌ | Low | 4d/5d metals, mild relativity |
| ZORA (SARC) | ✅ | ✅ | Medium | Heavy elements, spectroscopy |
| DKH2 (SAR) | ✅ | ❌ | Medium | 4d/5d metals, high accuracy |
| DKH2 (DKHSO) | ✅ | ✅ | High | Heavy elements, spin-orbit effects |
| IORA | ✅ | ❌ | Medium | Alternative to ZORA/DKH |

### 1. ECP (Effective Core Potentials) — Implicit Relativity

**How it works**: Replace core electrons with a pseudopotential that implicitly includes scalar relativistic effects.

| ECP | For | ORCA Syntax |
|---|---|---|
| def2-ECP | Main group (Kr+) + 3d metals | `def2-TZVP` (auto-applied) |
| SDD | Main group + TM | `SDD` basis |
| SARC-ECP | 4d/5d/4f/5f metals | `SARC2-TZVP` (auto-applied) |

**When to use**: Default production for elements beyond Kr (Z=36). Sufficient for geometries, energies, frequencies. Use **only scalar relativity** — no spin-orbit coupling via ECP.

**Limitations**: Cannot describe spin-orbit effects (SOC, phosphorescence, intersystem crossing). Exchange-correlation functional sees only valence electrons.

### 2. ZORA (Zero-Order Regular Approximation) — Scalar + Spin-Orbit

**ORCA keywords**:

| Method | Keyword | Description |
|---|---|---|
| Scalar ZORA | `! ZORA` | Scalar relativistic only |
| Spin-orbit ZORA | `! ZORA` + `%rel SOC ... end` | Includes SOC |

**ZORA Hamiltonian choice**:

| Hamiltonian | Keyword | When to use |
|---|---|---|
| Scalar ZORA | `! ZORA` | Geometries, frequencies, scalar NMR |
| ZORA + SOC | `! ZORA` + `%rel SOC 1 end` | Spin-orbit splittings, phosphorescence |
| ZORA + SOC (full) | `%rel SOCType 1 end` | Full SOC (including two-electron) |

**ZORA + basis sets**: Use ZORA-compatible bases:
- `ZORA-def2-TZVP`, `ZORA-def2-QZVP` (optimized with ZORA)
- Also works with standard def2 bases but ZORA-optimized is preferred

**When to use**:
- 4d metals (Mo, Ru, Rh, Pd, Ag, Cd): scalar ZORA sufficient
- 5d metals (W, Re, Os, Ir, Pt, Au): ZORA + SOC recommended
- NMR of heavy atoms: ZORA essential for chemical shifts
- EPR of TM complexes: ZORA + SOC for g-tensors

### 3. DKH (Douglas-Kroll-Hess) — Scalar + Spin-Orbit

**ORCA keywords**:

| Method | Keyword | Description |
|---|---|---|
| Scalar DKH2 | `! DKH2` | 2nd-order DKH, scalar |
| Scalar DKHSO | `! DKHSO` | 2nd-order DKH + spin-orbit |
| Higher order | `! DKH3` / `! DKH4` | 3rd / 4th order (benchmark) |

**DKH + basis sets**:
- `DKH-def2-TZVP`, `DKH-def2-QZVP`
- DKH-optimized bases recommended for accuracy

**When to use**:
- Higher accuracy than ZORA for heavy elements
- Preferred for 5d metals and beyond at production level
- NMR parameters (shielding, spin-spin coupling)
- DKH3/4 for benchmark-quality relativistic calculations

### 4. IORA (Infinite-Order Regular Approximation)

**ORCA keywords**:
- `! IORA` — scalar only
- More accurate than ZORA for very heavy elements
- Recommended when ZORA is insufficient but DKH2 is too expensive

### 5. Spin-Orbit Coupling (Explicit)

ORCA computes SOC after a scalar relativistic calculation. The SOC can be:

| Method | Input | Output |
|---|---|---|
| SOC with ZORA | `%rel SOC 1 end` | Spin-orbit matrix elements |
| SOC with DKH | `! DKHSO` | SOC included in Hamiltonian |
| SOC from TDDFT | `%tddft SOC ... end` | SOC effects on excited states |
| QDPT (Quasi-Degenerate PT) | `%rel QDPT ... end` | SOC between near-degenerate states |

**SOC activation in TDDFT**:
```
%tddft
  NRoots 10
  SOC 1          # activate SOC
  DOSOC 0        # dipole SOC (0=length, 1=velocity)
end
```

### 6. Picture-Change Effects

Relativistic effects modify the wavefunction near the nucleus. For properties that depend on the **wavefunction near the nucleus**, a "picture-change" correction is needed:

| Property | Correction needed | Effect |
|---|---|---|
| NMR chemical shifts | ✅ Critical | Up to 50% error without picture-change |
| Hyperfine coupling (EPR) | ✅ Critical | Large errors without correction |
| Electric field gradients (NQR) | ✅ Important | 10-30% improvement |
| Geometries / energies | ❌ Not needed | Well described without |

ORCA handles picture-change automatically for ZORA and DKH properties.

## Selection Rules

### By Element / System

| System | Elements | Relativistic Method | SOC needed? |
|---|---|---|---|
| 3d transition metals | Sc-Zn (Z=21-30) | None / scalar ZORA | Typically no |
| 4d transition metals | Y-Cd (Z=39-48) | **ECP** or **scalar ZORA** | Rarely |
| 5d transition metals | Lu-Hg (Z=71-80) | **ZORA** or **DKH2** | ✅ Yes (for spectra) |
| Lanthanides | La-Lu (Z=57-71) | **ZORA** + SOC | ✅ Essential |
| Actinides | Ac-Lr (Z=89-103) | **DKH2** or **IORA** + SOC | ✅ Essential |
| Main group heavy | Tl-Rn (Z=81-86) | **ECP** or **ZORA** | For spin-orbit splittings |
| Noble metals (Au, Pt) | Au, Pt, etc. | **DKH2** or **ZORA** | ✅ Important for properties |
| 6p elements | Tl-Rn | **ZORA** or **DKH2** | ✅ (SOC splitting in p-orbitals) |

### By Property

| Property | Method | Notes |
|---|---|---|
| Geometry optimization | ECP or scalar ZORA | SOC rarely needed for geometries |
| Single-point energy (SP) | ECP or scalar ZORA | DKH2 for high accuracy |
| Frequencies | ECP or scalar ZORA | Hessian not significantly affected by SOC |
| TDDFT (organic on heavy atom) | ZORA + SOC or DKHSO | SOC splits excited states |
| Phosphorescence rates | ZORA + SOC | SOC essential, uses QDPT |
| NMR chemical shifts | **ZORA** (preferred) or DKH2 | Picture-change critical |
| EPR g-tensor | **ZORA** + SOC | SOC essential |
| EPR hyperfine | **ZORA** + SOC | Picture-change critical |
| Spin-orbit splitting | ZORA + SOC / DKHSO | Choose based on element |
| Mössbauer isomer shift | DKH2 + appropriate basis | Core properties |

### Cost Spectrum

```
ECP  <  ZORA  <  DKH2  <  IORA  <  DKH3/4
(low cost)                  (high cost)
                      
        No SOC  <  SOC (QR)  <  SOC (QDPT)
```

## Common Input Patterns

### Scalar ZORA for geometry optimization (4d/5d metal complex)

```
! B3LYP DKH-def2-TZVP OPT TightSCF RIJCOSX
! ZORA
%maxcore 4000
%pal nprocs 8 end
* xyz 0 1
  ... coordinates ...
*
```

### ZORA + SOC for TDDFT (heavy organic, phosphorescence)

```
! B3LYP DKH-def2-TZVP RIJCOSX TightSCF
! ZORA
%tddft
  NRoots 20
  SOC 1
  DOSOC 0
end
%rel
  SOC 1
  QDPT 1
end
* xyz 0 1
  ... coordinates ...
*
```

### DKH2 scalar for heavy element benchmark

```
! PBE0 DKH-def2-TZVP RIJCOSX TightSCF
! DKH2
%maxcore 8000
* xyz 0 1
  ... coordinates ...
*
```

### ECP approach (simple, default production)

```
! B3LYP def2-TZVP OPT TightSCF RIJCOSX
* xyz 0 1
  ... coordinates including 4d/5d elements ...
*
```
(ECP is auto-applied when using def2 bases for heavy elements)

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using ZORA without ZORA-optimized basis | Use `DKH-def2-TZVP` or `ZORA-def2-TZVP` |
| Expecting SOC from ECP alone | ECP includes only scalar relativity |
| Forgetting picture-change for NMR/EPR | ZORA/DKH handle this automatically |
| Using SOC for geometry optimization | SOC has negligible effect on geometry, waste of resources |
| Not activating SOC when computing phosphorescence | Phosphorescence requires SOC between S₁ and T₁ |
| Using too small a basis with ZORA | min. DKH-def2-TZVP / ZORA-def2-TZVP |
| Mixing DKH and ZORA bases | Use consistent relativistic basis family |

## Output Format

Produce a structured recommendation:

```
RELATIVISTIC METHOD RECOMMENDATION
====================================
System:           <elements>
Property:         <property>
Accuracy:         <accuracy>

Recommended method:  <METHOD>
Basis:               <BASIS> (relativistic-optimized if needed)
SOC needed:          Yes/No

Rationale:
<why this method is appropriate for this system>

ORCA keywords:
! <REL_METHOD>
<additional SOC keywords if needed>

Notes:
<picture-change, cost estimate, alternatives>
```

## Examples

| System | Recommendation |
|---|---|
| Ir(ppy)₃ phosphorescence | ZORA + SOC + QDPT, DKH-def2-TZVP |
| UO₂²⁺ geometry | DKH2 scalar, DKH-def2-TZVP |
| Au₁₃ cluster, SP energy | ZORA or DKH2, DKH-def2-TZVP |
| Fe(CO)₅, geometry | ECP (def2-ECP) via def2-TZVP |
| Pt complex, ¹⁹⁵Pt NMR | ZORA (picture-change critical), ZORA-def2-TZVP |
| CeO₂, TDDFT | ZORA + SOC, ZORA-def2-TZVP |
| W(CO)₆, frequencies | scalar ZORA or DKH2 |
| Cs⁺ solvation | ECP (def2-ECP) or ZORA |

## Academic Quality Standards

- 3d TMs: ECP or no relativistic treatment is standard
- 4d TMs: scalar ZORA or ECP (both accepted)
- 5d TMs: ZORA+SOC or DKH2 (SOC essential for spectroscopy)
- Lanthanides/actinides: ZORA+SOC minimum; DKH2 for benchmark
- Always specify the relativistic method and basis in methods section of paper
- Use ZORA- or DKH-optimized bases for production work
- Document whether SOC was included (important for excited states)
- For NMR/EPR on heavy atoms, relativistic treatment is mandatory
