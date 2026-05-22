#!/usr/bin/env bash
# Validate a CP2K input file for basic structural correctness.
# Usage: ./validate-cp2k-input.sh <input.inp>
# Checks: balanced &END tokens, required sections, cutoff values

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -ne 1 ]; then
  echo "Usage: $0 <input.inp>"
  exit 1
fi

inp_file="$1"

if [ ! -f "$inp_file" ]; then
  echo -e "${RED}ERROR: File '$inp_file' not found.${NC}"
  exit 1
fi

errors=0
warnings=0

echo "Validating: $inp_file"
echo ""

# 1. Check balanced &END tokens
open_sections=$(grep -c '^&[A-Z]' "$inp_file" || true)
close_sections=$(grep -c '&END' "$inp_file" || true)
if [ "$open_sections" -ne "$close_sections" ]; then
  echo -e "${RED}ERROR: Unbalanced sections. Found $open_sections opening and $close_sections closing &END directives.${NC}"
  errors=$((errors + 1))
else
  echo -e "${GREEN}OK: Section balance ($open_sections openings, $close_sections closings).${NC}"
fi

# 2. Check required top-level sections
for section in "GLOBAL" "FORCE_EVAL" "MOTION"; do
  if grep -qi "^\s*&$section" "$inp_file"; then
    echo -e "${GREEN}OK: &$section section found.${NC}"
  else
    echo -e "${RED}ERROR: Required &$section section missing.${NC}"
    errors=$((errors + 1))
  fi
done

# 3. Check PROJECT is set
if grep -qi "^\s*PROJECT" "$inp_file"; then
  project=$(grep -i "^\s*PROJECT" "$inp_file" | head -1 | awk '{print $2}')
  echo -e "${GREEN}OK: PROJECT = $project${NC}"
else
  echo -e "${YELLOW}WARNING: PROJECT not set in &GLOBAL. CP2K will use 'cp2k' as default.${NC}"
  warnings=$((warnings + 1))
fi

# 4. Check RUN_TYPE
if grep -qi "RUN_TYPE" "$inp_file"; then
  run_type=$(grep -i "RUN_TYPE" "$inp_file" | head -1 | awk '{print $2}')
  echo -e "${GREEN}OK: RUN_TYPE = $run_type${NC}"
fi

# 5. Check CUTOFF is set
if grep -qi "CUTOFF" "$inp_file" | grep -v "REL_CUTOFF" | head -1; then
  cutoff=$(grep -i "^\s*CUTOFF\b" "$inp_file" | head -1 | awk '{print $2}')
  if [ -n "$cutoff" ] && [ "$cutoff" -lt 200 ] 2>/dev/null; then
    echo -e "${YELLOW}WARNING: CUTOFF ($cutoff Ry) seems very low. Recommended >= 280 Ry.${NC}"
    warnings=$((warnings + 1))
  else
    echo -e "${GREEN}OK: CUTOFF set to $cutoff Ry${NC}"
  fi
else
  echo -e "${RED}ERROR: CUTOFF not set in &MGRID.${NC}"
  errors=$((errors + 1))
fi

# 6. Check BASIS_SET_FILE_NAME
if grep -qi "BASIS_SET_FILE_NAME" "$inp_file"; then
  basis_file=$(grep -i "BASIS_SET_FILE_NAME" "$inp_file" | head -1 | awk '{print $2}')
  echo -e "${GREEN}OK: BASIS_SET_FILE_NAME = $basis_file${NC}"
else
  echo -e "${YELLOW}WARNING: BASIS_SET_FILE_NAME not set (will use CP2K default).${NC}"
  warnings=$((warnings + 1))
fi

# 7. Check POTENTIAL_FILE_NAME
if grep -qi "POTENTIAL_FILE_NAME" "$inp_file"; then
  pot_file=$(grep -i "POTENTIAL_FILE_NAME" "$inp_file" | head -1 | awk '{print $2}')
  echo -e "${GREEN}OK: POTENTIAL_FILE_NAME = $pot_file${NC}"
else
  echo -e "${YELLOW}WARNING: POTENTIAL_FILE_NAME not set (will use CP2K default).${NC}"
  warnings=$((warnings + 1))
fi

# 8. Check that each &KIND has both BASIS_SET and POTENTIAL
while read -r line; do
  kind_name=$(echo "$line" | awk '{print $2}')
  found_basis=false
  found_pot=false
  # Look at lines between this &KIND and next &END KIND
  awk -v kind="$kind_name" '
    /^ *&KIND '"$kind_name"'/ {found=1; next}
    found && /^ *&END KIND/ {exit}
    found && /BASIS_SET/ {basis=1}
    found && /POTENTIAL/ {pot=1}
    END {
      if (found && !basis) print "MISSING_BASIS"
      if (found && !pot) print "MISSING_POT"
    }
  ' "$inp_file" | while read -r issue; do
    if [ "$issue" = "MISSING_BASIS" ]; then
      echo -e "${RED}ERROR: &KIND $kind_name missing BASIS_SET.${NC}"
    fi
    if [ "$issue" = "MISSING_POT" ]; then
      echo -e "${RED}ERROR: &KIND $kind_name missing POTENTIAL.${NC}"
    fi
  done
done < <(grep -i "^\s*&KIND\b" "$inp_file")

# 9. Check SCF settings
if grep -qi "EPS_SCF" "$inp_file"; then
  eps_scf=$(grep -i "EPS_SCF" "$inp_file" | head -1 | awk '{print $2}')
  echo -e "${GREEN}OK: EPS_SCF = $eps_scf${NC}"
else
  echo -e "${RED}ERROR: EPS_SCF not set in &SCF.${NC}"
  errors=$((errors + 1))
fi

# 10. Check XC functional
if grep -qi "XC_FUNCTIONAL" "$inp_file"; then
  xc_func=$(grep -i "XC_FUNCTIONAL" "$inp_file" | head -1 | awk '{print $2}')
  echo -e "${GREEN}OK: XC_FUNCTIONAL = $xc_func${NC}"
else
  echo -e "${YELLOW}WARNING: XC_FUNCTIONAL not specified (CP2K will use default).${NC}"
  warnings=$((warnings + 1))
fi

echo ""
echo "============================="

if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
  echo -e "${GREEN}VALID: No errors, no warnings — input looks good.${NC}"
elif [ "$errors" -eq 0 ]; then
  echo -e "${YELLOW}VALID with $warnings warnings. Review warnings above.${NC}"
else
  echo -e "${RED}INVALID: $errors error(s) and $warnings warning(s) found. Fix errors before running CP2K.${NC}"
  exit 1
fi
