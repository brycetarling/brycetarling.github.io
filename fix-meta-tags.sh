#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash fix-meta-tags.sh
#
# Fixes: <title> and meta description tags were referencing page.title and
# page.description, which don't match your actual front matter field names
# (page_title and meta_description). Every page was silently falling back
# to the generic site-wide title/description instead of the one you wrote
# for that specific page.

set -e
f="_layouts/default.html"

if [ ! -f "$f" ]; then
  echo "ERROR: $f not found — run this from the repo root."
  exit 1
fi

if grep -q '{{ page.page_title' "$f"; then
  echo "  · already fixed, skipped"
else
  sed -i.bak \
    -e 's#<title>{{ page.title }}{% if page.title %} — {% endif %}{{ site.title }}</title>#<title>{{ page.page_title | default: page.title | default: site.title }}</title>#' \
    -e 's#<meta name="description" content="{{ page.description | default: site.description }}">#<meta name="description" content="{{ page.meta_description | default: site.description }}">#' \
    "$f"
  rm -f "${f}.bak"
  echo "  ✓ fixed $f"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Fix title/meta description to use actual per-page front matter fields\" && git push"
