# frozen_string_literal: true

require 'test_helper'

class InitTest < Minitest::Test
  include TestHelpers

  def test_init_creates_basic_structure
    with_temp_dir do |dir|
      project_dir = File.join(dir, 'mysite')
      init = Craze::Commands::Init.new(project_dir, { with_vite: false })
      init.run

      assert Dir.exist?(project_dir)
      assert_path_exists File.join(project_dir, 'craze.yml')
      assert_path_exists File.join(project_dir, 'content', 'index.md')
      assert_path_exists File.join(project_dir, 'content', 'posts', 'hello.md')
      assert_path_exists File.join(project_dir, 'templates', 'layouts', 'default.html.erb')
      assert_path_exists File.join(project_dir, 'templates', 'pages', 'page.html.erb')
      assert Dir.exist?(File.join(project_dir, 'assets'))
      assert Dir.exist?(File.join(project_dir, 'data'))
      assert_path_exists File.join(project_dir, 'README.md')
    end
  end

  def test_init_creates_valid_config
    with_temp_dir do |dir|
      project_dir = File.join(dir, 'mysite')
      init = Craze::Commands::Init.new(project_dir, { with_vite: false })
      init.run

      config = YAML.load_file(File.join(project_dir, 'craze.yml'))

      assert_equal 'My Craze Site', config.dig('site', 'title')
      assert_equal 'dist', config.dig('build', 'out_dir')
      assert_equal 'content', config.dig('content', 'dir')
    end
  end

  def test_init_with_vite_creates_frontend_structure
    with_temp_dir do |dir|
      project_dir = File.join(dir, 'mysite')
      init = Craze::Commands::Init.new(project_dir, { with_vite: true })
      init.run

      frontend_dir = File.join(project_dir, 'frontend')

      assert Dir.exist?(frontend_dir)
      assert_path_exists File.join(frontend_dir, 'package.json')
      assert_path_exists File.join(frontend_dir, 'vite.config.ts')
      assert_path_exists File.join(frontend_dir, 'tailwind.config.js')
      assert_path_exists File.join(frontend_dir, 'postcss.config.js')
      assert_path_exists File.join(frontend_dir, 'src', 'main.ts')
      assert_path_exists File.join(frontend_dir, 'src', 'styles.css')

      config = YAML.load_file(File.join(project_dir, 'craze.yml'))

      assert_equal 'vite', config.dig('frontend', 'mode')
      assert_includes config['integrations'], 'vite_assets'
    end
  end
end
