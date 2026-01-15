# frozen_string_literal: true

require 'fileutils'
require_relative 'base'

module Craze
  module Integrations
    class ViteAssets < Base
      def run
        return unless vite_mode?

        copy_vite_assets
        puts '  Vite assets copied'
      end

      private

      def vite_mode?
        @config.dig('frontend', 'mode') == 'vite'
      end

      def copy_vite_assets
        src_dir = @config.dig('frontend', 'build', 'out_dir')
        dest_dir = @config.dig('frontend', 'copy_to', 'dir')

        return unless src_dir && dest_dir && Dir.exist?(src_dir)

        FileUtils.mkdir_p(dest_dir)
        FileUtils.cp_r(Dir.glob("#{src_dir}/*"), dest_dir)
      end
    end
  end
end
