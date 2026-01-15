# frozen_string_literal: true

require 'test_helper'

class BuilderTest < Minitest::Test
  include TestHelpers

  def test_build_discovers_collection_pages
    with_temp_dir do |dir|
      setup_content_structure(dir)

      config = {
        'content' => {
          'dir' => 'content',
          'collections' => {
            'posts' => {
              'pattern' => 'posts/**/*.md',
              'permalink' => '/posts/:slug/'
            }
          }
        }
      }

      builder = Craze::SiteGraph::Builder.new(config)
      result = builder.build

      assert_equal 1, result[:collections].size
      assert result[:collections].key?('posts')

      posts = result[:collections]['posts']

      assert_equal 2, posts.pages.size
    end
  end

  def test_build_discovers_standalone_pages
    with_temp_dir do |dir|
      setup_content_structure(dir)

      config = {
        'content' => {
          'dir' => 'content',
          'collections' => {
            'posts' => {
              'pattern' => 'posts/**/*.md',
              'permalink' => '/posts/:slug/'
            }
          }
        }
      }

      builder = Craze::SiteGraph::Builder.new(config)
      result = builder.build

      standalone = result[:pages].reject { |p| p.path.include?('posts/') }

      assert_equal 2, standalone.size
    end
  end

  def test_pages_have_url_and_output_path
    with_temp_dir do |dir|
      setup_content_structure(dir)

      config = {
        'content' => {
          'dir' => 'content',
          'collections' => {
            'posts' => {
              'pattern' => 'posts/**/*.md',
              'permalink' => '/posts/:slug/'
            }
          }
        }
      }

      builder = Craze::SiteGraph::Builder.new(config)
      result = builder.build

      post = result[:collections]['posts'].pages.find { |p| p.slug == 'first' }

      assert_equal '/posts/first/', post.url
      assert_equal '/posts/first/index.html', post.output_path
    end
  end

  def test_excludes_draft_pages
    with_temp_dir do |_dir|
      FileUtils.mkdir_p('content/posts')
      File.write('content/posts/published.md', <<~MD)
        ---
        title: Published
        date: 2026-01-15
        ---
        Content
      MD
      File.write('content/posts/draft.md', <<~MD)
        ---
        title: Draft
        date: 2026-01-15
        draft: true
        ---
        Content
      MD

      config = {
        'content' => {
          'dir' => 'content',
          'collections' => {
            'posts' => {
              'pattern' => 'posts/**/*.md',
              'permalink' => '/posts/:slug/'
            }
          }
        }
      }

      builder = Craze::SiteGraph::Builder.new(config)
      result = builder.build

      assert_equal 1, result[:collections]['posts'].pages.size
      assert_equal 'Published', result[:collections]['posts'].pages.first.title
    end
  end

  private

  def setup_content_structure(_dir)
    FileUtils.mkdir_p('content/posts')
    File.write('content/index.md', <<~MD)
      ---
      title: Home
      ---
      Welcome!
    MD
    File.write('content/about.md', <<~MD)
      ---
      title: About
      ---
      About us.
    MD
    File.write('content/posts/first.md', <<~MD)
      ---
      title: First Post
      date: 2026-01-10
      ---
      First content.
    MD
    File.write('content/posts/second.md', <<~MD)
      ---
      title: Second Post
      date: 2026-01-15
      ---
      Second content.
    MD
  end
end
