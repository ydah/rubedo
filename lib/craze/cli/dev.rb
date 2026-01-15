# frozen_string_literal: true

require 'webrick'
require 'listen'
require_relative '../pipeline'

module Craze
  module Commands
    class Dev
      def initialize(options)
        @options = options
        @port = options[:port] || 4000
      end

      def run
        unless File.exist?('craze.yml')
          warn 'Error: craze.yml not found. Run `craze init` first.'
          exit 1
        end

        puts 'Building site...'
        build_site

        puts "Starting dev server on http://localhost:#{@port}"
        start_watcher
        start_server
      end

      private

      def build_site
        @pipeline = Pipeline.new(config_path: 'craze.yml', environment: 'development')
        @pipeline.build
        puts 'Build complete.'
      rescue StandardError => e
        warn "Build error: #{e.message}"
      end

      def start_watcher
        content_dir = 'content'
        templates_dir = 'templates'
        assets_dir = 'assets'

        dirs_to_watch = [content_dir, templates_dir, assets_dir].select { |d| Dir.exist?(d) }
        return if dirs_to_watch.empty?

        @listener = Listen.to(*dirs_to_watch) do |modified, added, removed|
          changed = modified + added + removed
          puts "Changed: #{changed.map { |f| File.basename(f) }.join(', ')}"
          puts 'Rebuilding...'
          build_site
        end

        @listener.start
      end

      def start_server
        out_dir = 'dist'
        FileUtils.mkdir_p(out_dir)

        server = WEBrick::HTTPServer.new(
          Port: @port,
          DocumentRoot: out_dir,
          Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN),
          AccessLog: []
        )

        server.mount_proc '/--live-reload' do |_req, res|
          res.content_type = 'text/event-stream'
          res['Cache-Control'] = 'no-cache'
          res.body = "data: reload\n\n"
        end

        trap('INT') do
          @listener&.stop
          server.shutdown
        end

        server.start
      end
    end
  end
end
