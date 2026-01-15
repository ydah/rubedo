# frozen_string_literal: true

require 'yaml'

module Craze
  class Config
    DEFAULT_CONFIG = {
      'site' => {
        'title' => 'My Site',
        'url' => 'https://example.com',
        'language' => 'en'
      },
      'build' => {
        'out_dir' => 'dist',
        'base_path' => '/',
        'clean' => true
      },
      'content' => {
        'dir' => 'content',
        'collections' => {}
      },
      'templates' => {
        'dir' => 'templates'
      },
      'assets' => {
        'dir' => 'assets',
        'passthrough' => []
      },
      'integrations' => []
    }.freeze

    attr_reader :data

    def initialize(path = 'craze.yml', environment: 'production')
      @path = path
      @environment = environment
      @data = load_config
    end

    def [](key)
      @data[key]
    end

    def dig(*keys)
      @data.dig(*keys)
    end

    def to_h
      @data
    end

    private

    def load_config
      user_config = File.exist?(@path) ? YAML.load_file(@path) : {}
      deep_merge(DEFAULT_CONFIG.dup, user_config)
    end

    def deep_merge(base, override)
      base.merge(override) do |_key, base_val, override_val|
        if base_val.is_a?(Hash) && override_val.is_a?(Hash)
          deep_merge(base_val, override_val)
        else
          override_val
        end
      end
    end
  end
end
