#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash fix-case-study-page.sh
#
# Fixes on case study pages:
#  - Removes the duplicate category label (was showing in both the
#    breadcrumb AND as a kicker above the H1)
#  - Adds top spacing so the H1/sidebar aren't flush against the breadcrumb
#  - Removes the horizontal rule + "Sample" label above the CTA button
#    (the anon-note box and meta-label already did that job; this was
#    double-signposting)
#  - Adds space below the CTA button before the prev/next pager
#  - Adds the same sample link to the sidebar as a small text link

set -e
echo "Applying case study page fixes..."

mkdir -p _layouts
cat > _layouts/case-study.html << 'EOF'
---
layout: default
---
{% assign cat = site.data.categories | where: "slug", page.category | first %}
{% assign path_parts = page.path | split: '/' %}
{% assign slug = path_parts | last | remove: '.md' %}
{% assign sample = page.sample_url %}

<div class="breadcrumb wrap">
  <a href="{{ '/portfolio/' | relative_url }}">Portfolio</a> / {{ cat.label | default: page.category }}
</div>

<article class="wrap">
  <div class="case-layout">
    <div>
      <h1 class="h-case">{{ page.title }}</h1>
      {% if page.deck %}<p class="deck">{{ page.deck }}</p>{% endif %}

      {% if page.cover_image %}
      <figure class="case-lead {% if page.cover_orientation == 'portrait' %}is-portrait{% endif %}">
        <img src="{{ '/assets/images/case-studies/' | append: slug | append: '-cover.' | append: page.cover_ext | relative_url }}" alt="{{ page.image_alt | default: page.title | escape }}">
        {% if page.cover_caption %}<figcaption>{{ page.cover_caption }}</figcaption>{% endif %}
      </figure>
      {% endif %}
    </div>

    <aside class="case-rail">
      {% if page.attribution %}
      <div>
        <span class="meta-label">Credited to</span>
        <p>{{ page.attribution }}</p>
      </div>
      {% endif %}

      {% if page.year %}
      <div>
        <span class="meta-label">Year</span>
        <p>{{ page.year }}</p>
      </div>
      {% endif %}

      {% if page.role %}
      <div>
        <span class="meta-label">Role</span>
        <p>{{ page.role }}</p>
      </div>
      {% endif %}

      {% if sample == '/contact/' %}
      <div>
        <span class="meta-label">Sample</span>
        <p><a href="{{ sample | relative_url }}">Get in touch →</a></p>
      </div>
      {% elsif sample contains '/assets/' %}
      <div>
        <span class="meta-label">Sample</span>
        <p><a href="{{ sample | relative_url }}" target="_blank" rel="noopener">Download the sample →</a></p>
      </div>
      {% elsif sample %}
      <div>
        <span class="meta-label">Sample</span>
        <p><a href="{{ sample }}" target="_blank" rel="noopener">View the published piece →</a></p>
      </div>
      {% endif %}
    </aside>
  </div>

  <div class="prose">
    {{ content }}
  </div>

  {% if sample == '/contact/' %}
  <div class="anon-note">
    <p>Client, author, and publication withheld by agreement. Process and role are described in full above; samples available on request.</p>
  </div>
  <a href="{{ sample | relative_url }}" class="btn btn-secondary" style="margin-bottom: 32px;">Get in touch →</a>
  {% elsif sample contains '/assets/' %}
  <a href="{{ sample | relative_url }}" class="btn btn-secondary" target="_blank" rel="noopener" style="margin-bottom: 32px;">Download the sample →</a>
  {% elsif sample %}
  <a href="{{ sample }}" class="btn btn-secondary" target="_blank" rel="noopener" style="margin-bottom: 32px;">View the published piece →</a>
  {% endif %}

  <div class="case-pager">
    {% if page.previous %}
    <a href="{{ page.previous.url | relative_url }}">
      <span class="meta-label">← Previous</span>
      <span>{{ page.previous.title }}</span>
    </a>
    {% else %}<span></span>{% endif %}

    {% if page.next %}
    <a href="{{ page.next.url | relative_url }}">
      <span class="meta-label">Next →</span>
      <span>{{ page.next.title }}</span>
    </a>
    {% endif %}
  </div>
</article>
EOF
echo "  ✓ _layouts/case-study.html"

# Add top spacing to case-layout in main.css (idempotent)
f="assets/css/main.css"
if [ -f "$f" ] && ! grep -q '.case-layout { display: grid; grid-template-columns: 1fr var(--rail); gap: 56px; align-items: start; margin-top: 44px; }' "$f"; then
  if grep -q '.case-layout { display: grid; grid-template-columns: 1fr var(--rail); gap: 56px; align-items: start; }' "$f"; then
    sed -i.bak 's/\.case-layout { display: grid; grid-template-columns: 1fr var(--rail); gap: 56px; align-items: start; }/.case-layout { display: grid; grid-template-columns: 1fr var(--rail); gap: 56px; align-items: start; margin-top: 44px; }/' "$f"
    rm -f "${f}.bak"
    echo "  ✓ assets/css/main.css (added top spacing)"
  else
    echo "  ! could not find expected .case-layout rule in main.css — check manually"
  fi
else
  echo "  · assets/css/main.css already has the spacing fix, skipped"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Clean up case study page: remove duplicate category label, tighten spacing, add sidebar sample link\" && git push"
