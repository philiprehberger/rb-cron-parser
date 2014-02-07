# frozen_string_literal: true

require_relative 'lib/philiprehberger/cron_parser/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-cron_parser'
  spec.version       = Philiprehberger::CronParser::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Cron expression parser for calculating next and previous occurrences'
  spec.description   = 'Parse standard 5-field cron expressions and calculate next/previous occurrences, ' \
                       'match times against patterns, and generate human-readable descriptions.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-cron-parser'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
