# frozen_string_literal: true

require 'test_helper'

class PipelineTest < Minitest::Test
  include TestHelpers

  def test_build_generates_output
    with_temp_dir do |_dir|
      setup_project

      pipeline = Craze::Pipeline.new(config_path: 'craze.yml', environment: 'production')
      summary = pipeline.build

      assert_path_exists 'dist/index.html'
      assert_path_exists 'dist/posts/hello/index.html'
      assert_equal 2, summary[:pages]
    end
  end

  def test_build_renders_templates
    with_temp_dir do |_dir|
      setup_project

      pipeline = Craze::Pipeline.new(config_path: 'craze.yml', environment: 'production')
      pipeline.build

      content = File.read('dist/index.html')

      assert_includes content, '<!DOCTYPE html>'
      assert_includes content, 'Welcome'
      assert_includes content, 'Test Site'
    end
  end

  def test_build_emits_events
    with_temp_dir do |_dir|
      setup_project

      events_emitted = []
      pipeline = Craze::Pipeline.new(config_path: 'craze.yml', environment: 'production')

      pipeline.on(:before_build) { events_emitted << :before_build }
      pipeline.on(:after_write) { events_emitted << :after_write }

      pipeline.build

      assert_includes events_emitted, :before_build
      assert_includes events_emitted, :after_write
    end
  end

  def test_build_copies_assets
    with_temp_dir do |_dir|
      setup_project
      FileUtils.mkdir_p('assets')
      File.write('assets/style.css', 'body { color: black; }')

      pipeline = Craze::Pipeline.new(config_path: 'craze.yml', environment: 'production')
      pipeline.build

      assert_path_exists 'dist/assets/style.css'
    end
  end

  def test_build_runs_integrations
    with_temp_dir do |_dir|
      setup_project_with_integrations

      pipeline = Craze::Pipeline.new(config_path: 'craze.yml', environment: 'production')
      pipeline.build

      assert_path_exists 'dist/sitemap.xml'
      assert_path_exists 'dist/feed.xml'
      assert_path_exists 'dist/search.json'
    end
  end

  private

  def setup_project
    File.write('craze.yml', YAML.dump({
                                         'site' => { 'title' => 'Test Site' },
                                         'build' => { 'out_dir' => 'dist', 'clean' => true },
                                         'content' => {
                                           'dir' => 'content',
                                           'collections' => {
                                             'posts' => { 'pattern' => 'posts/**/*.md', 'permalink' => '/posts/:slug/' }
                                           }
                                         },
                                         'templates' => { 'dir' => 'templates' }
                                       }))

    FileUtils.mkdir_p('content/posts')
    File.write('content/index.md', <<~MD)
      ---
      title: Home
      layout: default
      ---
      Welcome
    MD
    File.write('content/posts/hello.md', <<~MD)
      ---
      title: Hello
      date: 2026-01-15
      layout: default
      ---
      Hello world
    MD

    FileUtils.mkdir_p('templates/layouts')
    File.write('templates/layouts/default.html.erb', <<~ERB)
      <!DOCTYPE html>
      <html>
      <head><title><%= page["title"] %> | <%= site["title"] %></title></head>
      <body><%= page["content"] %></body>
      </html>
    ERB
  end

  def setup_project_with_integrations
    File.write('craze.yml', YAML.dump({
                                         'site' => { 'title' => 'Test Site', 'url' => 'https://example.com' },
                                         'build' => { 'out_dir' => 'dist', 'clean' => true },
                                         'content' => {
                                           'dir' => 'content',
                                           'collections' => {
                                             'posts' => { 'pattern' => 'posts/**/*.md', 'permalink' => '/posts/:slug/' }
                                           }
                                         },
                                         'templates' => { 'dir' => 'templates' },
                                         'integrations' => %w[sitemap rss search_index]
                                       }))

    FileUtils.mkdir_p('content/posts')
    File.write('content/index.md', <<~MD)
      ---
      title: Home
      layout: default
      ---
      Welcome
    MD
    File.write('content/posts/hello.md', <<~MD)
      ---
      title: Hello
      date: 2026-01-15
      layout: default
      ---
      Hello world
    MD

    FileUtils.mkdir_p('templates/layouts')
    File.write('templates/layouts/default.html.erb', <<~ERB)
      <!DOCTYPE html>
      <html>
      <head><title><%= page["title"] %> | <%= site["title"] %></title></head>
      <body><%= page["content"] %></body>
      </html>
    ERB
  end
end
