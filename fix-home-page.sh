#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash fix-home-page.sh
#
# Fixes two things:
#  1. The stray "</a>" text showing under each Home page card. Jekyll's
#     markdown processor (kramdown) treats <a> as an inline element, so
#     wrapping a <div> inside it (like the work-thumb) confuses the parser.
#     Portfolio never had this bug because it wraps each card in a <div>
#     instead — this switches Home to that same, already-working pattern.
#  2. Sets the Home page's featured picks to exactly: clients-using-ai,
#     ltr-2025 (2025 Legal Trends Report), and almazan — removes the
#     featured flag from ghostwriting.md.

set -e
echo "Applying home page fixes..."

# 1. Rewrite index.markdown with the div-based work-item pattern
cat > index.markdown << 'EOF'
---
layout: default
title: "Home"
page_title: "Bryce Tarling"
meta_description: "Bryce Tarling is a writer and editor with 10+ years' experience in marketing communications."
role_line: "Writer • Editor • Content Strategy"
---
<p class="kicker">{{ page.role_line }}</p>
<h1 class="h-hero">Words that work</h1>
<p class="standfirst">Bringing order to chaos. Connecting goals to what gets written.</p>

<div style="display:flex; gap:16px; margin-bottom:56px;">
  <a href="{{ '/portfolio/' | relative_url }}" class="btn btn-primary">Visit Portfolio →</a>
  <a href="{{ '/contact/' | relative_url }}" class="btn btn-secondary">Get in Touch</a>
</div>

<div class="group-head" style="margin-bottom: 4px; justify-content: space-between;">
  <h2 class="h-sect">Selected work</h2>
  <a href="{{ '/portfolio/' | relative_url }}" style="font: 500 11px/1 var(--font-ui); letter-spacing:0.12em; text-transform:uppercase; color:var(--ink-4); text-decoration:none;">All work →</a>
</div>

{% assign featured = site.case_studies | where: "featured", true %}
{% for item in featured %}
{% assign path_parts = item.path | split: '/' %}
{% assign slug = path_parts | last | remove: '.md' %}
<div class="work-item">
  <div class="work-thumb">
    {% if item.cover_image %}
    <img src="{{ '/assets/images/case-studies/' | append: slug | append: '-cover.' | append: item.cover_ext | relative_url }}" alt="{{ item.image_alt | default: item.title | escape }}">
    {% else %}
    <div class="no-cover">no cover{% if item.category == 'ghostwriting' %}<br>anon.{% endif %}</div>
    {% endif %}
  </div>
  <div>
    <span class="work-cat">{{ item.year }}</span>
    <a href="{{ item.url | relative_url }}" class="work-title work-item-link">{{ item.title }}</a>
    <span class="work-desc">{{ item.list_summary }}</span>
  </div>
</div>
{% endfor %}
EOF
echo "  ✓ index.markdown (div-wrapper fix for the stray </a> bug)"

# 2. Remove featured flag from ghostwriting.md
f="_case_studies/ghostwriting.md"
if [ -f "$f" ] && grep -q "^featured: true$" "$f"; then
  tmp="${f}.tmp.$$"
  grep -v "^featured: true$" "$f" > "$tmp"
  mv "$tmp" "$f"
  echo "  ✓ removed featured flag from ghostwriting.md"
else
  echo "  · ghostwriting.md already has no featured flag, skipped"
fi

echo
echo "Home page will now feature exactly: clients-using-ai, ltr-2025, almazan"
echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Fix stray </a> bug on home page, set featured picks to 3\" && git push"
