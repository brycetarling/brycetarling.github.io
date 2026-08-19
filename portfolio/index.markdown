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
  {% endif %}
{% endfor %}

<p class="page-intro" style="margin-top:48px;">Looking for something else? <a href="{{ '/contact/' | relative_url }}">Reach out</a> for additional writing samples.</p>
