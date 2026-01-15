<p align="center">
  <img src="assets/logo-header.svg" alt="craze header logo">
  <p align="center">
    <strong>A modern static site generator for Ruby with Vite/Tailwind integration</strong>
  </p>
  <p align="center">
    <a href="https://rubygems.org/gems/craze"><img src="https://img.shields.io/gem/v/craze.svg?colorB=319e8c" alt="Gem Version"></a>
    <a href="https://rubygems.org/gems/craze"><img src="https://img.shields.io/gem/dt/craze.svg" alt="Downloads"></a>
    <img src="https://img.shields.io/badge/ruby-%3E%3D%203.2-ruby.svg" alt="Ruby Version">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License">
  </p>
</p>

<p align="center">
  <a href="#features">Features</a> ·
  <a href="#installation">Installation</a> ·
  <a href="#quick-start">Quick Start</a> ·
  <a href="#configuration">Configuration</a> ·
  <a href="#how-it-works">How It Works</a> ·
  <a href="#integrations">Integrations</a>
</p>

---

Craze is a static site generator that compiles Markdown content with YAML front matter into a static website using ERB templates. It features incremental builds, live reload during development, and seamless integration with modern frontend tools like Vite and Tailwind CSS.

## Features

<a name="features"></a>

- Markdown content with YAML front matter
- ERB templates with layouts and partials
- Collections (posts, pages, etc.) with custom permalinks
- Incremental builds with file watching
- Live reload during development
- Vite + Tailwind CSS integration
- Extensible integrations (RSS, Sitemap, Search Index)

## Installation

<a name="installation"></a>

Add to your Gemfile:

```ruby
gem 'craze'
```

Then install:

```bash
bundle install
```

### Requirements

<a name="requirements"></a>

- Ruby 3.2+
- Node.js 18+ (for Vite integration)

## Quick Start

<a name="quick-start"></a>

Create a new project:

```bash
craze init mysite
cd mysite
craze dev
```

With Vite + Tailwind:

```bash
craze init mysite --with-vite
cd mysite
cd frontend && npm install && cd ..
craze dev
```

Build for production:

```bash
craze build
```

## Integrations

<a name="integrations"></a>

### Sitemap

Generates `sitemap.xml` with all pages.

### RSS

Generates `feed.xml` for posts collection.

### Search Index

Generates `search.json` for client-side search.

### Vite Assets

Copies Vite build output to dist directory and provides template helpers.

## Configuration

<a name="configuration"></a>

Create `craze.yml` in your project root:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `site.title` | String | `"My Site"` | Site title |
| `site.url` | String | `"https://example.com"` | Site URL |
| `site.language` | String | `"en"` | Site language |
| `build.out_dir` | String | `"dist"` | Output directory |
| `build.base_path` | String | `"/"` | Base path for URLs |
| `build.clean` | Boolean | `true` | Clean output before build |
| `content.dir` | String | `"content"` | Content directory |
| `templates.dir` | String | `"templates"` | Templates directory |
| `assets.dir` | String | `"assets"` | Assets directory |
| `integrations` | Array | `[]` | Enabled integrations |

### Example Configuration

```yaml
site:
  title: "My Blog"
  url: "https://example.com"
  language: "en"

build:
  out_dir: "dist"
  base_path: "/"
  clean: true

content:
  dir: "content"
  collections:
    posts:
      pattern: "posts//*.md"
      permalink: "/posts/:slug/"

templates:
  dir: "templates"

integrations:
  - sitemap
  - rss
  - search_index
```

## How It Works

<a name="how-it-works"></a>

1. Content Discovery scans `content/` for Markdown files
2. Front Matter Parsing extracts YAML metadata from each file
3. Markdown Rendering converts Markdown to HTML using CommonMark
4. Template Rendering applies ERB layouts with page data
5. Integration Execution runs sitemap, RSS, search index generators
6. Output Writing writes HTML files to `dist/`

### Template Helpers

| Helper | Description |
|--------|-------------|
| `url_for(path)` | Generate URL with base path |
| `asset_path(name)` | Generate asset URL |
| `escape_html(text)` | HTML escape |
| `format_date(date, format)` | Format date |

### Vite Helpers

| Helper | Description |
|--------|-------------|
| `vite_client_tag` | Vite HMR client (dev only) |
| `vite_js_tag(entry)` | JavaScript entry point |
| `vite_css_tag(entry)` | CSS entry point |
| `vite_asset_path(entry)` | Get asset path from manifest |

## Development

<a name="development"></a>

```bash
bundle install
bundle exec rake test
bundle exec rubocop
```

## Contributing

<a name="contributing"></a>

Bug reports and pull requests are welcome at https://github.com/ydah/craze.

## License

<a name="license"></a>

Released under the [MIT License](https://opensource.org/licenses/MIT).
