# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require 'json'

module Craze
  module Commands
    class Init
      def initialize(dir, options)
        @dir = File.expand_path(dir)
        @options = options
      end

      def run
        puts "Creating new Craze project in #{@dir}..."

        create_directories
        create_config
        create_content
        create_templates
        create_readme

        create_frontend_structure if @options[:with_vite]

        puts 'Done! Your Craze project is ready.'
        puts ''
        puts 'Next steps:'
        puts "  cd #{File.basename(@dir)}"
        puts '  cd frontend && npm install && cd ..' if @options[:with_vite]
        puts '  craze dev'
      end

      private

      def create_directories
        dirs = %w[content content/posts templates templates/layouts templates/pages assets data]
        dirs.each do |dir|
          FileUtils.mkdir_p(File.join(@dir, dir))
        end
      end

      def create_config
        config = base_config
        add_vite_config(config) if @options[:with_vite]
        File.write(File.join(@dir, 'craze.yml'), YAML.dump(config))
      end

      def base_config
        {
          'site' => {
            'title' => 'My Craze Site',
            'url' => 'https://example.com',
            'language' => 'en'
          },
          'build' => {
            'out_dir' => 'dist',
            'base_path' => '/',
            'clean' => true
          },
          'content' => {
            'dir' => 'content',
            'collections' => {
              'posts' => {
                'pattern' => 'posts/**/*.md',
                'permalink' => '/posts/:slug/'
              }
            }
          },
          'templates' => {
            'dir' => 'templates'
          },
          'assets' => {
            'dir' => 'assets',
            'passthrough' => ['assets/static']
          },
          'integrations' => %w[sitemap rss search_index]
        }
      end

      def add_vite_config(config)
        config['frontend'] = {
          'mode' => 'vite',
          'root' => 'frontend',
          'dev_server' => { 'url' => 'http://localhost:5173' },
          'build' => {
            'command' => 'npm run build',
            'out_dir' => 'frontend/dist',
            'public_base' => '/'
          },
          'copy_to' => { 'dir' => 'dist/assets', 'strategy' => 'copy' },
          'manifest' => { 'path' => 'frontend/dist/.vite/manifest.json' }
        }
        config['integrations'] << 'vite_assets'
      end

      def create_content
        index_content = <<~MARKDOWN
          ---
          title: Welcome to Craze
          layout: default
          ---

          # Welcome to Craze

          This is your new static site powered by Craze.

          ## Getting Started

          Edit this file at `content/index.md` to customize your homepage.

          Check out your [first post](/posts/hello/).
        MARKDOWN

        File.write(File.join(@dir, 'content', 'index.md'), index_content)

        hello_post = <<~MARKDOWN
          ---
          title: Hello, World!
          date: #{Time.now.strftime('%Y-%m-%d')}
          tags: [ruby, craze]
          layout: default
          ---

          # Hello, World!

          This is your first blog post. Welcome to Craze!

          ## What is Craze?

          Craze is a modern static site generator written in Ruby. It features:

          - Markdown content with YAML front matter
          - ERB templates
          - Incremental builds
          - Live reload during development
          - Vite and Tailwind CSS integration
        MARKDOWN

        File.write(File.join(@dir, 'content', 'posts', 'hello.md'), hello_post)
      end

      def create_templates
        default_layout = <<~ERB
          <!DOCTYPE html>
          <html lang="<%= site["language"] || "en" %>">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title><%= page["title"] %> | <%= site["title"] %></title>
            #{vite_head_tags if @options[:with_vite]}
          </head>
          <body>
            <header>
              <nav>
                <a href="<%= url_for("/") %>"><%= site["title"] %></a>
              </nav>
            </header>
            <main>
              <%= page["content"] %>
            </main>
            <footer>
              <p>&copy; <%= Time.now.year %> <%= site["title"] %></p>
            </footer>
          </body>
          </html>
        ERB

        File.write(File.join(@dir, 'templates', 'layouts', 'default.html.erb'), default_layout)

        page_template = <<~ERB
          <%= page["content"] %>
        ERB

        File.write(File.join(@dir, 'templates', 'pages', 'page.html.erb'), page_template)
      end

      def vite_head_tags
        <<~ERB.strip
          <%= vite_client_tag %>
              <%= vite_js_tag("src/main.ts") %>
        ERB
      end

      def create_readme
        readme = <<~MARKDOWN
          # My Craze Site

          A static site built with [Craze](https://github.com/ydah/craze).

          ## Development

          ```bash
          craze dev
          ```

          ## Build

          ```bash
          craze build
          ```

          The output will be in the `dist/` directory.
        MARKDOWN

        File.write(File.join(@dir, 'README.md'), readme)
      end

      def create_frontend_structure
        frontend_dir = File.join(@dir, 'frontend')
        FileUtils.mkdir_p(File.join(frontend_dir, 'src'))

        create_package_json(frontend_dir)
        create_vite_config(frontend_dir)
        create_tailwind_config(frontend_dir)
        create_postcss_config(frontend_dir)
        create_frontend_source_files(frontend_dir)
      end

      def create_package_json(frontend_dir)
        package_json = {
          'name' => 'craze-frontend',
          'private' => true,
          'type' => 'module',
          'scripts' => {
            'dev' => 'vite',
            'build' => 'vite build',
            'preview' => 'vite preview'
          },
          'devDependencies' => {
            'autoprefixer' => '^10.4.20',
            'postcss' => '^8.4.49',
            'tailwindcss' => '^3.4.17',
            'typescript' => '^5.7.2',
            'vite' => '^6.0.7'
          }
        }
        File.write(File.join(frontend_dir, 'package.json'), JSON.pretty_generate(package_json))
      end

      def create_vite_config(frontend_dir)
        vite_config = <<~JS
          import { defineConfig } from 'vite'

          export default defineConfig({
            build: {
              manifest: true,
              rollupOptions: {
                input: 'src/main.ts',
              },
            },
          })
        JS
        File.write(File.join(frontend_dir, 'vite.config.ts'), vite_config)
      end

      def create_tailwind_config(frontend_dir)
        tailwind_config = <<~JS
          /** @type {import('tailwindcss').Config} */
          export default {
            content: ['../templates/**/*.erb', '../content/**/*.md'],
            theme: {
              extend: {},
            },
            plugins: [],
          }
        JS
        File.write(File.join(frontend_dir, 'tailwind.config.js'), tailwind_config)
      end

      def create_postcss_config(frontend_dir)
        postcss_config = <<~JS
          export default {
            plugins: {
              tailwindcss: {},
              autoprefixer: {},
            },
          }
        JS
        File.write(File.join(frontend_dir, 'postcss.config.js'), postcss_config)
      end

      def create_frontend_source_files(frontend_dir)
        main_ts = <<~TS
          import './styles.css'

          console.log('Craze + Vite is ready!')
        TS
        File.write(File.join(frontend_dir, 'src', 'main.ts'), main_ts)

        styles_css = <<~CSS
          @tailwind base;
          @tailwind components;
          @tailwind utilities;

          body {
            @apply bg-gray-50 text-gray-900;
          }

          main {
            @apply max-w-4xl mx-auto px-4 py-8;
          }
        CSS
        File.write(File.join(frontend_dir, 'src', 'styles.css'), styles_css)
      end
    end
  end
end
