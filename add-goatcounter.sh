#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash add-goatcounter.sh
#
# Adds the GoatCounter tracking snippet to every page, right before the
# closing </body> tag. Cookie-free, ~3.5KB, loads async — no perceptible
# performance impact and no GDPR consent banner needed.

set -e
f="_layouts/default.html"

if [ ! -f "$f" ]; then
  echo "ERROR: $f not found — run this from the repo root."
  exit 1
fi

if grep -q "goatcounter" "$f"; then
  echo "  · GoatCounter snippet already present, skipped"
else
  insert_after() {
    file="$1"; match="$2"; newline="$3"
    tmp="${file}.tmp.$$"
    : > "$tmp"
    inserted=0
    while IFS= read -r line || [ -n "$line" ]; do
      printf '%s\n' "$line" >> "$tmp"
      if [ "$line" = "$match" ] && [ "$inserted" -eq 0 ]; then
        printf '%s\n' "$newline" >> "$tmp"
        inserted=1
      fi
    done < "$file"
    mv "$tmp" "$file"
  }

  insert_after "$f" '  <script src="{{ '"'"'/assets/js/nav.js'"'"' | relative_url }}" defer></script>' '  <script data-goatcounter="https://brycetarling.goatcounter.com/count" async src="//gc.zgo.at/count.js"></script>'
  echo "  ✓ added GoatCounter snippet to $f"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Add GoatCounter analytics\" && git push"
