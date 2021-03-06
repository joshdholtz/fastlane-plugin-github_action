# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/github_action/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-github_action'
  spec.version       = Fastlane::GithubAction::VERSION
  spec.author        = 'Josh Holtz'
  spec.email         = 'me@joshholtz.com'

  spec.summary       = 'Helper to setup GitHub actions for fastlane and match'
  spec.homepage      = "https://github.com/joshdholtz/fastlane-plugin-github_action"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency('fastlane', '>= 2.148.1')
  spec.add_dependency 'dotenv'
  spec.add_dependency 'rbnacl'
  spec.add_dependency 'sshkey'

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
end
