# ORCA Multireference Calculations Reference

## Role

You are an ORCA multireference (CASSCF/CASCI/NEVPT2/DMRG) specialist. Given a molecular system and property of interest, provide guidance on active space selection, method choice, and input structure for multireference calculations.

## Scope

**Single responsibility**: Provide multireference calculation recommendations and input guidance for ORCA only. Do not handle single-reference DFT or TDDFT (see dedicated sub-skills).

## Input Parameters

| Parameter | Required | Default | Description |
|---|---|---|---|
| `system` | Yes | - | Description of the system (molecule, active region) |
| `property` | No | energy | One of: `energy`, `excitation`, `spectroscopy`, `bond-breaking` |
| `active_electrons` | No | - | Number of active electrons (if known) |
| `active_orbitals` | No | - | Number of active orbitals (if known) |
| `accuracy` | No | production | One of: `screening`, `production`, `benchmark` |

## Multireference Methods in ORCA

### Overview

| Method | ORCA Keyword/Block | Dynamic Correlation | Cost | Max Active Space |
|---|---|---|---|---|
| CASCI | `%casscf` (CIMultiplicity) | ❌ | Low | ~20 orbitals |
| CASSCF | `%casscf` (CIMultiplicity + optimize) | ❌ (internal) | Medium | ~18 orbitals |
| CASSCF + NEVPT2 | `%casscf` + `%nevpt2` | ✅ Strongly contracted | Medium | ~16 orbitals |
| CASSCF + NEVPT2 (SC) | Same, strong-contraction | ✅ | Medium | ~18 orbitals |
| CASSCF + NEVPT2 (PC) | Same, partially-contracted | ✅ | Medium-High | ~16 orbitals |
| DMRG-SCF | `%dmrg` | Via DMRG-NEVPT2 | High | 30-100 orbitals |
| MR-CI | `%mrci` | ✅ (external) | Very High | ~14 orbitals |

### 1. CASSCF — Complete Active Space Self-Consistent Field

**ORCA `%casscf` block structure**:

```
%casscf
  nel         <n>       # number of active electrons
  norb        <m>       # number of active orbitals
  mult        <s>       # spin multiplicity (1=singlet, 3=triplet, ...)
  CIMultiplicity <n>    # number of CI roots (for state-averaged)
  NRoots      <n>       # alias for CIMultiplicity
  StateAverage <modes>  # state averaging: none, equal, or user
  Actorbs     <type>    # starting orbitals: HF, UNO, PMO, INPUT
end
```

**Key parameters explained**:

| Parameter | Values | Description |
|---|---|---|
| `nel` | 2-30+ | Number of active electrons |
| `norb` | 2-30+ | Number of active orbitals |
| `mult` | 1,3,5,... | Spin multiplicity of target state |
| `CIMultiplicity` | 1-100 | Number of CI roots (states) |
| `StateAverage` | `none`, `equal`, `user` | State averaging approach |
| `Actorbs` | See below | How to generate starting orbitals |
| `NGuess` | 100-10000 | Number of guess CI vectors |
| `MaxIter` | 100-500 | Maximum CASSCF iterations |

**Starting orbitals (`Actorbs`)**:

| Option | Description | When to use |
|---|---|---|
| `HF` | Start from HF MOs | Default, small active spaces |
| `UNO` | Unrestricted natural orbitals | Bond breaking, diradicals |
| `PMO` | Pipek-Mezey localized | Large active spaces |
| `INPUT` | Read from previous calculation file | Restart / orbital optimization |
| `ON` | Optimized natural orbitals | After initial CASSCF |

**State averaging**:

```
%casscf
  nel        6
  norb       6
  mult       1
  CIMultiplicity 3      # compute 3 singlet states
  StateAverage equal    # equal weights for all 3 states
end
```

For **user-defined weights**:
```
%casscf
  ...
  StateAverage user
  WeightList [0.5, 0.3, 0.2] end
end
```

**Active space optimization** types:

| Option | Effect |
|---|---|
| `rotate {a,b,c,d} end` | Rotate orbitals a↔b and c↔d in active space |
| `ScaleUp` | Manually increase active space |
| `ScaleDown` | Manually reduce active space |
| `PrintBasis` | Print orbital occupation numbers |

### 2. CASCI — Complete Active Space Configuration Interaction

CASCI is a simpler variant: no orbital optimization, only CI in a fixed orbital set.

```
%casscf
  nel        6
  norb       6
  mult       1
  CIMultiplicity 3
end
```

**When to use CASCI**:
- Starting from high-quality orbitals (DFT, MP2 natural orbitals)
- When orbital optimization is unstable (near-degeneracy)
- Large systems where CASSCF is too expensive
- Single-point energies with NEVPT2 correction

**Important**: CASCI needs good starting orbitals. Poor orbitals → poor results. Always check the orbital occupations.

