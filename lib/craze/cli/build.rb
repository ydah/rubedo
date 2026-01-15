# frozen_string_literal: true

require_relative '../pipeline'

module Craze
  module Commands
    class Build
      def initialize(options)
        @options = options
      end

      def run
        start_time = Time.now

        puts 'Building Craze site...'

        unless File.exist?('craze.yml')
          warn 'Error: craze.yml not found. Run `craze init` first.'
          exit 1
        end

        run_frontend_build unless @options[:no_frontend]

        pipeline = Pipeline.new(config_path: 'craze.yml', environment: 'production')
        summary = pipeline.build

        elapsed = Time.now - start_time
        puts "Done! Generated #{summary[:pages]} pages in #{elapsed.round(2)}s"
        puts "Output: #{summary[:output_dir]}/"
      end

      private

      def run_frontend_build
        return unless File.exist?('craze.yml')

        config = YAML.load_file('craze.yml')
        return unless config.dig('frontend', 'mode') == 'vite'

        command = config.dig('frontend', 'build', 'command')
        return unless command

        frontend_root = config.dig('frontend', 'root') || 'frontend'
        return unless Dir.exist?(frontend_root)

        puts 'Building frontend assets...'
        Dir.chdir(frontend_root) do
          system(command) || warn('Frontend build failed')
        end

        copy_frontend_assets(config)
      end

      def copy_frontend_assets(config)
        src_dir = config.dig('frontend', 'build', 'out_dir')
        dest_dir = config.dig('frontend', 'copy_to', 'dir')
        return unless src_dir && dest_dir && Dir.exist?(src_dir)

        puts 'Copying frontend assets...'
        FileUtils.mkdir_p(dest_dir)
        FileUtils.cp_r(Dir.glob("#{src_dir}/*"), dest_dir)
      end
    end
  end
end
