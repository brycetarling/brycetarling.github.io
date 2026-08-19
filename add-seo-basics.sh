#!/usr/bin/env bash
# Run from the ROOT of your brycetarling.github.io repo:
#   bash add-seo-basics.sh
#
# Adds:
#  - jekyll-sitemap plugin (auto-generates sitemap.xml — officially
#    supported by GitHub Pages, no config needed beyond enabling it)
#  - robots.txt pointing crawlers at the sitemap
#  - Also fixes a pre-existing gap: jekyll-feed was in your Gemfile but
#    never actually listed in _config.yml's "plugins:" array — GitHub
#    Pages' hosted build reads that list (not the Gemfile) to decide
#    what to activate, so the feed plugin likely wasn't running on the
#    live site. Both plugins are now correctly wired up.

set -e
echo "Adding SEO basics..."

# 1. Gemfile
f="Gemfile"
if [ -f "$f" ] && ! grep -q "jekyll-sitemap" "$f"; then
  sed -i.bak '/gem "jekyll-feed", "~> 0.12"/a\
  gem "jekyll-sitemap", "~> 1.4"' "$f"
  rm -f "${f}.bak"
  echo "  ✓ Gemfile"
else
  echo "  · Gemfile already has jekyll-sitemap, skipped"
fi

# 2. _config.yml
f="_config.yml"
if [ -f "$f" ] && ! grep -q "^plugins:" "$f"; then
  cat >> "$f" << 'CONF_EOF'

plugins:
  - jekyll-feed
  - jekyll-sitemap
CONF_EOF
  echo "  ✓ _config.yml (added plugins list)"
elif [ -f "$f" ] && grep -q "^plugins:" "$f" && ! grep -q "jekyll-sitemap" "$f"; then
  echo "  ! _config.yml already has a plugins: list but no jekyll-sitemap — add it manually to be safe"
else
  echo "  · _config.yml already configured, skipped"
fi

# 3. robots.txt
f="robots.txt"
if [ ! -f "$f" ]; then
  cat > "$f" << 'ROBOTS_EOF'
User-agent: *
Allow: /

Sitemap: https://brycetarling.github.io/sitemap.xml
ROBOTS_EOF
  echo "  ✓ robots.txt"
else
  echo "  · robots.txt already exists, skipped"
fi

echo
echo "Done. Review with: git diff"
echo "Then: git add . && git commit -m \"Add sitemap.xml and robots.txt, fix jekyll-feed plugin activation\" && git push"
echo
echo "After it deploys (may take a minute longer than usual, first build with a new plugin):"
echo "  Check https://brycetarling.github.io/sitemap.xml exists"
echo "  Check https://brycetarling.github.io/robots.txt exists"
