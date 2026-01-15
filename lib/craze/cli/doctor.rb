# frozen_string_literal: true

require 'yaml'

module Craze
  module Commands
    class Doctor
      def run
        puts 'Craze Doctor - Checking project health...'
        puts ''

        issues = []

        issues.concat(check_config)
        issues.concat(check_directories)
        issues.concat(check_frontend)

        puts ''
        if issues.empty?
          puts '✓ All checks passed!'
        else
          puts "Found #{issues.size} issue(s):"
          issues.each { |issue| puts "  • #{issue}" }
        end
      end

      private

      def check_config
        issues = []
        config_path = 'craze.yml'

        if File.exist?(config_path)
          puts '✓ craze.yml found'
          begin
            YAML.load_file(config_path)
            puts '✓ craze.yml is valid YAML'
          rescue Psych::SyntaxError => e
            issues << "craze.yml has invalid YAML: #{e.message}"
            puts '✗ craze.yml has invalid YAML'
          end
        else
          issues << 'craze.yml not found'
          puts '✗ craze.yml not found'
        end

        issues
      end

      def check_directories
        issues = []
        required_dirs = %w[content templates]

        required_dirs.each do |dir|
          if Dir.exist?(dir)
            puts "✓ #{dir}/ directory exists"
          else
            issues << "#{dir}/ directory not found"
            puts "✗ #{dir}/ directory not found"
          end
        end

        issues
      end

      def check_frontend
        issues = []
        return issues unless File.exist?('craze.yml')

        config = YAML.load_file('craze.yml')
        return issues unless config.dig('frontend', 'mode') == 'vite'

        puts ''
        puts 'Checking frontend dependencies...'

        issues.concat(check_node_npm)
        issues.concat(check_frontend_package(config))
        issues
      end

      def check_node_npm
        issues = []
        node_version = `node --version 2>/dev/null`.strip
        if node_version.empty?
          issues << 'Node.js not found (required for Vite)'
          puts '✗ Node.js not found'
        else
          puts "✓ Node.js #{node_version}"
        end

        npm_version = `npm --version 2>/dev/null`.strip
        if npm_version.empty?
          issues << 'npm not found (required for Vite)'
          puts '✗ npm not found'
        else
          puts "✓ npm #{npm_version}"
        end
        issues
      end

      def check_frontend_package(config)
        issues = []
        frontend_dir = config.dig('frontend', 'root') || 'frontend'
        package_json = File.join(frontend_dir, 'package.json')

        unless File.exist?(package_json)
          issues << "#{package_json} not found"
          puts "✗ #{package_json} not found"
          return issues
        end

        puts "✓ #{package_json} found"
        node_modules = File.join(frontend_dir, 'node_modules')
        if Dir.exist?(node_modules)
          puts "✓ #{frontend_dir}/node_modules/ exists"
        else
          issues << "#{frontend_dir}/node_modules/ not found - run 'npm install' in #{frontend_dir}/"
          puts "✗ #{frontend_dir}/node_modules/ not found"
        end
        issues
      end
    end
  end
end
