#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash fix-alt-escaping.sh
#
# Fixes: alt text containing a literal quote mark (like the tombstone image's
# alt text) was breaking the <img> tag's HTML, because the quote inside the
# alt text wasn't being escaped. Adds Liquid's `escape` filter everywhere
# alt text gets inserted into an attribute, so this can't happen again on
# any future case study either.

set -e

for f in portfolio/index.markdown index.markdown; do
  [ -f "$f" ] || continue
  if grep -q 'alt="{{ item.image_alt | default: item.title }}"' "$f"; then
    sed -i.bak 's/alt="{{ item.image_alt | default: item.title }}"/alt="{{ item.image_alt | default: item.title | escape }}"/' "$f"
    rm -f "${f}.bak"
    echo "  ✓ fixed $f"
  else
    echo "  · $f already fixed or pattern not found, skipped"
  fi
done

f="_layouts/case-study.html"
if [ -f "$f" ] && grep -q 'alt="{{ page.image_alt | default: page.title }}"' "$f"; then
  sed -i.bak 's/alt="{{ page.image_alt | default: page.title }}"/alt="{{ page.image_alt | default: page.title | escape }}"/' "$f"
  rm -f "${f}.bak"
  echo "  ✓ fixed $f"
else
  echo "  · $f already fixed or pattern not found, skipped"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Escape alt text to prevent quote marks breaking img tags\" && git push"
