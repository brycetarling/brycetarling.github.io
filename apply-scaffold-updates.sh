#!/usr/bin/env bash
# Run this from the ROOT of your brycetarling.github.io repo:
#   bash apply-scaffold-updates.sh
#
# What it does:
#  - Adds cover_ext + featured front matter fields to the case study files
#  - Rewrites case-study.html layout (fixes cover path, attribution display,
#    sample button logic; removes dead Skills/Published sections)
#  - Rewrites portfolio/index.markdown as a real Liquid loop over 5 categories
#  - Rewrites index.markdown (Home) with hero markup + featured work loop
#  - Rewrites about/index.markdown with the about-layout grid + portrait
#  - Rewrites contact/index.markdown with the JS-obfuscated mailto link
#  - Adds _data/categories.yml (category slug -> display label, in order)
#  - Adds assets/js/nav.js and wires up the mobile hamburger toggle
#
# Safe to re-run. Review the diff with `git diff` before committing.

set -e
echo "Applying scaffold updates..."

mkdir -p _data
cat > _data/categories.yml << 'EOF'
- slug: blog-post
  label: "Blog post"
- slug: research-and-reporting
  label: "Research and reporting"
- slug: customer-stories
  label: "Customer stories"
- slug: downloadable-content
  label: "Downloadable content"
- slug: ghostwriting
  label: "Ghostwriting"
EOF
echo "  ✓ _data/categories.yml"

# 2. Add cover_ext + featured fields to case study front matter
cd _case_studies 2>/dev/null || { echo "ERROR: _case_studies/ not found — run this from the repo root."; exit 1; }

# insert_after <file> <exact line to match> <new line to insert after it>
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

set_cover_ext() {
  slug="$1"; ext="$2"; f="${slug}.md"
  [ -f "$f" ] || return 0
  grep -q "^cover_ext:" "$f" || insert_after "$f" "cover_image: true" "cover_ext: \"${ext}\""
}

set_cover_ext "7-steps-easier-billing" webp
set_cover_ext "almazan" webp
set_cover_ext "client-intake-checklist" webp
set_cover_ext "clients-using-ai" webp
set_cover_ext "death-of-the-billable-hour" webp
set_cover_ext "ltr-2025" webp
set_cover_ext "shadow-it" webp
set_cover_ext "solo-ltr-2026" webp
set_cover_ext "harvey-jacob" png
set_cover_ext "ltr-hourly-rates" png
set_cover_ext "runkle" png
echo "  ✓ cover_ext added to case study front matter"

for slug in ltr-2025 almazan clients-using-ai ghostwriting; do
  f="${slug}.md"
  [ -f "$f" ] || continue
  if ! grep -q "^featured:" "$f"; then
    order_line=$(grep "^order:" "$f")
    insert_after "$f" "$order_line" "featured: true"
  fi
done
echo "  ✓ featured: true added to 4 homepage picks (edit any file's 'featured' line to change which show)"

cd ..

# 3. Case study layout template
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
      <p class="kicker">{{ cat.label | default: page.category }}</p>
      <h1 class="h-case">{{ page.title }}</h1>
      {% if page.deck %}<p class="deck">{{ page.deck }}</p>{% endif %}

      {% if page.cover_image %}
      <figure class="case-lead {% if page.cover_orientation == 'portrait' %}is-portrait{% endif %}">
        <img src="{{ '/assets/images/case-studies/' | append: slug | append: '-cover.' | append: page.cover_ext | relative_url }}" alt="{{ page.image_alt | default: page.title }}">
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
    </aside>
  </div>

  <div class="prose">
    {{ content }}
  </div>

  {% if sample == '/contact/' %}
  <div class="anon-note">
    <p>Client, author, and publication withheld by agreement. Process and role are described in full above; samples available on request.</p>
  </div>
  <div class="rule" style="margin-bottom: 20px;"></div>
  <a href="{{ sample | relative_url }}" class="btn btn-secondary">Get in touch →</a>
  {% elsif sample contains '/assets/' %}
  <div class="rule" style="margin-bottom: 20px;"></div>
  <p class="meta-label" style="margin-bottom: 10px;">Sample</p>
  <a href="{{ sample | relative_url }}" class="btn btn-secondary" target="_blank" rel="noopener">Download the sample →</a>
  {% elsif sample %}
  <div class="rule" style="margin-bottom: 20px;"></div>
  <p class="meta-label" style="margin-bottom: 10px;">Sample</p>
  <a href="{{ sample }}" class="btn btn-secondary" target="_blank" rel="noopener">View the published piece →</a>
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

# 4. Portfolio index
mkdir -p portfolio
cat > portfolio/index.markdown << 'EOF'
---
layout: default
title: "Portfolio"
page_title: "Bryce Tarling | Portfolio"
meta_description: "Browse writing samples for blog posts, research reporting, customer stories, downloadable content, ghostwriting, and more."
permalink: /portfolio/
---
<p class="kicker">Portfolio</p>
<h1 class="h-page">Writing samples</h1>
<p class="page-intro" style="margin-bottom:48px;">With ten years working for a high-growth tech company, I've created copy for many key business functions, including content marketing, demand generation, video scripts, and customer marketing and communications.</p>

