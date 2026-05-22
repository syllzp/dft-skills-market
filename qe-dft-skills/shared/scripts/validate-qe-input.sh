#!/usr/bin/env bash
# Validate a Quantum ESPRESSO pw.x input file for consistency.
# Usage: ./validate-qe-input.sh <input.in>
# Prints validation results: PASS or FAIL for each check.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <input.in>"
  exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
  echo "FAIL: File '$INPUT' not found"
  exit 1
fi

errors=0

check() {
  local msg="$1"
  local cond="$2"
  if eval "$cond"; then
    echo "  PASS: $msg"
  else
    echo "  FAIL: $msg"
    errors=$((errors + 1))
  fi
}

echo "=== QE Input Validation: $INPUT ==="

# 1. Namelists are properly closed with /
check "Namelists closed with /" \
  'grep -c "^/" "$INPUT" | xargs -I{} test {} -ge 3'

# 2. &CONTROL exists
check "&CONTROL namelist present" \
  'grep -q "^&CONTROL" "$INPUT"'

# 3. &SYSTEM exists
check "&SYSTEM namelist present" \
  'grep -q "^&SYSTEM" "$INPUT"'

# 4. &ELECTRONS exists
check "&ELECTRONS namelist present" \
  'grep -q "^&ELECTRONS" "$INPUT"'

# 5. ecutwfc is set and positive
ECUTWFC=$(grep -i "ecutwfc" "$INPUT" | sed 's/.*=[[:space:]]*\([0-9.]*\).*/\1/' | head -1)
check "ecutwfc is set and positive" \
  'test -n "$ECUTWFC" && echo "$ECUTWFC > 0" | bc -l | grep -q 1'

# 6. ecutrho exists and >= 4 * ecutwfc
ECUTRHO=$(grep -i "ecutrho" "$INPUT" | sed 's/.*=[[:space:]]*\([0-9.]*\).*/\1/' | head -1)
if [ -n "$ECUTRHO" ] && [ -n "$ECUTWFC" ]; then
  check "ecutrho >= 4 * ecutwfc" \
    'echo "$ECUTRHO >= 4 * $ECUTWFC" | bc -l | grep -q 1'
else
  echo "  SKIP: ecutrho check (missing values)"
fi

# 7. nat matches number of atomic positions
NAT=$(grep -i "^[[:space:]]*nat[[:space:]]*=" "$INPUT" | sed 's/.*=[[:space:]]*\([0-9]*\).*/\1/' | head -1)
POS_COUNT=$(grep -c -E '^[[:space:]]*[A-Z][a-z]?[[:space:]]+[-0-9]' "$INPUT" 2>/dev/null || grep -c -E '^[[:space:]]*[A-Z][a-z]?[[:space:]]+' "$INPUT" | head -1)
# More robust nat count: count lines between ATOMIC_POSITIONS and next section
POS_LINES=$(sed -n '/^ATOMIC_POSITIONS/,/^[A-Z_]/p' "$INPUT" | grep -c -E '^[[:space:]]*[A-Za-z]')
if [ -n "$NAT" ] && [ "$POS_LINES" -gt 0 ]; then
  check "nat ($NAT) matches number of position lines ($POS_LINES)" \
    'test "$NAT" -eq "$POS_LINES"'
else
  echo "  SKIP: nat / positions count check (missing values)"
fi

# 8. ntyp matches number of ATOMIC_SPECIES
NTYP=$(grep -i "^[[:space:]]*ntyp[[:space:]]*=" "$INPUT" | sed 's/.*=[[:space:]]*\([0-9]*\).*/\1/' | head -1)
SPECIES_COUNT=$(sed -n '/^ATOMIC_SPECIES/,/^[A-Z_]/p' "$INPUT" | grep -c -E '^[[:space:]]*[A-Za-z]')
if [ -n "$NTYP" ] && [ "$SPECIES_COUNT" -gt 0 ]; then
  check "ntyp ($NTYP) matches number of species lines ($SPECIES_COUNT)" \
    'test "$NTYP" -eq "$SPECIES_COUNT"'
else
  echo "  SKIP: ntyp / species count check (missing values)"
fi

# 9. mixing_beta between 0.05 and 1.0
MIX_BETA=$(grep -i "mixing_beta" "$INPUT" | sed 's/.*=[[:space:]]*\([0-9.]*\).*/\1/' | head -1)
if [ -n "$MIX_BETA" ]; then
  check "mixing_beta between 0.05 and 1.0" \
    'echo "$MIX_BETA >= 0.05 && $MIX_BETA <= 1.0" | bc -l | grep -q 1'
else
  echo "  SKIP: mixing_beta check (missing)"
fi

# 10. If nspin=2, starting_magnetization should be present
if grep -qi "nspin[[:space:]]*=[[:space:]]*2" "$INPUT"; then
  check "nspin=2: starting_magnetization present" \
    'grep -qi "starting_magnetization" "$INPUT"'
else
  echo "  INFO: nspin not 2, skipping magnetization check"
fi

# 11. If lda_plus_u, Hubbard_U should be present
if grep -qi "lda_plus_u[[:space:]]*=[[:space:]]*\.true\." "$INPUT"; then
  check "lda_plus_u: Hubbard_U present" \
    'grep -qi "Hubbard_U" "$INPUT"'
else
  echo "  INFO: lda_plus_u not set, skipping Hubbard_U check"
fi

# 12. K_POINTS section present
check "K_POINTS section present" \
  'grep -q "^K_POINTS" "$INPUT"'

# 13. ATOMIC_SPECIES section present
check "ATOMIC_SPECIES section present" \
  'grep -q "^ATOMIC_SPECIES" "$INPUT"'

# 14. ATOMIC_POSITIONS section present
check "ATOMIC_POSITIONS section present" \
  'grep -q "^ATOMIC_POSITIONS" "$INPUT"'

# Summary
echo ""
if [ "$errors" -eq 0 ]; then
  echo "RESULT: ALL CHECKS PASSED"
  exit 0
else
  echo "RESULT: $errors check(s) FAILED"
  exit 1
fi
