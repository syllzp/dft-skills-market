#!/usr/bin/env bash
# Validate a Gaussian 16 input file (.com) for common errors.
# Usage: ./validate-gaussian-input.sh <file.com>
# Prints validation results for: memory, processors, route section, charge/multiplicity, coordinates.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <file.com>"
  exit 1
fi

com_file="$1"

if [ ! -f "$com_file" ]; then
  echo "ERROR: File '$com_file' not found."
  exit 1
fi

errors=0
warnings=0

echo "=== Gaussian 16 Input Validation: $com_file ==="
echo ""

# ---------------------------------------------------------------------------
# 1. Check file has required sections
# ---------------------------------------------------------------------------

# Count blank lines (section separators)
blank_lines=$(grep -c '^\s*$' "$com_file")
if [ "$blank_lines" -lt 3 ]; then
  echo "WARNING: Fewer than 3 blank lines found. Gaussian .com files need blank lines between sections."
  warnings=$((warnings + 1))
fi

# ---------------------------------------------------------------------------
# 2. Route section (first non-comment, non-% line)
# ---------------------------------------------------------------------------
route=$(grep -E '^#' "$com_file" | head -1 || true)
if [ -z "$route" ]; then
  echo "ERROR: No route section found (must start with #)."
  errors=$((errors + 1))
else
  echo "OK: Route section: $route"
fi

# ---------------------------------------------------------------------------
# 3. %chk, %mem, %nprocshared
# ---------------------------------------------------------------------------
chk=$(grep -E '^%chk' "$com_file" || true)
mem=$(grep -E '^%mem' "$com_file" || true)
nproc=$(grep -E '^%nprocshared' "$com_file" || true)

if [ -z "$chk" ]; then
  echo "WARNING: No %chk line (checkpoint file not specified)."
  warnings=$((warnings + 1))
else
  echo "OK: $chk"
fi

if [ -z "$mem" ]; then
  echo "ERROR: No %mem line (memory not specified). Add e.g. '%mem=4GB'."
  errors=$((errors + 1))
else
  echo "OK: $mem"
fi

if [ -z "$nproc" ]; then
  echo "WARNING: No %nprocshared line (will use single core). Add e.g. '%nprocshared=16'."
  warnings=$((warnings + 1))
else
  echo "OK: $nproc"
fi

# ---------------------------------------------------------------------------
# 4. Charge and multiplicity line
# ---------------------------------------------------------------------------
# The charge/mult line appears after the blank line following the title
# We find it by looking for an integer pair after the route line
cm_line=$(grep -E '^\s*-?[0-9]+\s+[0-9]+\s*$' "$com_file" | head -1 || true)

if [ -z "$cm_line" ]; then
  echo "ERROR: No charge/multiplicity line found (e.g. '0 1')."
  errors=$((errors + 1))
else
  charge=$(echo "$cm_line" | awk '{print $1}')
  mult=$(echo "$cm_line" | awk '{print $2}')
  echo "OK: Charge=$charge, Multiplicity=$mult"

  # Validate multiplicity >= 1
  if [ "$mult" -lt 1 ]; then
    echo "ERROR: Multiplicity must be >= 1, got $mult."
    errors=$((errors + 1))
  fi

  # Count electrons from coordinates
  coord_lines=$(sed -n "/$cm_line/,\$p" "$com_file" | tail -n +2 | grep -E '^\s*[A-Za-z]' || true)
  total_electrons=0

  # Atomic numbers
  declare -A Z=(
    [H]=1 [He]=2 [Li]=3 [Be]=4 [B]=5 [C]=6 [N]=7 [O]=8 [F]=9 [Ne]=10
    [Na]=11 [Mg]=12 [Al]=13 [Si]=14 [P]=15 [S]=16 [Cl]=17 [Ar]=18
    [K]=19 [Ca]=20 [Sc]=21 [Ti]=22 [V]=23 [Cr]=24 [Mn]=25 [Fe]=26 [Co]=27 [Ni]=28 [Cu]=29 [Zn]=30
    [Ga]=31 [Ge]=32 [As]=33 [Se]=34 [Br]=35 [Kr]=36
    [Ru]=44 [Rh]=45 [Pd]=46 [Ag]=47 [Cd]=48
    [I]=53 [Xe]=54
    [Pt]=78 [Au]=79
  )

  while read -r elem rest; do
    elem_upper=$(echo "$elem" | sed 's/^\([A-Za-z]\+\).*$/\1/')
    atomic_num=${Z[$elem_upper]:-}
    if [ -z "$atomic_num" ]; then
      echo "WARNING: Unknown element '$elem'. Extend Z map or verify manually."
      warnings=$((warnings + 1))
    else
      total_electrons=$((total_electrons + atomic_num))
    fi
  done <<< "$coord_lines"

  system_electrons=$((total_electrons - charge))
  echo "Total electrons (neutral): $total_electrons"
  echo "System electrons (q=$charge): $system_electrons"

  # Parity check
  electron_parity=$((system_electrons % 2))
  mult_parity=$(( (mult - 1) % 2 ))

  if [ "$electron_parity" -ne "$mult_parity" ]; then
    echo "ERROR: $total_electrons electrons with charge $charge gives $system_electrons electrons, but multiplicity $mult is inconsistent. Multiplicity must have parity = $( [ $electron_parity -eq 0 ] && echo 'odd (1,3,5...)' || echo 'even (2,4,6...)')."
    errors=$((errors + 1))
  else
    echo "OK: Electron count consistent with charge/multiplicity."
  fi
fi

# ---------------------------------------------------------------------------
# 5. Check for common route section issues
# ---------------------------------------------------------------------------
if [ -n "$route" ]; then
  if ! echo "$route" | grep -qi 'opt'; then
    echo "WARNING: Route section does not contain 'Opt'. Is this a geometry optimization?"
    warnings=$((warnings + 1))
  fi

  if echo "$route" | grep -qi 'm06' || echo "$route" | grep -qi 'm11'; then
    if ! echo "$route" | grep -qi 'superfine'; then
      echo "WARNING: Minnesota functional detected but int=superfine not found. Add 'int=superfine'."
      warnings=$((warnings + 1))
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 6. Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Validation Complete ==="
echo "Errors:   $errors"
echo "Warnings: $warnings"

if [ "$errors" -gt 0 ]; then
  echo "RESULT: FAILED ($errors error(s))"
  exit 1
elif [ "$warnings" -gt 0 ]; then
  echo "RESULT: PASSED ($warnings warning(s))"
  exit 0
else
  echo "RESULT: PASSED (clean)"
  exit 0
fi
