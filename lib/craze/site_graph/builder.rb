# frozen_string_literal: true

require_relative '../content/parser'
require_relative '../content/page'
require_relative 'router'
require_relative 'collection'

module Craze
  module SiteGraph
    class Builder
      def initialize(config)
        @config = config
        @content_dir = config.dig('content', 'dir') || 'content'
        @collections_config = config.dig('content', 'collections') || {}
        @parser = Content::Parser.new
      end

      def build
        pages = []
        collections = {}

        @collections_config.each do |name, collection_config|
          collection = build_collection(name, collection_config)
          collections[name] = collection
          pages.concat(collection.pages)
        end

        standalone_pages = discover_standalone_pages(collections)
        pages.concat(standalone_pages)

        { pages: pages, collections: collections }
      end

      private

      def build_collection(name, config)
        pattern = config['pattern']
        permalink = config['permalink'] || "/#{name}/:slug/"

        collection = Collection.new(name: name, pattern: pattern, permalink: permalink)

        glob_pattern = File.join(@content_dir, pattern)
        Dir.glob(glob_pattern).each do |file_path|
          page = parse_page(file_path, permalink)
          collection.add(page) unless page.draft?
        end

        collection
      end

      def discover_standalone_pages(collections)
        collection_files = collections.values.flat_map do |c|
          c.pages.map(&:path)
        end.to_set

        standalone = []
        Dir.glob(File.join(@content_dir, '**/*.md')).each do |file_path|
          next if collection_files.include?(file_path)

          page = parse_page(file_path, nil)
          standalone << page unless page.draft?
        end

        standalone
      end

      def parse_page(file_path, permalink_pattern)
        result = @parser.parse_file(file_path)

        page = Content::Page.new(
          path: file_path,
          front_matter: result[:front_matter],
          body: result[:body],
          html: result[:html]
        )

        url = if permalink_pattern
                Router.resolve(page, permalink_pattern)
              else
                default_url_for(file_path)
              end

        page.instance_variable_set(:@url, url)
        page.define_singleton_method(:url) { @url }

        output_path = Router.output_path(url)
        page.instance_variable_set(:@output_path, output_path)
        page.define_singleton_method(:output_path) { @output_path }

        page
      end

      def default_url_for(file_path)
        relative = file_path.sub(%r{^#{Regexp.escape(@content_dir)}/?}, '')
        relative = relative.sub(/\.md$/, '')
        relative = relative.sub(%r{(^|/)index$}, '\1')
        return '/' if relative.empty?

        "/#{relative}/"
      end
    end
  end
end
