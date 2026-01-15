# frozen_string_literal: true

require 'json'
require_relative 'base'

module Craze
  module Integrations
    class SearchIndex < Base
      def run
        index = build_index
        write_file('search.json', JSON.pretty_generate(index))
      end

      private

      def build_index
        @pages.map do |page|
          {
            'title' => page.title || page.slug,
            'url' => page.url,
            'content' => strip_html(page.html)[0, 500],
            'tags' => page.tags,
            'date' => page.date&.to_s
          }
        end
      end

      def strip_html(html)
        html.to_s.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip
      end
    end
  end
end
