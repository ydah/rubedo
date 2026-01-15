# frozen_string_literal: true

module Craze
  module Integrations
    class Base
      attr_reader :config, :pages, :collections, :out_dir

      def initialize(config:, pages:, collections:, out_dir:)
        @config = config
        @pages = pages
        @collections = collections
        @out_dir = out_dir
      end

      def run
        raise NotImplementedError, 'Subclasses must implement #run'
      end

      protected

      def write_file(path, content)
        full_path = File.join(@out_dir, path)
        FileUtils.mkdir_p(File.dirname(full_path))
        File.write(full_path, content)
        puts "  Generated #{path}"
      end

      def site_url
        @config.dig('site', 'url') || 'https://example.com'
      end
    end
  end
end
