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

{% assign featured = site.case_studies | where: "featured", true | sort: "featured_order" %}
{% for item in featured %}
{% assign path_parts = item.path | split: '/' %}
{% assign slug = path_parts | last | remove: '.md' %}
<div class="work-item">
  <div class="work-thumb">
    {% if item.cover_image %}
    <img src="{{ '/assets/images/case-studies/' | append: slug | append: '-cover.' | append: item.cover_ext | relative_url }}" alt="{{ item.image_alt | default: item.title | escape }}">
    {% else %}
    {% if item.category == 'ghostwriting' %}
    <div class="no-cover no-cover-icon">
      <svg viewBox="0 0 24 28" aria-hidden="true">
        <path d="M12 2 L17 12 L13.2 17 L13.2 19.5 L10.8 19.5 L10.8 17 L7 12 Z" fill="var(--paper)"/>
        <rect x="10" y="19.5" width="4" height="6" fill="var(--paper)"/>
        <line x1="12" y1="5" x2="12" y2="17" stroke="var(--ink)" stroke-width="1.1"/>
        <circle cx="12" cy="12.5" r="1.3" fill="var(--ink)"/>
      </svg>
    </div>
    {% else %}
    <div class="no-cover">no cover</div>
    {% endif %}
    {% endif %}
  </div>
  <div>
    <span class="work-cat">{{ item.year }}</span>
    <a href="{{ item.url | relative_url }}" class="work-title work-item-link">{{ item.title }}</a>
    <span class="work-desc">{{ item.list_summary }}</span>
  </div>
</div>
{% endfor %}
