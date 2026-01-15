# frozen_string_literal: true

require 'test_helper'

class PageTest < Minitest::Test
  def test_page_attributes
    page = Craze::Content::Page.new(
      path: 'content/posts/hello.md',
      front_matter: {
        'title' => 'Hello World',
        'date' => Date.new(2026, 1, 15),
        'layout' => 'post',
        'tags' => %w[ruby test],
        'draft' => false
      },
      body: '# Hello',
      html: '<h1>Hello</h1>'
    )

    assert_equal 'content/posts/hello.md', page.path
    assert_equal 'Hello World', page.title
    assert_equal Date.new(2026, 1, 15), page.date
    assert_equal 'post', page.layout
    assert_equal %w[ruby test], page.tags
    refute_predicate page, :draft?
    assert_equal 'hello', page.slug
    assert_equal '<h1>Hello</h1>', page.html
  end

  def test_default_layout
    page = Craze::Content::Page.new(
      path: 'test.md',
      front_matter: {},
      body: '',
      html: ''
    )

    assert_equal 'default', page.layout
  end

  def test_draft_page
    page = Craze::Content::Page.new(
      path: 'draft.md',
      front_matter: { 'draft' => true },
      body: '',
      html: ''
    )

    assert_predicate page, :draft?
  end

  def test_bracket_accessor
    page = Craze::Content::Page.new(
      path: 'test.md',
      front_matter: { 'custom_field' => 'custom_value' },
      body: '',
      html: ''
    )

    assert_equal 'custom_value', page['custom_field']
  end

  def test_to_h
    page = Craze::Content::Page.new(
      path: 'content/test.md',
      front_matter: { 'title' => 'Test' },
      body: '',
      html: '<p>test</p>'
    )

    hash = page.to_h

    assert_equal 'Test', hash['title']
    assert_equal '<p>test</p>', hash['content']
    assert_equal 'test', hash['slug']
  end
end
