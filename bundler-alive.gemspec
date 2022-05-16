# frozen_string_literal: true

require_relative "lib/bundler/alive/version"
require "yaml"

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |gem|
  gemspec = YAML.load_file("gemspec.yml")
  gem.name = gemspec.fetch("name")
  gem.version = Bundler::Alive::VERSION
  gem.authors = gemspec.fetch("authors")
  gem.email = gemspec.fetch("email")

  gem.summary = gemspec.fetch("summary")
  gem.description = gemspec.fetch("description")
  gem.homepage = gemspec.fetch("homepage")
  gem.required_ruby_version = gemspec.fetch("required_ruby_version")

  metadata = gemspec.fetch("metadata")
  gem.metadata["homepage_uri"] = metadata["homepage_uri"]
  gem.metadata["source_code_uri"] = metadata["source_code_uri"]
  gem.metadata["changelog_uri"] = metadata["changelog_uri"]
  gem.metadata["rubygems_mfa_required"] = "true"

  gem.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  gem.bindir = gemspec.fetch("bindir")
  gem.executables = gem.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  gem.require_paths = gemspec.fetch("require_paths")

  split = lambda do |string|
    string.nil? ? "" : string.split(/,\s*/)
  end

  gemspec["dependencies"].each do |name, versions|
    if versions.nil?
      gem.add_dependency(name)
    else
      gem.add_dependency(name, split[versions])
    end
  end

  gemspec["development_dependencies"].each do |name, versions|
    if versions.nil?
      gem.add_development_dependency(name)
    else
      gem.add_development_dependency(name, split[versions])
    end
  end
end
# rubocop:enable Metrics/BlockLength
