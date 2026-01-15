# frozen_string_literal: true

require_relative 'base'

module Craze
  module Integrations
    class Sitemap < Base
      def run
        xml = build_sitemap
        write_file('sitemap.xml', xml)
      end

      private

      def build_sitemap
        urls = @pages.map { |page| url_entry(page) }.join("\n")

        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          #{urls}
          </urlset>
        XML
      end

      def url_entry(page)
        loc = "#{site_url.chomp('/')}#{page.url}"
        lastmod = page.date&.strftime('%Y-%m-%d') || Time.now.strftime('%Y-%m-%d')

        <<~XML.strip
          <url>
            <loc>#{escape_xml(loc)}</loc>
            <lastmod>#{lastmod}</lastmod>
          </url>
        XML
      end

      def escape_xml(text)
        text.to_s
            .gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
            .gsub("'", '&apos;')
      end
    end
  end
end
