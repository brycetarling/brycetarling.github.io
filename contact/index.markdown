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
