#!/usr/bin/env bash
# Validate that POTCAR contains expected pseudopotential entries
# and that ENMAX values are consistent across all species.
# Usage: ./validate-potcar.sh [POTCAR]
# Reads POTCAR in current directory if no argument given.
# Prints "VALID" or "INVALID: <reason>"

set -euo pipefail

potcar_file="${1:-POTCAR}"

if [ ! -f "$potcar_file" ]; then
  echo "INVALID: File '$potcar_file' not found"
  exit 1
fi

# Count number of pseudopotentials by counting "End of Dataset" markers
n_datasets=$(grep -c "End of Dataset" "$potcar_file" || true)

if [ "$n_datasets" -eq 0 ]; then
  echo "INVALID: No 'End of Dataset' markers found. File does not contain valid POTCAR data."
  exit 1
fi

# Extract element names from TITEL lines
echo "Found $n_datasets pseudopotential(s):"
grep "TITEL" "$potcar_file" | sed 's/.*TITEL\s*=\s*//'

# Extract VRHFIN (atomic species) lines -- these identify each element
echo ""
echo "Atomic species (VRHFIN):"
grep "VRHFIN" "$potcar_file" | sed 's/.*VRHFIN\s*=\s*//' | tr -d ' '

# Extract ENMAX values
echo ""
echo "ENMAX values (eV):"
enmax_values=$(grep "ENMAX" "$potcar_file" | sed 's/.*ENMAX\s*[=;]\s*//' | tr -d '; ')

echo "$enmax_values" | while read -r val; do
  printf "  %s\n" "$val"
done

# Check for VRHFIN uniqueness (no duplicate elements)
vrkhfin_lines=$(grep "VRHFIN" "$potcar_file" | sed 's/.*VRHFIN\s*=\s*//' | tr -d ' ')
duplicates=$(echo "$vrkhfin_lines" | tr ' ' '\n' | sort | uniq -d)

if [ -n "$duplicates" ]; then
  echo ""
  echo "WARNING: Duplicate atomic species found:"
  echo "$duplicates"
  echo "This may indicate incorrect POTCAR concatenation (same element twice)."
fi

# Check each dataset has a reasonable file size
echo ""
echo "File size: $(wc -c < "$potcar_file") bytes"
echo "Average per dataset: $(( $(wc -c < "$potcar_file") / n_datasets )) bytes"

# Overall validation
all_lines_ok=true

# ENMAX values must be positive numbers
while read -r val; do
  if [ -z "$val" ]; then
    continue
  fi
  if ! echo "$val" | grep -qE '^[0-9]+\.?[0-9]*$'; then
    echo ""
    echo "WARNING: Non-numeric ENMAX value: '$val'"
    all_lines_ok=false
  fi
done < <(grep "ENMAX" "$potcar_file" | sed 's/.*ENMAX\s*[=;]\s*//' | tr -d '; ')

if [ "$all_lines_ok" = true ] && [ "$n_datasets" -ge 1 ]; then
  echo ""
  echo "VALID: $potcar_file contains $n_datasets pseudopotential(s)"
  echo "Suggested ENCUT (1.3x max ENMAX):"
  max_enmax=$(grep "ENMAX" "$potcar_file" | sed 's/.*ENMAX\s*[=;]\s*//' | tr -d '; ' | sort -n | tail -1)
  min_encut=$(echo "$max_enmax * 1.3" | bc -l 2>/dev/null || python3 -c "print($max_enmax * 1.3)" 2>/dev/null || echo "$max_enmax * 1.3 (install bc or python for precise calc)")
  echo "  max(ENMAX) = $max_enmax eV"
  echo "  ENCUT >= $min_encut eV  (1.3x)"
  echo "  ENCUT >= $(echo "$max_enmax * 1.5" | bc -l 2>/dev/null || python3 -c "print($max_enmax * 1.5)" 2>/dev/null || echo "$max_enmax * 1.5 (precise)") eV  (1.5x for precise)"
else
  echo ""
  echo "INVALID: Issues found in $potcar_file"
  exit 1
fi
