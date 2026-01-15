# frozen_string_literal: true

require_relative 'lib/craze/version'

Gem::Specification.new do |spec|
  spec.name = 'craze'
  spec.version = Craze::VERSION
  spec.authors = ['Yudai Takada']
  spec.email = ['t.yudai92@gmail.com']

  spec.summary = 'A modern static site generator for Ruby'
  spec.description = <<~DESC.chomp
    Craze is a modern static site generator with Vite/Tailwind integration,
    incremental builds, and extensible integrations.
  DESC
  spec.homepage = 'https://github.com/ydah/craze'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = ['craze']
  spec.require_paths = ['lib']

  spec.add_dependency 'commonmarker', '~> 2.6.1'
  spec.add_dependency 'listen', '~> 3.9'
  spec.add_dependency 'logger', '~> 1.6'
  spec.add_dependency 'thor', '~> 1.3'
  spec.add_dependency 'webrick', '~> 1.8'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
