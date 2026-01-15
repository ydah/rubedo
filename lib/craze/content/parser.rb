# frozen_string_literal: true

require 'yaml'
require 'commonmarker'

module Craze
  module Content
    class Parser
      FRONT_MATTER_REGEX = /\A---\r?\n(.*?)\r?\n---\r?\n(.*)\z/m

      def parse(content)
        front_matter, body = extract_front_matter(content)
        html = render_markdown(body)
        { front_matter: front_matter, body: body, html: html }
      end

      def parse_file(path)
        content = File.read(path)
        result = parse(content)
        result[:path] = path
        result
      end

      private

      def extract_front_matter(content)
        match = content.match(FRONT_MATTER_REGEX)
        if match
          front_matter = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
          body = match[2]
        else
          front_matter = {}
          body = content
        end
        [front_matter, body]
      end

      def render_markdown(body)
        Commonmarker.to_html(
          body,
          options: {
            parse: { smart: true },
            render: { unsafe: true }
          }
        )
      end
    end
  end
end
