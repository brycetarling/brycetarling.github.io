#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash style-404-page.sh
#
# Restyles the 404 page to match the site's actual design system
# (kicker/h-page/page-intro/btn classes) instead of generic default
# Jekyll starter styling. Nav and footer were already rendering here
# (layout: default), this just makes the content match everything
# around it, and adds Back to home / View portfolio links.
#
# Also removes .anon-note and .rule — two CSS classes flagged as dead
# code in QA (no longer referenced anywhere since the confidentiality
# note was removed from the ghostwriting page).

set -e
echo "Styling 404 page and cleaning up dead CSS..."

f="404.html"
if [ -f "$f" ] && grep -q "class=\"kicker\">404" "$f"; then
  echo "  · 404.html already styled, skipped"
else
  cat > "$f" << 'PAGE_EOF'
---
permalink: /404.html
layout: default
title: "Page not found"
page_title: "Page not found | Bryce Tarling"
meta_description: "The page you're looking for doesn't exist."
---
<p class="kicker">404</p>
<h1 class="h-page">Page not found</h1>
<p class="page-intro" style="margin-bottom:40px;">The page you're looking for doesn't exist or may have moved.</p>

<div style="display:flex; gap:16px;">
  <a href="{{ '/' | relative_url }}" class="btn btn-primary">Back to home →</a>
  <a href="{{ '/portfolio/' | relative_url }}" class="btn btn-secondary">View portfolio</a>
</div>
PAGE_EOF
  echo "  ✓ 404.html"
fi

f="assets/css/main.css"
if [ -f "$f" ] && grep -q "^\.rule {" "$f"; then
  python3 -c "
with open('$f') as fh:
    content = fh.read()
old = '''.rule { border: 0; border-top: 2px solid var(--rule); margin: 0; }

/* --- header --------------------------------------------------------------- */'''
new = '''
/* --- header --------------------------------------------------------------- */'''
content = content.replace(old, new, 1)
with open('$f', 'w') as fh:
    fh.write(content)
"
  echo "  ✓ removed dead .rule CSS"
else
  echo "  · .rule already removed, skipped"
fi

if [ -f "$f" ] && grep -q "\.anon-note {" "$f"; then
  python3 -c "
with open('$f') as fh:
    content = fh.read()
old = '''.anon-note {
  margin: 0 0 30px; max-width: 60ch;
  padding: 16px 20px;
  background: var(--surface); border: 2px solid rgba(32,30,29,0.3);
}
.anon-note p { margin: 0; font: 400 15px/1.6 var(--font-ui); color: var(--ink-3); }

.case-pager { display: flex; justify-content: space-between; align-items: baseline; padding-top: 22px; border-top: 2px solid var(--rule); }
.case-pager a { text-decoration: none; color: var(--ink); }'''
new = '''.case-pager { display: flex; justify-content: space-between; align-items: baseline; padding-top: 22px; border-top: 2px solid var(--rule); }
.case-pager a { text-decoration: none; color: var(--ink); }'''
content = content.replace(old, new, 1)
with open('$f', 'w') as fh:
    fh.write(content)
"
  echo "  ✓ removed dead .anon-note CSS"
else
  echo "  · .anon-note already removed, skipped"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Restyle 404 page to match site design system, remove dead CSS\" && git push"