{% for cat in site.data.categories %}
  {% assign items = site.case_studies | where: "category", cat.slug | sort: "order" %}
  {% if items.size > 0 %}
  <div class="group-head"{% unless forloop.first %} style="margin-top:48px;"{% endunless %}>
    <span class="group-num">{% if forloop.index < 10 %}0{{ forloop.index }}{% else %}{{ forloop.index }}{% endif %}</span>
    <h2 class="h-group">{{ cat.label }}</h2>
  </div>
  {% for item in items %}
  {% assign path_parts = item.path | split: '/' %}
  {% assign slug = path_parts | last | remove: '.md' %}
  <div class="work-item">
    <div class="work-thumb">
      {% if item.cover_image %}
      <img src="{{ '/assets/images/case-studies/' | append: slug | append: '-cover.' | append: item.cover_ext | relative_url }}" alt="{{ item.image_alt | default: item.title }}">
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
  {% endif %}
{% endfor %}

<p class="page-intro" style="margin-top:48px;">Looking for something else? <a href="{{ '/contact/' | relative_url }}">Reach out</a> for additional writing samples.</p>
EOF
echo "  ✓ portfolio/index.markdown"

# 5. Home page
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
<a href="{{ item.url | relative_url }}" class="work-item">
  <div class="work-thumb">
    {% if item.cover_image %}
    <img src="{{ '/assets/images/case-studies/' | append: slug | append: '-cover.' | append: item.cover_ext | relative_url }}" alt="{{ item.image_alt | default: item.title }}">
    {% else %}
    <div class="no-cover">no cover{% if item.category == 'ghostwriting' %}<br>anon.{% endif %}</div>
    {% endif %}
  </div>
  <div>
    <span class="work-cat">{{ item.year }}</span>
    <span class="work-title">{{ item.title }}</span>
    <span class="work-desc">{{ item.list_summary }}</span>
  </div>
</a>
{% endfor %}
EOF
echo "  ✓ index.markdown (Home)"

# 6. About page
mkdir -p about
cat > about/index.markdown << 'EOF'
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
    <p class="page-intro" style="margin-bottom:40px;">People look to me for a calm and confident voice in executing clear and engaging communications for a variety of audiences and goals.</p>

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

  <figure class="portrait">
    <img src="{{ '/assets/img/portrait.jpg' | relative_url }}" alt="Portrait of Bryce Tarling">
  </figure>
</div>
EOF
echo "  ✓ about/index.markdown"

# 7. Contact page
mkdir -p contact
cat > contact/index.markdown << 'EOF'
---
layout: default
title: "Contact"
page_title: "Bryce Tarling | Contact"
meta_description: "Contact and profile information for Bryce Tarling."
contact_email: "givebrycewords@gmail.com"
---
<p class="kicker">Contact</p>
<h1 class="h-page">Reach out</h1>
<p class="page-intro" style="margin-bottom:40px;">Whether you're working through a list of copy deliverables, want to explore a project, or just want to connect, feel free to reach out.</p>

<div class="contact-list">
  <div class="contact-row">
    <span class="meta-label">Email</span>
    <a href="#" id="contact-email">Loading…</a>
  </div>
  <div class="contact-row">
    <span class="meta-label">LinkedIn</span>
    <a href="https://www.linkedin.com/in/bryce-tarling" target="_blank" rel="noopener">/in/bryce-tarling</a>
  </div>
</div>

<script>
  (function () {
    var user = "{{ page.contact_email | split: '@' | first }}";
    var domain = "{{ page.contact_email | split: '@' | last }}";
    var link = document.getElementById("contact-email");
    if (link) {
      link.href = "mailto:" + user + "@" + domain;
      link.textContent = user + "@" + domain;
    }
  })();
</script>
EOF
echo "  ✓ contact/index.markdown"

# 8. Mobile nav toggle
mkdir -p assets/js
cat > assets/js/nav.js << 'EOF'
document.addEventListener('DOMContentLoaded', function () {
  var toggle = document.getElementById('nav-toggle');
  var nav = document.getElementById('site-nav');
  if (!toggle || !nav) return;

  toggle.addEventListener('click', function () {
    var isOpen = nav.classList.toggle('is-open');
    toggle.setAttribute('aria-expanded', isOpen);
  });

  nav.addEventListener('click', function (e) {
    if (e.target.tagName === 'A') {
      nav.classList.remove('is-open');
      toggle.setAttribute('aria-expanded', 'false');
    }
  });
});
EOF
echo "  ✓ assets/js/nav.js"

# Wire IDs into nav.html (idempotent)
if [ -f _includes/nav.html ] && ! grep -q 'id="nav-toggle"' _includes/nav.html; then
  sed -i.bak 's/<button class="nav-toggle" aria-label="Menu" aria-expanded="false">/<button class="nav-toggle" id="nav-toggle" aria-label="Menu" aria-expanded="false">/' _includes/nav.html
  sed -i.bak 's/<nav class="site-nav">/<nav class="site-nav" id="site-nav">/' _includes/nav.html
  rm -f _includes/nav.html.bak
  echo "  ✓ _includes/nav.html (added toggle/nav IDs)"
else
  echo "  · _includes/nav.html already wired, skipped"
fi

# Wire script tag into default.html (idempotent)
if [ -f _layouts/default.html ] && ! grep -q 'assets/js/nav.js' _layouts/default.html; then
  insert_after "_layouts/default.html" "  {% include footer.html %}" "  <script src=\"{{ '/assets/js/nav.js' | relative_url }}\" defer></script>"
  echo "  ✓ _layouts/default.html (added nav.js script tag)"
else
  echo "  · _layouts/default.html already wired, skipped"
fi

echo
echo "Done. Review changes with:  git diff"
echo "Then:  git add . && git commit -m \"Wire up portfolio loop, fix case study template, rebuild page scaffolds, add nav toggle\" && git push"
