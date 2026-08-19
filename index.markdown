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
