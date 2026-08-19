#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash add-ghostwriting-icon.sh
#
# Replaces the "no cover / anon." text placeholder with a pen nib icon
# (ink-colored box, paper-colored icon) for the Ghostwriting card's
# thumbnail — on the Portfolio index only. The case study page itself
# is untouched (stays text-only, no hero image, as decided).

set -e
echo "Adding ghostwriting thumbnail icon..."

replace_no_cover() {
  f="$1"
  [ -f "$f" ] || return 0
  if grep -q "no-cover-icon" "$f"; then
    echo "  · $f already updated, skipped"
    return 0
  fi

  case "$f" in
    portfolio/index.markdown)
      old='      <div class="no-cover">no cover{% if item.category == '"'"'ghostwriting'"'"' %}<br>anon.{% endif %}</div>'
      indent="      "
      ;;
    index.markdown)
      old='    <div class="no-cover">no cover{% if item.category == '"'"'ghostwriting'"'"' %}<br>anon.{% endif %}</div>'
      indent="    "
      ;;
  esac

  if ! grep -qF "$old" "$f"; then
    echo "  ! expected placeholder line not found in $f — check manually"
    return 0
  fi

  new="${indent}{% if item.category == 'ghostwriting' %}
${indent}<div class=\"no-cover no-cover-icon\">
${indent}  <svg viewBox=\"0 0 24 28\" aria-hidden=\"true\">
${indent}    <path d=\"M12 2 L17 12 L13.2 17 L13.2 19.5 L10.8 19.5 L10.8 17 L7 12 Z\" fill=\"var(--paper)\"/>
${indent}    <rect x=\"10\" y=\"19.5\" width=\"4\" height=\"6\" fill=\"var(--paper)\"/>
${indent}    <line x1=\"12\" y1=\"5\" x2=\"12\" y2=\"17\" stroke=\"var(--ink)\" stroke-width=\"1.1\"/>
${indent}    <circle cx=\"12\" cy=\"12.5\" r=\"1.3\" fill=\"var(--ink)\"/>
${indent}  </svg>
${indent}</div>
${indent}{% else %}
${indent}<div class=\"no-cover\">no cover</div>
${indent}{% endif %}"

  tmp="${f}.tmp.$$"
  python3 -c "
import sys
with open('$f') as fh:
    content = fh.read()
old = '''$old'''
new = '''$new'''
content = content.replace(old, new, 1)
with open('$tmp', 'w') as fh:
    fh.write(content)
"
  mv "$tmp" "$f"
  echo "  ✓ $f"
}

replace_no_cover "portfolio/index.markdown"
replace_no_cover "index.markdown"

f="assets/css/main.css"
if [ -f "$f" ] && ! grep -q "no-cover-icon" "$f"; then
  old='.work-thumb .no-cover {
  height: 104px; width: 104px;
  background: var(--surface); border: 1px solid rgba(32,30,29,0.3);
  display: flex; align-items: center; justify-content: center; text-align: center;
  font: 400 8.5px/1.3 var(--font-mono); color: var(--ink-4);
}'
  new='.work-thumb .no-cover {
  height: 104px; width: 104px;
  background: var(--surface); border: 1px solid rgba(32,30,29,0.3);
  display: flex; align-items: center; justify-content: center; text-align: center;
  font: 400 8.5px/1.3 var(--font-mono); color: var(--ink-4);
}
.work-thumb .no-cover-icon { background: var(--ink); }
.work-thumb .no-cover-icon svg { width: 30px; height: auto; }'
  python3 -c "
with open('$f') as fh:
    content = fh.read()
old = '''$old'''
new = '''$new'''
if old not in content:
    print('  ! expected .no-cover CSS block not found — check manually')
else:
    content = content.replace(old, new, 1)
    with open('$f', 'w') as fh:
        fh.write(content)
    print('  ✓ assets/css/main.css')
"
else
  echo "  · assets/css/main.css already updated, skipped"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Add nib icon for ghostwriting thumbnail on portfolio index\" && git push"
