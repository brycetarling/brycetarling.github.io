#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash fix-pager-order.sh
#
# Bug found in QA: the Previous/Next pager at the bottom of case study
# pages used Jekyll's built-in page.previous/page.next, which follows
# the collection's default order — alphabetical by filename. That meant
# clicking "Next" jumped between unrelated categories (e.g. from a
# downloadable-content piece to a customer story to another
# downloadable-content piece), not matching the category grouping shown
# on the Portfolio index.
#
# This computes prev/next from the same category+order sequence the
# Portfolio page displays, so clicking through case studies follows a
# sensible reading order.

set -e
f="_layouts/case-study.html"

if [ ! -f "$f" ]; then
  echo "ERROR: $f not found — run this from the repo root."
  exit 1
fi

if grep -q "assign ordered" "$f"; then
  echo "  · already fixed, skipped"
else
  python3 -c "
with open('$f') as fh:
    content = fh.read()

old = '''  <div class=\"case-pager\">
    {% if page.previous %}
    <a href=\"{{ page.previous.url | relative_url }}\">
      <span class=\"meta-label\">← Previous</span>
      <span>{{ page.previous.title }}</span>
    </a>
    {% else %}<span></span>{% endif %}

    {% if page.next %}
    <a href=\"{{ page.next.url | relative_url }}\">
      <span class=\"meta-label\">Next →</span>
      <span>{{ page.next.title }}</span>
    </a>
    {% endif %}
  </div>
</article>'''

new = '''  {% assign ordered = \"\" | split: \"\" %}
  {% for cat in site.data.categories %}
    {% assign cat_items = site.case_studies | where: \"category\", cat.slug | sort: \"order\" %}
    {% assign ordered = ordered | concat: cat_items %}
  {% endfor %}
  {% assign current_index = 0 %}
  {% for item in ordered %}
    {% if item.url == page.url %}{% assign current_index = forloop.index0 %}{% endif %}
  {% endfor %}
  {% assign prev_i = current_index | minus: 1 %}
  {% assign next_i = current_index | plus: 1 %}

  <div class=\"case-pager\">
    {% if prev_i >= 0 %}
    {% assign prev_item = ordered[prev_i] %}
    <a href=\"{{ prev_item.url | relative_url }}\">
      <span class=\"meta-label\">← Previous</span>
      <span>{{ prev_item.title }}</span>
    </a>
    {% else %}<span></span>{% endif %}

    {% if next_i < ordered.size %}
    {% assign next_item = ordered[next_i] %}
    <a href=\"{{ next_item.url | relative_url }}\">
      <span class=\"meta-label\">Next →</span>
      <span>{{ next_item.title }}</span>
    </a>
    {% endif %}
  </div>
</article>'''

if old not in content:
    print('  ! expected pager block not found — check manually')
else:
    content = content.replace(old, new, 1)
    with open('$f', 'w') as fh:
        fh.write(content)
    print('  ✓ fixed $f')
"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Fix Previous/Next pager to follow category order instead of alphabetical filename order\" && git push"
