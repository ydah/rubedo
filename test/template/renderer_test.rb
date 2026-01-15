# frozen_string_literal: true

require 'test_helper'

class RendererTest < Minitest::Test
  include TestHelpers

  def test_render_with_layout
    with_temp_dir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'templates', 'layouts'))
      File.write(File.join(dir, 'templates', 'layouts', 'default.html.erb'), <<~ERB)
        <!DOCTYPE html>
        <html>
        <head><title><%= page["title"] %></title></head>
        <body><%= page["content"] %></body>
        </html>
      ERB

      renderer = Craze::Template::Renderer.new(
        templates_dir: File.join(dir, 'templates'),
        site: { 'title' => 'Test Site' }
      )

      page = Craze::Content::Page.new(
        path: 'test.md',
        front_matter: { 'title' => 'Hello', 'layout' => 'default' },
        body: '',
        html: '<p>World</p>'
      )

      result = renderer.render(page)

      assert_includes result, '<!DOCTYPE html>'
      assert_includes result, '<title>Hello</title>'
      assert_includes result, '<p>World</p>'
    end
  end

  def test_render_without_layout
    with_temp_dir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'templates', 'layouts'))

      renderer = Craze::Template::Renderer.new(
        templates_dir: File.join(dir, 'templates'),
        site: { 'title' => 'Test Site' }
      )

      page = Craze::Content::Page.new(
        path: 'test.md',
        front_matter: { 'title' => 'Hello', 'layout' => 'nonexistent' },
        body: '',
        html: '<p>Just content</p>'
      )

      result = renderer.render(page)

      assert_equal '<p>Just content</p>', result
    end
  end

  def test_render_string
    renderer = Craze::Template::Renderer.new(
      templates_dir: '/tmp',
      site: { 'title' => 'Test Site', 'base_path' => '/' }
    )

    page = Craze::Content::Page.new(
      path: 'test.md',
      front_matter: { 'title' => 'Hello' },
      body: '',
      html: '<p>Content</p>'
    )

    template = '<h1><%= page["title"] %></h1><%= page["content"] %>'
    result = renderer.render_string(template, page: page)

    assert_equal '<h1>Hello</h1><p>Content</p>', result
  end

  def test_render_with_collections
    with_temp_dir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'templates', 'layouts'))
      File.write(File.join(dir, 'templates', 'layouts', 'default.html.erb'), <<~ERB)
        <ul>
        <% collections["posts"].each do |post| %>
          <li><%= post["title"] %></li>
        <% end %>
        </ul>
      ERB

      renderer = Craze::Template::Renderer.new(
        templates_dir: File.join(dir, 'templates'),
        site: {}
      )

      page = Craze::Content::Page.new(
        path: 'index.md',
        front_matter: { 'layout' => 'default' },
        body: '',
        html: ''
      )

      posts = [
        { 'title' => 'Post 1' },
        { 'title' => 'Post 2' }
      ]

      result = renderer.render(page, collections: { 'posts' => posts })

      assert_includes result, '<li>Post 1</li>'
      assert_includes result, '<li>Post 2</li>'
    end
  end
end
