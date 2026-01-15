# frozen_string_literal: true

require 'test_helper'

class RouterTest < Minitest::Test
  def test_resolve_with_slug
    page = Craze::Content::Page.new(
      path: 'content/posts/hello-world.md',
      front_matter: { 'date' => Date.new(2026, 1, 15) },
      body: '',
      html: ''
    )

    url = Craze::SiteGraph::Router.resolve(page, '/posts/:slug/')

    assert_equal '/posts/hello-world/', url
  end

  def test_resolve_with_date_tokens
    page = Craze::Content::Page.new(
      path: 'content/posts/my-post.md',
      front_matter: { 'date' => Date.new(2026, 3, 5) },
      body: '',
      html: ''
    )

    url = Craze::SiteGraph::Router.resolve(page, '/:year/:month/:day/:slug/')

    assert_equal '/2026/03/05/my-post/', url
  end

  def test_resolve_with_title_token
    page = Craze::Content::Page.new(
      path: 'content/test.md',
      front_matter: { 'title' => 'Hello World Post!' },
      body: '',
      html: ''
    )

    url = Craze::SiteGraph::Router.resolve(page, '/articles/:title/')

    assert_equal '/articles/hello-world-post/', url
  end

  def test_output_path_for_trailing_slash
    output = Craze::SiteGraph::Router.output_path('/posts/hello/')

    assert_equal '/posts/hello/index.html', output
  end

  def test_output_path_for_html_extension
    output = Craze::SiteGraph::Router.output_path('/about.html')

    assert_equal '/about.html', output
  end

  def test_output_path_for_no_extension
    output = Craze::SiteGraph::Router.output_path('/about')

    assert_equal '/about/index.html', output
  end
end
