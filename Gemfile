# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "faraday"
gem "octokit"
gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "rubocop", "~> 1.21"
gem "thor"
gem "toml-rb"

group :development do
  gem "yard"
end

group :test do
  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  gem "factory_bot"
  gem "simplecov", "~> 0.10", "< 0.18"
  gem "vcr"
  gem "webmock"
end
