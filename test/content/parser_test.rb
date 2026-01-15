# frozen_string_literal: true

require 'test_helper'

class ParserTest < Minitest::Test
  def setup
    @parser = Craze::Content::Parser.new
  end

  def test_parse_with_front_matter
    content = <<~MD
      ---
      title: Test Post
      date: 2026-01-15
      tags: [ruby, test]
      ---

      # Hello World

      This is a test.
    MD

    result = @parser.parse(content)

    assert_equal 'Test Post', result[:front_matter]['title']
    assert_equal Date.new(2026, 1, 15), result[:front_matter]['date']
    assert_equal %w[ruby test], result[:front_matter]['tags']
    assert_includes result[:html], 'Hello World</h1>'
    assert_includes result[:html], '<p>This is a test.</p>'
  end

  def test_parse_without_front_matter
    content = "# Just Markdown\n\nNo front matter here."

    result = @parser.parse(content)

    assert_empty result[:front_matter]
    assert_includes result[:html], 'Just Markdown</h1>'
  end

  def test_parse_empty_front_matter
    content = <<~MD
      ---
      ---

      # Content
    MD

    result = @parser.parse(content)

    assert_empty result[:front_matter]
    assert_includes result[:html], 'Content</h1>'
  end

  def test_parse_file
    Dir.mktmpdir do |dir|
      file_path = File.join(dir, 'test.md')
      File.write(file_path, <<~MD)
        ---
        title: File Test
        ---

        Content here.
      MD

      result = @parser.parse_file(file_path)

      assert_equal file_path, result[:path]
      assert_equal 'File Test', result[:front_matter]['title']
    end
  end

  def test_markdown_renders_paragraphs
    content = <<~MD
      ---
      title: test
      ---

      Hello World
    MD

    result = @parser.parse(content)

    assert_includes result[:html], '<p>Hello World</p>'
  end
end
