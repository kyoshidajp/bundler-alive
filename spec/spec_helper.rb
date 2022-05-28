# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "rspec"
require "factory_bot"
require "bundler/alive"
require "vcr"

include Bundler::Alive # rubocop:disable Style/MixinUsage

TMP_DIR = "tmp"

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

  config.before do
    path = File.join(TMP_DIR, "schema.json")
    Dir.mkdir(TMP_DIR) unless Dir.exist?(TMP_DIR)
    FileUtils.remove_file(path) if File.exist?(path)
    stub_const("Bundler::Alive::USER_PATH", TMP_DIR)
    stub_const("Bundler::Alive::SCHEMA_PATH", path)

    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch)
      .with(Bundler::Alive::Client::GithubApi::ACCESS_TOKEN_ENV_NAME, nil)
      .and_return("something")
  end

  config.after do
    path = File.join(TMP_DIR, "schema.json")
    Dir.mkdir(TMP_DIR) unless Dir.exist?(TMP_DIR)
    FileUtils.remove_file(path) if File.exist?(path)
  end
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr"
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = false
  c.filter_sensitive_data("github-access-token") { ENV.fetch(Client::GithubApi::ACCESS_TOKEN_ENV_NAME, nil) }
  c.filter_sensitive_data("gitlab-access-token") { ENV.fetch(Client::GitlabApi::ACCESS_TOKEN_ENV_NAME, nil) }
end
