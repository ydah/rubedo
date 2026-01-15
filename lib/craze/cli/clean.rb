# frozen_string_literal: true

require 'fileutils'

module Craze
  module Commands
    class Clean
      CLEAN_DIRS = %w[dist .craze-cache].freeze

      def run
        puts 'Cleaning build artifacts...'

        CLEAN_DIRS.each do |dir|
          if Dir.exist?(dir)
            FileUtils.rm_rf(dir)
            puts "  Removed #{dir}/"
          else
            puts "  #{dir}/ not found, skipping"
          end
        end

        puts 'Done!'
      end
    end
  end
end
