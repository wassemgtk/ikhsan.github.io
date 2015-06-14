###
# Blog settings
###

## Localisation
activate :i18n, :langs => [:en, :id]

## Syntax Highlighting
activate :syntax
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :deploy do |deploy|
  deploy.method = :git
  deploy.branch = 'master'
end

activate :blog do |blog|
  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.summary_separator = /(READMORE)/
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.prefix = "blog"
  blog.layout = "blog"
  blog.summary_length = 250
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  blog.paginate = true
  blog.per_page = 5
  blog.page_link = "page/{num}"
end

page "/feed.xml", layout: false

###
# Helpers
###

# Reload the browser automatically whenever files change
activate :livereload

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, "img"

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript

  # Use relative URLs
  activate :relative_assets
end
