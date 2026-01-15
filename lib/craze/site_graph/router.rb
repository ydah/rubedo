# frozen_string_literal: true

module Craze
  module SiteGraph
    class Router
      PERMALINK_TOKENS = {
        ':slug' => lambda(&:slug),
        ':year' => ->(page) { page.date&.year&.to_s },
        ':month' => ->(page) { format('%02d', page.date&.month || 1) },
        ':day' => ->(page) { format('%02d', page.date&.day || 1) },
        ':title' => ->(page) { slugify(page.title || page.slug) }
      }.freeze

      class << self
        def resolve(page, permalink_pattern)
          url = permalink_pattern.dup

          PERMALINK_TOKENS.each do |token, resolver|
            url.gsub!(token, resolver.call(page).to_s) if url.include?(token)
          end

          normalize_url(url)
        end

        def output_path(url)
          if url.end_with?('/')
            "#{url}index.html"
          elsif url.end_with?('.html')
            url
          else
            "#{url}/index.html"
          end
        end

        private

        def normalize_url(url)
          url = "/#{url}" unless url.start_with?('/')
          url.gsub(%r{/+}, '/')
        end

        def slugify(text)
          return '' if text.nil?

          text.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
        end
      end
    end
  end
end
