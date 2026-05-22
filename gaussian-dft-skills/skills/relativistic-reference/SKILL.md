# Gaussian 16 Relativistic Calculations Reference

## Role

You are a Gaussian 16 relativistic effect specialist. Given a molecular system containing heavy elements, recommend the appropriate relativistic treatment (ECP, DKH, or spin-orbit) and explain the rationale.

## Scope

**Single responsibility**: Provide relativistic method recommendations for Gaussian 16 calculations only. Do not generate complete input files (use the dedicated input sub-skills) or handle basis set selection (see `basis-reference`).

## Input Parameters

| Parameter | Required | Default | Description |
|---|---|---|---|
| `elements` | Yes | - | List of elements (especially heavy ones: 4d, 5d, 4f, 5f) |
| `property` | No | energy | One of: `energy`, `geometry`, `freq`, `excitation`, `nmr` |
| `accuracy` | No | production | One of: `screening`, `production`, `benchmark` |
| `molecule_type` | No | organic | One of: `organic`, `transition-metal`, `heavy-element`, `lanthanide`, `actinide` |

## Relativistic Methods in Gaussian 16

### Overview

Gaussian offers three main approaches for relativistic effects:

| Method | Scalar | Spin-Orbit | Cost | Best for |
|---|---|---|---|---|
| ECP / Pseudopotentials | ✅ (implicit) | ❌ | None | Production default for Z>36 |
| DKH (Douglas-Kroll) | ✅ | Limited | Medium | High accuracy without ECP |
| X2C (eXact 2-Component) | ✅ | ✅ | Medium-High | State-of-the-art, G16 defaults in new versions |

### 1. ECP (Effective Core Potentials) — Implicit Relativity

**How it works**: Replace core electrons with a pseudopotential that implicitly includes scalar relativistic effects. This is the **most common approach** in Gaussian.

| ECP | For | Gaussian Basis | Available Elements |
|---|---|---|---|
| LANL2DZ | Main group + TM (Kr-Cm) | `LANL2DZ` | Most 4d, 5d, 4f, 5f |
| SDD | Main group + TM | `SDDAll` / `SDD` | Extended coverage |
| Stuttgart RLC | Lanthanides, actinides | `MWB*` / `MWB28` | Ce-Yb, Th-Cm |
| def2-ECP | Main group + TM (Kr+) | `def2TZVP` etc. | 4d, 5d, main group heavy |
| CRENBL | Large-core ECP | `CRENBL` | Lanthanides, actinides |
| CRENBS | Small-core ECP | `CRENBS` | Lanthanides, actinides |

**When to use**: Default production for elements beyond Kr. Sufficient for geometries, energies, frequencies.

**Limitations**: No spin-orbit coupling. Properties depending on core region (NMR, Mössbauer) are poorly described.

### 2. DKH (Douglas-Kroll-Hess) — All-Electron Relativity

**Gaussian keyword**: `Int=DKH` (up to DKH2) or `Int=DKHSO`

| Level | Keyword | Description |
|---|---|---|
| DKH1 | `Int=DKH` | 1st order (obsolete) |
| DKH2 | `Int=DKH` (default) | 2nd order — standard |
| DKH3+ | Not directly supported | Use X2C instead |
| Spin-orbit DKH | `Int=DKHSO` | 2nd order + spin-orbit |

**Basis sets for DKH**: Use DKH-compatible recontractions:
- `cc-pVDZ-DK`, `cc-pVTZ-DK`, `cc-pVQZ-DK`
- `aug-cc-pVTZ-DK`
- `ANO-RCC` (relativistic atomic natural orbitals)

**When to use**:
- All-electron relativistic treatment
- High accuracy for light-to-medium heavy elements
- NMR parameters (when all-electron is needed)
- Properties sensitive to core region

### 3. X2C (eXact 2-Component) — State-of-the-Art

**Gaussian keyword**: `Int=X2C`

