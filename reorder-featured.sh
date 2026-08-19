#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash reorder-featured.sh
#
# Adds an explicit featured_order field to the 3 featured case studies so
# Home page order can be controlled directly instead of falling back to
# alphabetical-by-filename. Sets order to: clients-using-ai (1),
# ltr-2025 (2), almazan (3).

set -e
echo "Reordering featured picks..."

cd _case_studies 2>/dev/null || { echo "ERROR: _case_studies/ not found — run this from the repo root."; exit 1; }

set_order() {
  slug="$1"; order="$2"; f="${slug}.md"
  [ -f "$f" ] || return 0
  if grep -q "^featured_order:" "$f"; then
    echo "  · $f already has featured_order, skipped (edit it manually if you want to change the order)"
    return 0
  fi
  tmp="${f}.tmp.$$"
  : > "$tmp"
  while IFS= read -r line || [ -n "$line" ]; do
    printf '%s\n' "$line" >> "$tmp"
    if [ "$line" = "featured: true" ]; then
      printf '%s\n' "featured_order: ${order}" >> "$tmp"
    fi
  done < "$f"
  mv "$tmp" "$f"
  echo "  ✓ $f (featured_order: ${order})"
}

set_order "clients-using-ai" 1
set_order "ltr-2025" 2
set_order "almazan" 3

cd ..

f="index.markdown"
if [ -f "$f" ] && grep -q 'where: "featured", true %}' "$f" && ! grep -q 'sort: "featured_order"' "$f"; then
  sed -i.bak 's/where: "featured", true %}/where: "featured", true | sort: "featured_order" %}/' "$f"
  rm -f "${f}.bak"
  echo "  ✓ index.markdown (sorted by featured_order)"
else
  echo "  · index.markdown already sorted or pattern not found, skipped"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Add explicit ordering for home page featured picks\" && git push"
