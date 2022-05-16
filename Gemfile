# frozen_string_literal: true

source "https://rubygems.org"

gemspec

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
