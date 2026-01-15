# frozen_string_literal: true

require 'test_helper'

class RssTest < Minitest::Test
  include TestHelpers

  def test_generates_rss_feed
    with_temp_dir do |_dir|
      FileUtils.mkdir_p('dist')

      post1 = create_post('/posts/first/', 'First Post', Date.new(2026, 1, 10))
      post2 = create_post('/posts/second/', 'Second Post', Date.new(2026, 1, 15))

      collection = Craze::SiteGraph::Collection.new(
        name: 'posts',
        pattern: 'posts/**/*.md',
        permalink: '/posts/:slug/'
      )
      collection.add(post1)
      collection.add(post2)

      integration = Craze::Integrations::RSS.new(
        config: { 'site' => { 'url' => 'https://example.com', 'title' => 'My Blog' } },
        pages: [post1, post2],
        collections: { 'posts' => collection },
        out_dir: 'dist'
      )

      integration.run

      assert_path_exists 'dist/feed.xml'

      content = File.read('dist/feed.xml')

      assert_includes content, '<title>My Blog</title>'
      assert_includes content, 'First Post'
      assert_includes content, 'Second Post'
    end
  end

  private

  def create_post(url, title, date)
    page = Craze::Content::Page.new(
      path: "content/posts/#{title.downcase.tr(' ', '-')}.md",
      front_matter: { 'title' => title, 'date' => date },
      body: '',
      html: "<p>#{title} content</p>"
    )
    page.instance_variable_set(:@url, url)
    page.define_singleton_method(:url) { @url }
    page
  end
end
