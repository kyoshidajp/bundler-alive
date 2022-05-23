# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "rspec"
require "factory_bot"
require "bundler/alive"
require "vcr"

include Bundler::Alive # rubocop:disable Style/MixinUsage

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr"
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = false

  if Object.const_defined?("Client::GithubGraphql")
    c.filter_sensitive_data("github-access-token") { ENV.fetch(Client::GithubGraphql::ACCESS_TOKEN_ENV_NAME, nil) }
  end

  c.filter_sensitive_data("gitlab-access-token") { ENV.fetch(Client::GitlabApi::ACCESS_TOKEN_ENV_NAME, nil) }
end