| Variant | Keyword | Description |
|---|---|---|
| Scalar X2C | `Int=X2C` | Scalar relativistic (default) |
| Spin-orbit X2C | `Int=X2C=SO` | Including spin-orbit |

**Features**:
- Automatically includes picture-change correction
- Variational stability
- Accurate for all elements
- **Default method in newer Gaussian versions**

**Basis sets for X2C**: Use `x2c-*` family:
- `x2c-SVPall`, `x2c-TZVPall`, `x2c-QZVPall` (optimized for X2C)
- Also compatible with DKH-optimized DK bases

**When to use**:
- Preferred all-electron method in G16
- Heavy elements (lanthanides, actinides)
- Spin-orbit effects on properties
- NMR with spin-orbit
- Consistent accuracy from 3d to 5f elements

### 4. Spin-Orbit Coupling in Gaussian

| Method | Keyword | Output |
|---|---|---|
| DKH spin-orbit | `Int=DKHSO` | 2-component spin-orbit |
| X2C spin-orbit | `Int=X2C=SO` | 2-component spin-orbit |
| SOC with TDDFT | `TD` + `Int=DKHSO` or `X2C=SO` | Spin-orbit effects on excitations |

**Spin-orbit TDDFT** (approximate approach):
```
#P B3LYP/gen Int=X2C=SO
TD(NStates=10)
```

Gaussian's SOC treatment is less mature than ORCA's. For phosphorescence rates and detailed SOC analysis, consider using ORCA instead.

## Selection Rules

### By Element / System

| System | Elements | Method | SOC needed? |
|---|---|---|---|
| 3d transition metals | Sc-Zn (Z=21-30) | ECP or none | No |
| 4d transition metals | Y-Cd (Z=39-48) | **ECP** (LANL2DZ or def2-ECP) | Rarely |
| 5d transition metals | Lu-Hg (Z=71-80) | **ECP** or **X2C** | For spectra |
| Lanthanides | La-Lu (Z=57-71) | **ECP** (SDD, CRENBL) or **X2C** | ✅ Important |
| Actinides | Ac-Lr (Z=89-103) | **X2C** or **ECP** (SDD) | ✅ Essential |
| Main group heavy | Tl-Rn (Z=81-86) | **ECP** (def2-ECP) | For SOC splittings |
| Au, Pt, etc. | Z=78-79 | **ECP** or **X2C** | For spectroscopy |
| 6p elements | Tl-Rn | **ECP** or **X2C** | SOC splitting in p-orbitals |

### By Property

| Property | Method (Production) | Notes |
|---|---|---|
| Geometry optimization | ECP | SOC not needed for geometries |
| Single-point energy | ECP or X2C/DKH | X2C for benchmark |
| Frequencies | ECP | Hessian not SOC-sensitive |
| TDDFT / Excited states | ECP or X2C | SOC splitting via X2C=SO |
| NMR chemical shifts | **X2C** or DKH | Core properties need all-electron |
| NMR spin-spin coupling | X2C | Picture-change matters |
| Mössbauer isomer shift | X2C | Core electron density needed |
| EPR g-tensor | Not well supported | Use ORCA instead |

### Method Selection Flow

```
Z > 36 (heavy elements)?
├── No  (3d, 4p) → No relativistic treatment needed
└── Yes
    ├── Production geometries/energies → ECP (LANL2DZ, SDD, def2-ECP)
    ├── High accuracy all-electron → X2C with x2c-* basis
    ├── NMR / core properties → X2C (mandatory)
    ├── Spin-orbit effects → X2C=SO
    └── Lanthanides/actinides → X2C or ECP (SDD)
```

### Cost Spectrum

```
ECP  <  DKH2  <  X2C (scalar)  <  X2C=SO  <  DKH+SO
(low cost)                        (high cost)
```

ECP is essentially cost-free compared to valence-electron basis size.

## Common Input Patterns

### ECP with LANL2DZ (production for TM complex)

```
#P B3LYP/LANL2DZ Opt Freq

Title

0 1
... coordinates including TM ...
```

### ECP with def2-ECP via def2TZVP

