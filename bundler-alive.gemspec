# frozen_string_literal: true

require_relative "lib/bundler/alive/version"

Gem::Specification.new do |spec|
  spec.name = "bundler-alive"
  spec.version = Bundler::Alive::VERSION
  spec.authors = ["Katsuhiko YOSHIDA"]
  spec.email = ["claddvd@gmail.com"]

  spec.summary = "Are your gems alive?"
  spec.description = "bundler-alive reports gems are archived or not."
  spec.homepage = "https://github.com/kyoshidajp/bundler-alive"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = "https://github.com/kyoshidajp/bundler-alive"
  spec.metadata["source_code_uri"] = "https://github.com/kyoshidajp/bundler-alive"
  spec.metadata["changelog_uri"] = "https://github.com/kyoshidajp/bundler-alive"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "faraday"
  spec.add_dependency "octokit"
  spec.add_dependency "rake"
  spec.add_dependency "thor"
  spec.add_dependency "toml-rb"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "yard"

  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  spec.add_development_dependency "simplecov", "~> 0.10", "< 0.18"

  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
