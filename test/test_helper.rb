# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'craze'

require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'

module TestHelpers
  def with_temp_dir
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        yield dir
      end
    end
  end
end