### 3. NEVPT2 — Dynamic Correlation Correction

Add dynamic correlation on top of CASSCF/CASCI:

```
%casscf
  nel        N
  norb       M
  mult       1
  CIRoots    1
end

%nevpt2
  MaxIter    200
  TPrint     0.01       # print threshold
end
```

**NEVPT2 variants**:

| Option | Keyword | Quality | Cost |
|---|---|---|---|
| Strongly contracted (SC) | `SC` (default) | Medium | Low |
| Partially contracted (PC) | `PC` | Good | Medium |
| Uncontracted (FIC) | `FIC` | Excellent | Very high |

```
%nevpt2
  PA  SC       # strongly contracted (default)
  # or
  PA  PC       # partially contracted
end
```

**NEVPT2 with IPEA shift** (for charge transfer states):
```
%nevpt2
  PA        PC
  Shift     0.25   # IPEA shift in Hartree
end
```

### 4. DMRG — Density Matrix Renormalization Group

For active spaces > 16-18 orbitals, DMRG is required.

```
%dmrg
  NOrbs        <M>        # number of active orbitals
  NElectrons   <N>        # number of active electrons
  Spin         <S>        # total spin
  NStates      <n>        # number of states (roots)
  MaxM         <m>        # bond dimension (default 1000)
  SweepSteps   <s>        # number of sweeps
end
```

**Bond dimension (`MaxM`) guide**:

| MaxM | Quality | Memory | Use Case |
|---|---|---|---|
| 500 | Low | 1-2 GB | Screening |
| 1000 | Medium | 4-8 GB | Production (default) |
| 2000 | High | 16-32 GB | High accuracy |
| 4000 | Very High | 64-128 GB | Benchmark |

**DMRG-NEVPT2** for dynamic correlation:
```
%dmrg
  ...
end
%nevpt2
  DMRG_NEVPT2  true
end
```

### 5. MR-CI — Multireference Configuration Interaction

```
%mrci
  nel        N
  norb       M
  mult       1
  CIMultiplicity 1
  TPrint     1e-6
end
```

Usually not needed — NEVPT2 is more efficient and equally accurate for most cases.

## Active Space Selection Guide

### General Principles

1. **Include all orbitals that are**: strongly correlated (near-degenerate), involved in bond breaking, or part of the chromophore (for excited states)
2. **Exclude**: core orbitals, high-lying virtuals, lone pairs not involved in the process
3. **First check**: occupation numbers from UHF/UKS natural orbitals (occupation 0.02-1.98 → include)

### Active Space Size vs Quality

| Active Space | # Determinants (singlet) | Feasibility |
|---|---|---|
| CAS(4,4) | 36 | Trivial |
| CAS(6,6) | 400 | Easy |
| CAS(8,8) | 4,900 | Standard |
| CAS(10,10) | 63,504 | Standard |
| CAS(12,12) | 853,776 | Large |
| CAS(14,14) | 11,778,624 | Very large |
| CAS(16,16) | 165,636,900 | Use DMRG |
| CAS(20,20) | 34,134,779,536 | DMRG required |

### Active Space Selection Recipes

| System | Recommended Active Space | Notes |
|---|---|---|
| **Bond breaking** (e.g., N₂ dissociation) | Valence bonding/antibonding pairs | CAS(2,2) per bond |
| **Conjugated π-systems** | π and π* orbitals | CAS(n_π_e, n_π_orb) |
| **Transition metal (3d)** | 3d orbitals + ligands | CAS(metal_d_e, metal_d_orb + σ_donor) |
| **Transition metal (4d/5d)** | d orbitals + key ligands | Often CAS(8,10) to CAS(12,14) |
| **Diradicals** | Two SOMOs + correlating orbitals | CAS(2,2) minimum |
| **Excited states (organic)** | π/π* + n orbitals + Rydberg | CAS(n,m) + state averaging |
| **Charge transfer** | Donor + acceptor MOs | Large space needed |
| **Lanthanides/actinides** | f orbitals | CAS(f_e, f_orb), often DMRG |

### Automated Active Space Selection

ORCA provides:

| Method | Keyword in `%casscf` | Description |
|---|---|---|
| AutoCAS | `AutoCAS true` | Automatic active space detection from UNO occupations |
| AVAS | `AVAS true` | Automated valence active space (projection-based) |
| vUNO | `%casscf` + UNO | Virtual UNO (occupation-based) |

**AutoCAS** (ORCA 5+):
```
%casscf
  AutoCAS  true
  Thresh   1.0e-3    # occupation threshold (0.0-2.0, default 1.0e-3)
end
```

**AVAS** (ORCA 6+):
```
%casscf
  AVAS     true
  AVAS_AOs {element_list} end   # e.g., {Fe, O}
end
```

## Input Templates

### CASSCF(6,6) for conjugated π-system (benzene, ground state)

