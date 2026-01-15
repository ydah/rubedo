# frozen_string_literal: true

require 'cgi/escape'

module Craze
  module Template
    module Helpers
      def url_for(path)
        base_path = @site&.dig('base_path') || '/'
        path = "/#{path}" unless path.start_with?('/')
        path = "#{base_path.chomp('/')}#{path}" unless base_path == '/'
        path
      end

      def asset_path(name)
        url_for("/assets/#{name}")
      end

      def escape_html(text)
        CGI.escapeHTML(text.to_s)
      end

      def format_date(date, format = '%Y-%m-%d')
        return '' if date.nil?

        date = Date.parse(date.to_s) unless date.is_a?(Date) || date.is_a?(Time)
        date.strftime(format)
      end

      def vite_client_tag
        return '' unless vite_dev_mode?

        dev_url = @site&.dig('frontend', 'dev_server', 'url') || 'http://localhost:5173'
        %(<script type="module" src="#{dev_url}/@vite/client"></script>)
      end

      def vite_js_tag(entry)
        if vite_dev_mode?
          dev_url = @site&.dig('frontend', 'dev_server', 'url') || 'http://localhost:5173'
          %(<script type="module" src="#{dev_url}/#{entry}"></script>)
        else
          asset_file = vite_manifest_entry(entry)
          %(<script type="module" src="#{url_for("/assets/#{asset_file}")}"></script>)
        end
      end

      def vite_css_tag(entry)
        if vite_dev_mode?
          dev_url = @site&.dig('frontend', 'dev_server', 'url') || 'http://localhost:5173'
          %(<link rel="stylesheet" href="#{dev_url}/#{entry}">)
        else
          asset_file = vite_manifest_entry(entry)
          %(<link rel="stylesheet" href="#{url_for("/assets/#{asset_file}")}">)
        end
      end

      def vite_asset_path(entry)
        if vite_dev_mode?
          dev_url = @site&.dig('frontend', 'dev_server', 'url') || 'http://localhost:5173'
          "#{dev_url}/#{entry}"
        else
          asset_file = vite_manifest_entry(entry)
          url_for("/assets/#{asset_file}")
        end
      end

      private

      def vite_dev_mode?
        @environment == 'development' && @site&.dig('frontend', 'mode') == 'vite'
      end

      def vite_manifest_entry(entry)
        return entry unless @vite_manifest

        manifest_entry = @vite_manifest[entry]
        return entry unless manifest_entry

        manifest_entry['file'] || entry
      end
    end
  end
end
