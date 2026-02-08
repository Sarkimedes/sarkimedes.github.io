source "https://rubygems.org"
# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#

# This is the default theme for new Jekyll sites. You may change this to anything you like.
gem "minima", "~> 2.5"
# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# 
# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed"#, "~> 0.15.1"
  gem "jekyll-mermaid"
end


# github-pages dependencies - add these temporarily for when we remove the github-pages gem
gem "github-pages-health-check"
gem "jekyll"
gem "jekyll-avatar"
gem "jekyll-coffeescript"
#gem "jekyll-commonmark-ghpages"
gem "jekyll-default-layout"
gem "jekyll-gist"
gem "jekyll-github-metadata"
gem "jekyll-include-cache"
gem "jekyll-mentions"
gem "jekyll-optional-front-matter"
gem "jekyll-paginate"
gem "jekyll-readme-index"
gem "jekyll-redirect-from"
gem "jekyll-relative-links"
gem "jekyll-remote-theme"
gem "jekyll-sass-converter"
gem "jekyll-seo-tag"
gem "jekyll-sitemap"
gem "jekyll-titles-from-headings"
gem "jemoji"
gem "kramdown"
gem "kramdown-parser-gfm", "1.1.0"
gem "liquid"
gem "mercenary"

gem "nokogiri", ">= 1.13.6", "< 2.0"
gem "rouge", "3.26.0"
gem "terminal-table", "~> 1.4"

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :install_if => Gem.win_platform?
gem "webrick", "~> 1.8"
