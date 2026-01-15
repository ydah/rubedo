# frozen_string_literal: true

require 'thor'
require_relative 'cli/init'
require_relative 'cli/dev'
require_relative 'cli/build'
require_relative 'cli/clean'
require_relative 'cli/doctor'

module Craze
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'init [DIR]', 'Generate a new Craze project'
    option :with_vite, type: :boolean, default: false, desc: 'Include Vite + Tailwind integration'
    option :with_tailwind, type: :boolean, default: false, desc: 'Include Tailwind CSS (Vite recommended)'
    def init(dir = '.')
      Commands::Init.new(dir, options).run
    end

    desc 'dev', 'Start development server with live reload'
    option :port, type: :numeric, default: 4000, desc: 'Port to run the dev server on'
    def dev
      Commands::Dev.new(options).run
    end

    desc 'build', 'Build the static site'
    option :no_frontend, type: :boolean, default: false, desc: 'Skip frontend build'
    def build
      Commands::Build.new(options).run
    end

    desc 'clean', 'Remove dist/ and .craze-cache/ directories'
    def clean
      Commands::Clean.new.run
    end

    desc 'doctor', 'Check project configuration and dependencies'
    def doctor
      Commands::Doctor.new.run
    end

    desc 'version', 'Show Craze version'
    def version
      puts "Craze #{Craze::VERSION}"
    end
    map %w[-v --version] => :version
  end
end
