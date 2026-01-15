# frozen_string_literal: true

module Craze
  module SiteGraph
    class Collection
      attr_reader :name, :pages, :pattern, :permalink

      def initialize(name:, pattern:, permalink:)
        @name = name
        @pattern = pattern
        @permalink = permalink
        @pages = []
      end

      def add(page)
        @pages << page
      end

      def sorted_by_date(descending: true)
        sorted = @pages.select(&:date).sort_by(&:date)
        descending ? sorted.reverse : sorted
      end

      def by_tag(tag)
        @pages.select { |page| page.tags.include?(tag) }
      end

      def all_tags
        @pages.flat_map(&:tags).uniq.sort
      end

      def to_a
        @pages.map(&:to_h)
      end
    end
  end
end
