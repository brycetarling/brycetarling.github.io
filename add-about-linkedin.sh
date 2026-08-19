#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash add-about-linkedin.sh
#
# Adds a LinkedIn link to the About page sidebar, formatted vertically
# (label above link) matching the case study sidebar style, stacked
# below the portrait photo.

set -e
echo "Adding LinkedIn link to About sidebar..."

f="about/index.markdown"
if [ ! -f "$f" ]; then
  echo "ERROR: $f not found — run this from the repo root."
  exit 1
fi

if grep -q "about-rail" "$f"; then
  echo "  · already added, skipped"
else
  cat > "$f" << 'PAGE_EOF'
---
layout: default
title: "About"
page_title: "Bryce Tarling | About"
meta_description: "Senior writer, editor, and content marketer with 10+ years of experience working in B2B SaaS."
---
<p class="kicker">About</p>
<h1 class="h-page">A bit about me</h1>

<div class="about-layout">
  <div>
    <p class="page-intro" style="margin-bottom:24px;">I'm a senior writer, editor, and content marketer with 10+ years of experience working in B2B SaaS.</p>
    <p class="page-intro" style="margin-bottom:24px;">Skilled at creating compelling, audience-driven editorial content for online, print, and multimedia publications, I'm equally at home developing editorial strategy and executing polished drafts across a broad range of formats, audiences, and channels.</p>
    <p class="page-intro" style="margin-bottom:24px;">People look to me for a calm and confident voice in executing clear and engaging communications for a variety of audiences and goals.</p>

    <a href="{{ '/contact/' | relative_url }}" class="btn btn-secondary" style="margin-bottom:40px;">Get in touch →</a>

    <h2 class="h-group" style="margin-bottom:16px;">Experience</h2>
    <div class="cv" style="margin-bottom:40px;">
      <span class="year">2016–2026</span><span>Content marketer, Clio</span>
      <span class="year">2014–2016</span><span>Technical marketing writer, Reliance Foundry</span>
      <span class="year">2012–2014</span><span>Communications + Managing editor, Canadian Fair Trade Network / Fair Trade Magazine</span>
      <span class="year">2013–2014</span><span>Contract editor, Engineers Without Borders Canada</span>
      <span class="year">2012–2013</span><span>Editorial assistant, Alive Magazine</span>
    </div>

    <h2 class="h-group" style="margin-bottom:16px;">Recognition</h2>
    <div class="cv" style="margin-bottom:40px;">
      <span class="year">2020</span><span>B2B Killer Content Award, B2B Marketing Exchange</span>
    </div>

    <h2 class="h-group" style="margin-bottom:16px;">Education</h2>
    <div class="cv">
      <span class="year"></span><span>Diploma, Professional Writing, Douglas College</span>
      <span class="year"></span><span>B.Ed., Secondary English Education, University of British Columbia</span>
      <span class="year"></span><span>B.A., English, Sociology, University of British Columbia</span>
    </div>
  </div>

  <div class="about-rail">
    <figure class="portrait">
      <img src="{{ '/assets/img/portrait.jpg' | relative_url }}" alt="Portrait of Bryce Tarling">
    </figure>

    <div style="margin-top: 24px;">
      <span class="meta-label">LinkedIn</span>
      <p style="margin: 9px 0 0; font: 400 14.5px/1.5 var(--font-ui);"><a href="https://www.linkedin.com/in/bryce-tarling" target="_blank" rel="noopener">/in/bryce-tarling</a></p>
    </div>
  </div>
</div>
PAGE_EOF
  echo "  ✓ about/index.markdown"
fi

f="assets/css/main.css"
if [ -f "$f" ] && grep -q '.about-layout .portrait { order: -1; max-width: 320px; }' "$f"; then
  sed -i.bak 's/\.about-layout \.portrait { order: -1; max-width: 320px; }/.about-layout .about-rail { order: -1; max-width: 320px; }/' "$f"
  rm -f "${f}.bak"
  echo "  ✓ assets/css/main.css (updated mobile ordering to target new wrapper)"
elif [ -f "$f" ] && grep -q '.about-layout .about-rail' "$f"; then
  echo "  · main.css already updated, skipped"
else
  echo "  ! could not find expected mobile ordering rule in main.css — check manually"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Add LinkedIn link to About sidebar\" && git push"
