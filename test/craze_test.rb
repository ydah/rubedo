# frozen_string_literal: true

require 'test_helper'

class CrazeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil Craze::VERSION
  end

  def test_version_format
    assert_match(/\A\d+\.\d+\.\d+\z/, Craze::VERSION)
  end
end