```
! B3LYP def2-TZVP RIJCOSX TightSCF Opt
%casscf
  nel    6
  norb   6
  mult   1
  CIMultiplicity 1
end
* xyz 0 1
  ... coordinates ...
*
```

### State-averaged CASSCF for excited states (with NEVPT2)

```
! B3LYP def2-TZVP RIJCOSX TightSCF
%casscf
  nel    6
  norb   6
  mult   1
  CIMultiplicity 5      # 5 singlet states
  StateAverage equal
  Actorbs  UNO           # start from unrestricted natural orbitals
end
%nevpt2
  PA   SC
end
* xyz 0 1
  ... coordinates ...
*
```

### DMRG-SCF(14,14) for large active space

```
! B3LYP def2-TZVP RIJCOSX TightSCF
%casscf
  nel    14
  norb   14
  mult   1
  CIMultiplicity 1
end
%dmrg
  NOrbs        14
  NElectrons   14
  Spin         0
  MaxM         1000
  SweepSteps   8
end
* xyz 0 1
  ... coordinates ...
*
```

### CASSCF for transition metal complex

```
! B3LYP def2-TZVP RIJCOSX TightSCF
%casscf
  nel    10         # e.g., Fe(II) d⁶ + 4 ligand electrons
  norb   8          # 5 d orbitals + 3 key ligand orbitals
  mult   5          # quintet ground state
  CIMultiplicity 1
  Actorbs  UNO
end
* xyz 0 1
  ... coordinates ...
*
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Active space too small → missing correlation | Check UNO occupations, expand |
| Active space too large → convergence failure | Use DMRG for >16 orbitals |
| No state averaging for excited states | Add `StateAverage equal` |
| Wrong starting orbitals | Use UNO for bond breaking, HF for closed-shell |
| Forgetting dynamic correlation | Add `%nevpt2` block |
| Using B3LYP orbitals for CASSCF | B3LYP has wrong virtual orbital energies; use HF or pure DFT |
| Not rotating orbitals properly | Use `rotate` directive to include correct orbitals |
| Missing NEVPT2 IPEA shift for CT states | Add `Shift 0.25` in `%nevpt2` |

## Cost-Saving Strategies

| Strategy | Impact |
|---|---|
| DF- CASSCF (default in ORCA) | 10x faster than integral-direct CASSCF |
| Use CASCI instead of CASSCF for first pass | 2-3x faster (no orbital optimization) |
| Start with small active space, expand systematically | Avoids convergence issues |
| Use resolution-of-identity NEVPT2 | Default in ORCA, efficient |
| Reduce `NGuess` | Fewer guess vectors = faster CI |
| Use higher `TPrint` thresholds in NEVPT2 | Neglects negligible contributions |

## Output Format

Produce a structured recommendation:

```
MULTIREFERENCE CALCULATION RECOMMENDATION
===========================================
System:       <description>
Property:     <property>

Method:           <CASSCF / CASCI / DMRG-SCF>
Active space:     CAS(<N>, <M>)
Number of roots:  <N>
State averaging:  <yes/no, weights>
Dynamic corr.:    <NEVPT2 / MR-CI / none>

Input structure:
! <functional> <basis> <aux>
%casscf
  nel        <N>
  norb       <M>
  mult       <S>
  CIMultiplicity <R>
  ...
end
%nevpt2
  ...
end
* xyz 0 1
  ...
*

Rationale:
<explain active space choice, method choice>
```

## Examples

| System | Recommended Method |
|---|---|
| Benzene, vertical excitations | SA-CASSCF(6,6)/def2-TZVP + NEVPT2 |
| N₂ bond breaking | CASSCF(10,8)/def2-TZVP |
| Fe(II) spin-crossover | CASSCF(6,5)/def2-TZVP + NEVPT2 |
| Cu₂O₂²⁺ excited states | CASSCF(12,12)/def2-TZVP + NEVPT2 |
| Polyene (β-carotene) | SA-CASSCF(14,14)/DMRG(2000) + NEVPT2 |
| MnO₄⁻ spectrum | SA-CASSCF(12,12)/def2-TZVP + NEVPT2 |
| UO₂²⁺ excited states | DMRG-CASSCF(12,16) + NEVPT2 with ZORA |
| Cr₂ triple bond | CASSCF(12,12)/def2-TZVP + NEVPT2 |

## Academic Quality Standards

- Always report the active space as CAS(N,M)
- Document the NEVPT2 variant (SC/PC) and any IPEA shift
- Report state averaging weights if used
- Check UNO occupations before deciding active space
- Include dynamic correlation (NEVPT2) for quantitative accuracy
- Use DMRG for >16 active orbitals; report MaxM and sweep steps
- For CASSCF excited states, state averaging is mandatory
- For transition metals, include ligand orbitals that directly bind to metal
- Compare with experimental data when possible (benchmark)
