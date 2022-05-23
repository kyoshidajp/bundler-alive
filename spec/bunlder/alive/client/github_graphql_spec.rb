# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Bundler::Alive::Client::GithubGraphql" do
  context "when a schema file exist" do
    it "does not HTTP request to get schema file" do
      stub_const("Bundler::Alive::SCHEMA_PATH", "spec/fixtures/vcr/github_com/schema_json.yml")
      expect do
        load File.expand_path("../../../../lib/bundler/alive/client/github_graphql.rb", File.dirname(__FILE__))
        # obj = Object.new
        # obj.extend Bundler::Alive::Client::GithubGraphql
      end.not_to raise_error(VCR::Errors::UnhandledHTTPRequestError)
    end
  end

  context "when a schema file does not exist" do
    let!(:dir) { "tmp" }
    let!(:path) { File.join(dir, "schema.json") }
    before do
      Dir.mkdir(dir) unless Dir.exist?(dir)
      FileUtils.remove_file(path) if File.exist?(path)
      stub_const("Bundler::Alive::SCHEMA_PATH", path)

      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch)
        .with(Bundler::Alive::Client::GithubGraphql::ACCESS_TOKEN_ENV_NAME, nil)
        .and_return("something")
    end

    it "dump schema file" do
      VCR.use_cassette "github.com/schema.json" do
        load File.expand_path("../../../../lib/bundler/alive/client/github_graphql.rb", File.dirname(__FILE__))
        obj = Object.new
        obj.extend Bundler::Alive::Client::GithubGraphql
        expect(File.exist?(path)).to eq true
      end
    end
  end
end