```
#P B3LYP/def2TZVP Opt

Title

0 1
... coordinates including 4d/5d elements ...
```

**Note**: def2-ECP is auto-applied when using def2 bases. Add `PP` keyword if manual control is needed:
```
#P B3LYP/def2TZVP Opt
PP{def2-ECP}
```

### DKH2 all-electron (benchmark)

```
#P B3LYP/cc-pVTZ-DK Int=DKH Opt

Title

0 1
... coordinates ...
```

### X2C all-electron (state-of-the-art)

```
#P B3LYP/x2c-TZVPall Int=X2C Opt

Title

0 1
... coordinates ...
```

### X2C with spin-orbit

```
#P B3LYP/x2c-TZVPall Int=X2C=SO

Title

0 1
... coordinates ...
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `GEN` keyword unnecessarily | ECP basis names auto-include pseudopotentials |
| Using ECP for light elements (Z<37) | ECP is only defined for heavy elements |
| Expecting SOC from standard ECP | ECP provides only scalar relativity |
| Using all-electron DKH without DK basis | Use `cc-pVTZ-DK`, not `cc-pVTZ` |
| Mixing basis/ECP inconsistently | Define via `gen` with `PP` pseudo-potential card |
| Not declaring `PP` when mixing ECP/basis | Add `PP{...}` in route section or use genecp |

## ECP Detailed Selection

| Z | Element Group | Recommended ECP | Basis |
|---|---|---|---|
| 37-54 | Rb-Xe (4d, 5p) | def2-ECP, LANL2DZ | def2TZVP, LANL2DZ |
| 55-56 | Cs, Ba (6s) | def2-ECP, SDD | def2TZVP, SDDAll |
| 57-71 | La-Lu (4f, lanthanides) | SDD, CRENBL, Stuttgart MWB | SDDAll, CRENBL |
| 72-80 | Hf-Hg (5d) | def2-ECP, SDD | def2TZVP, SDDAll |
| 81-86 | Tl-Rn (6p) | def2-ECP, SDD | def2TZVP, SDDAll |
| 89-103 | Ac-Lr (5f, actinides) | SDD, CRENBL, Stuttgart MWB | SDDAll, CRENBL |

## Output Format

Produce a structured recommendation:

```
RELATIVISTIC METHOD RECOMMENDATION
====================================
System:           <elements>
Property:         <property>
Accuracy:         <accuracy>

Recommended method:  <METHOD>
Basis:               <BASIS>
ECP need:            Yes/No (which ECP)

Rationale:
<why this method is appropriate>

Gaussian route section:
#P <method/basis> <keywords>

Notes:
<cost estimate, alternatives, limitations>
```

## Examples

| System | Recommendation |
|---|---|
| Pt(CN)₄²⁻, geometry | ECP (LANL2DZ on Pt, 6-31G(d) on C,N) |
| UO₂²⁺, frequencies | X2C, x2c-TZVPall |
| Au₂ dimer, benchmark | X2C=SO, x2c-TZVPall |
| Fe(CO)₅, SP | No relativistic needed (3d metal) |
| CeO₂, TDDFT | ECP (SDD on Ce), 6-31+G(d) on O |
| W(CO)₆, NMR | X2C or DKH, x2c-TZVPall / cc-pVTZ-DK |
| CsI, excited states | ECP (def2-ECP) or X2C |
| Lanthanide complex | ECP (SDD or CRENBL) or X2C |

## Academic Quality Standards

- 3d TMs: No relativistic treatment needed — ECP is optional
- 4d TMs: ECP is standard (LANL2DZ or def2-ECP)
- 5d TMs: ECP is standard for geometries; X2C for high accuracy
- Lanthanides/actinides: ECP (SDD/CRENBL) for production; X2C for benchmark
- Always specify relativistic treatment in methods section
- Document the ECP or DKH/X2C level used
- For NMR on heavy nuclei, all-electron X2C or DKH is mandatory
- For spin-orbit splitting, use X2C=SO (or switch to ORCA for advanced SOC)
