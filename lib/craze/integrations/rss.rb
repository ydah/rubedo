# frozen_string_literal: true

require_relative 'base'

module Craze
  module Integrations
    class RSS < Base
      def run
        posts = find_posts
        return if posts.empty?

        xml = build_feed(posts)
        write_file('feed.xml', xml)
      end

      private

      def find_posts
        posts_collection = @collections['posts']
        return [] unless posts_collection

        posts_collection.sorted_by_date.first(20)
      end

      def build_feed(posts)
        items = posts.map { |post| item_entry(post) }.join("\n")
        site_title = @config.dig('site', 'title') || 'My Site'

        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
          <channel>
            <title>#{escape_xml(site_title)}</title>
            <link>#{site_url}</link>
            <description>#{escape_xml(site_title)} RSS Feed</description>
            <atom:link href="#{site_url}/feed.xml" rel="self" type="application/rss+xml"/>
            <lastBuildDate>#{Time.now.rfc2822}</lastBuildDate>
          #{items}
          </channel>
          </rss>
        XML
      end

      def item_entry(post)
        link = "#{site_url.chomp('/')}#{post.url}"
        pub_date = post.date ? Time.new(post.date.year, post.date.month, post.date.day).rfc2822 : Time.now.rfc2822

        <<~XML
          <item>
            <title>#{escape_xml(post.title || post.slug)}</title>
            <link>#{escape_xml(link)}</link>
            <guid>#{escape_xml(link)}</guid>
            <pubDate>#{pub_date}</pubDate>
            <description>#{escape_xml(strip_html(post.html)[0, 300])}</description>
          </item>
        XML
      end

      def strip_html(html)
        html.to_s.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip
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
