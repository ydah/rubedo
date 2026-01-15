# frozen_string_literal: true

require 'test_helper'

class SitemapTest < Minitest::Test
  include TestHelpers

  def test_generates_sitemap
    with_temp_dir do |_dir|
      FileUtils.mkdir_p('dist')

      pages = [
        create_page('/', 'Home', Date.new(2026, 1, 15)),
        create_page('/about/', 'About', Date.new(2026, 1, 10))
      ]

      integration = Craze::Integrations::Sitemap.new(
        config: { 'site' => { 'url' => 'https://example.com' } },
        pages: pages,
        collections: {},
        out_dir: 'dist'
      )

      integration.run

      assert_path_exists 'dist/sitemap.xml'

      content = File.read('dist/sitemap.xml')

      assert_includes content, 'https://example.com/'
      assert_includes content, 'https://example.com/about/'
      assert_includes content, '2026-01-15'
    end
  end

  private

  def create_page(url, title, date)
    page = Craze::Content::Page.new(
      path: "content/#{title.downcase}.md",
      front_matter: { 'title' => title, 'date' => date },
      body: '',
      html: "<p>#{title}</p>"
    )
    page.instance_variable_set(:@url, url)
    page.define_singleton_method(:url) { @url }
    page
  end
end
