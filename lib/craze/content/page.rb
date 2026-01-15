# frozen_string_literal: true

module Craze
  module Content
    class Page
      attr_reader :path, :front_matter, :body, :html

      def initialize(path:, front_matter:, body:, html:)
        @path = path
        @front_matter = front_matter
        @body = body
        @html = html
      end

      def title
        front_matter['title']
      end

      def date
        front_matter['date']
      end

      def layout
        front_matter['layout'] || 'default'
      end

      def tags
        front_matter['tags'] || []
      end

      def draft?
        front_matter['draft'] == true
      end

      def slug
        @slug ||= File.basename(path, '.*')
      end

      def [](key)
        front_matter[key]
      end

      def to_h
        {
          'title' => title,
          'date' => date,
          'layout' => layout,
          'tags' => tags,
          'draft' => draft?,
          'slug' => slug,
          'content' => html,
          'path' => path
        }.merge(front_matter)
      end
    end
  end
end
