# frozen_string_literal: true

require 'test_helper'

class SearchIndexTest < Minitest::Test
  include TestHelpers

  def test_generates_search_index
    with_temp_dir do |_dir|
      FileUtils.mkdir_p('dist')

      pages = [
        create_page('/', 'Home', %w[welcome]),
        create_page('/about/', 'About', [])
      ]

      integration = Craze::Integrations::SearchIndex.new(
        config: {},
        pages: pages,
        collections: {},
        out_dir: 'dist'
      )

      integration.run

      assert_path_exists 'dist/search.json'

      content = File.read('dist/search.json')
      index = JSON.parse(content)

      assert_equal 2, index.size
      assert_equal 'Home', index[0]['title']
      assert_equal '/', index[0]['url']
      assert_equal %w[welcome], index[0]['tags']
    end
  end

  private

  def create_page(url, title, tags)
    page = Craze::Content::Page.new(
      path: "content/#{title.downcase}.md",
      front_matter: { 'title' => title, 'tags' => tags },
      body: '',
      html: "<p>#{title} content</p>"
    )
    page.instance_variable_set(:@url, url)
    page.define_singleton_method(:url) { @url }
    page
  end
end
