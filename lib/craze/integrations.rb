# frozen_string_literal: true

require_relative 'integrations/base'
require_relative 'integrations/sitemap'
require_relative 'integrations/rss'
require_relative 'integrations/search_index'
require_relative 'integrations/vite_assets'

module Craze
  module Integrations
    REGISTRY = {
      'sitemap' => Sitemap,
      'rss' => RSS,
      'search_index' => SearchIndex,
      'vite_assets' => ViteAssets
    }.freeze

    def self.load(name)
      REGISTRY[name]
    end
  end
end
