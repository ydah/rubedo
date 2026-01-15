# frozen_string_literal: true

require 'test_helper'

class CollectionTest < Minitest::Test
  def setup
    @collection = Craze::SiteGraph::Collection.new(
      name: 'posts',
      pattern: 'posts/**/*.md',
      permalink: '/posts/:slug/'
    )
  end

  def test_add_page
    page = create_page('First Post', Date.new(2026, 1, 1))
    @collection.add(page)

    assert_equal 1, @collection.pages.size
    assert_equal 'First Post', @collection.pages.first.title
  end

  def test_sorted_by_date_descending
    @collection.add(create_page('Old Post', Date.new(2025, 1, 1)))
    @collection.add(create_page('New Post', Date.new(2026, 1, 1)))
    @collection.add(create_page('Middle Post', Date.new(2025, 6, 1)))

    sorted = @collection.sorted_by_date

    assert_equal 'New Post', sorted[0].title
    assert_equal 'Middle Post', sorted[1].title
    assert_equal 'Old Post', sorted[2].title
  end

  def test_sorted_by_date_ascending
    @collection.add(create_page('Old Post', Date.new(2025, 1, 1)))
    @collection.add(create_page('New Post', Date.new(2026, 1, 1)))

    sorted = @collection.sorted_by_date(descending: false)

    assert_equal 'Old Post', sorted[0].title
    assert_equal 'New Post', sorted[1].title
  end

  def test_by_tag
    @collection.add(create_page('Ruby Post', Date.new(2026, 1, 1), %w[ruby programming]))
    @collection.add(create_page('Go Post', Date.new(2026, 1, 2), %w[go programming]))
    @collection.add(create_page('Ruby Tips', Date.new(2026, 1, 3), ['ruby']))

    ruby_posts = @collection.by_tag('ruby')

    assert_equal 2, ruby_posts.size
    assert_includes ruby_posts.map(&:title), 'Ruby Post'
    assert_includes ruby_posts.map(&:title), 'Ruby Tips'
  end

  def test_all_tags
    @collection.add(create_page('Post 1', Date.new(2026, 1, 1), %w[ruby web]))
    @collection.add(create_page('Post 2', Date.new(2026, 1, 2), %w[go web]))

    tags = @collection.all_tags

    assert_equal %w[go ruby web], tags
  end

  private

  def create_page(title, date, tags = [])
    Craze::Content::Page.new(
      path: "content/posts/#{title.downcase.tr(' ', '-')}.md",
      front_matter: { 'title' => title, 'date' => date, 'tags' => tags },
      body: '',
      html: "<p>#{title}</p>"
    )
  end
end
