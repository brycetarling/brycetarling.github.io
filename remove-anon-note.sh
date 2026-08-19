#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash remove-anon-note.sh
#
# Removes the "Client, author, and publication withheld..." text box
# from case study pages whose sample link points to /contact/ (currently
# just the Ghostwriting page). The "Get in touch" button stays.

set -e
f="_layouts/case-study.html"

if [ ! -f "$f" ]; then
  echo "ERROR: $f not found — run this from the repo root."
  exit 1
fi

if grep -q 'class="anon-note"' "$f"; then
  tmp="${f}.tmp.$$"
  awk '
    /<div class="anon-note">/ { skip=1 }
    skip && /<\/div>/ { skip=0; next }
    !skip { print }
  ' "$f" > "$tmp"
  mv "$tmp" "$f"
  echo "  ✓ removed anon-note box from $f"
else
  echo "  · anon-note box already removed, skipped"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Remove confidentiality note box from ghostwriting page\" && git push"
