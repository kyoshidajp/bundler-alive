# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Bundler::Alive::Client::GithubGraphql" do
  describe "Bundler::Alive::Client::GithubGraphql#AccessTokenNotfoundError" do
    it "has an error message" do
      VCR.use_cassette "github.com/schema.json" do
        load File.expand_path("../../../../lib/bundler/alive/client/github_graphql.rb", File.dirname(__FILE__))
        exception = Bundler::Alive::Client::GithubGraphql::AccessTokenNotFoundError.new
        expect(exception).to be_an_instance_of(Bundler::Alive::Client::GithubGraphql::AccessTokenNotFoundError)

        message = "Environment variable BUNDLER_ALIVE_GITHUB_TOKEN is not set."\
                  " Need to set GitHub Personal Access Token to be authenticated at GitHub GraphQL API."\
                  " See: https://docs.github.com/en/graphql/guides/forming-calls-with-graphql#the-graphql-endpoint"
        expect(exception.message).to eq message
      end
    end
  end

  context "when a schema file exists" do
    before do
      stub_const("Bundler::Alive::SCHEMA_PATH", "spec/fixtures/files/schema.json")
      if Bundler::Alive::Client.const_defined?(:GithubGraphql)
        Bundler::Alive::Client.send(:remove_const, :GithubGraphql)
      end
    end

    it "load schema file from local" do
      load File.expand_path("../../../../lib/bundler/alive/client/github_graphql.rb", File.dirname(__FILE__))
      obj = Object.new
      obj.extend Bundler::Alive::Client::GithubGraphql
      expect(File.exist?(Bundler::Alive::SCHEMA_PATH)).to eq true
    end
  end

  context "when a schema file does not exist" do
    it "dump schema file" do
      VCR.use_cassette "github.com/schema.json" do
        if Bundler::Alive::Client.const_defined?(:GithubGraphql)
          Bundler::Alive::Client.send(:remove_const, :GithubGraphql)
        end

        load File.expand_path("../../../../lib/bundler/alive/client/github_graphql.rb", File.dirname(__FILE__))
        obj = Object.new
        obj.extend Bundler::Alive::Client::GithubGraphql
        expect(File.exist?(Bundler::Alive::SCHEMA_PATH)).to eq true
      end
    end
  end
end
