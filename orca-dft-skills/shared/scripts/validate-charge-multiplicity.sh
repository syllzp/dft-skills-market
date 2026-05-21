#!/usr/bin/env bash
# Validate that charge + multiplicity is consistent with electron count in an XYZ file.
# Usage: ./validate-charge-multiplicity.sh <file.xyz> <charge> <multiplicity>
# Prints "VALID" or "INVALID: <reason>"

set -euo pipefail

if [ $# -ne 3 ]; then
  echo "INVALID: Usage: $0 <file.xyz> <charge> <multiplicity>"
  exit 1
fi

xyz_file="$1"
charge="$2"
multiplicity="$3"

# Atomic numbers for elements H through Kr (common in DFT)
declare -A Z=(
  [H]=1 [He]=2 [Li]=3 [Be]=4 [B]=5 [C]=6 [N]=7 [O]=8 [F]=9 [Ne]=10
  [Na]=11 [Mg]=12 [Al]=13 [Si]=14 [P]=15 [S]=16 [Cl]=17 [Ar]=18
  [K]=19 [Ca]=20 [Sc]=21 [Ti]=22 [V]=23 [Cr]=24 [Mn]=25 [Fe]=26 [Co]=27 [Ni]=28 [Cu]=29 [Zn]=30
  [Ga]=31 [Ge]=32 [As]=33 [Se]=34 [Br]=35 [Kr]=36
)

# Count total electrons from XYZ file (skip first two header lines)
total_electrons=0
while read -r elem _rest; do
  if [ -z "${Z[$elem]+x}" ]; then
    echo "INVALID: Unknown element '$elem' -- extend the Z map in this script"
    exit 1
  fi
  total_electrons=$((total_electrons + Z[$elem]))
done < <(tail -n +3 "$xyz_file" | grep -v '^\*' | grep -v '^\s*$')

# Electrons in the charged system
system_electrons=$((total_electrons - charge))

# Parity check: even electrons -> odd multiplicity, odd electrons -> even multiplicity
electron_parity=$((system_electrons % 2))
mult_parity=$(( (multiplicity - 1) % 2 ))

if [ "$electron_parity" -ne "$mult_parity" ]; then
  echo "INVALID: Electron count ($total_electrons) with charge ($charge) gives $system_electrons electrons, but multiplicity ($multiplicity) is inconsistent. Multiplicity must be $(( system_electrons % 2 == 0 ? 1 : 2 )) or higher with same parity."
  exit 1
fi

if [ "$multiplicity" -lt 1 ]; then
  echo "INVALID: Multiplicity must be >= 1"
  exit 1
fi

echo "VALID: $total_electrons electrons, charge=$charge, multiplicity=$multiplicity, system_electrons=$system_electrons"
