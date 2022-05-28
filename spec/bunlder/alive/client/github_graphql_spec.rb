# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Bundler::Alive::Client::GithubGraphql" do
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
