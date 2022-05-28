# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::GithubApi do
  describe "#create_client" do
    context "when access token is set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch)
          .with("BUNDLER_ALIVE_GITHUB_TOKEN", nil)
          .and_return("something")
      end

      it "returns `GraphQL::Client` instance" do
        VCR.use_cassette "github.com/schema.json" do
          require_relative "../../../../lib/bundler/alive/client/github_graphql"
          obj = Object.new
          obj.extend described_class
          expect(obj.create_client).to be_an_instance_of(GraphQL::Client)
        end
      end
    end
  end

  describe "#query" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch)
        .with("BUNDLER_ALIVE_GITHUB_TOKEN", nil)
        .and_return("something")
    end
    let!(:client) do
      VCR.use_cassette "github.com/schema.json" do
        require_relative "../../../../lib/bundler/alive/client/github_graphql"
        Client::SourceCodeClient.new(service_name: :github)
      end
    end

    context "with all alive repository URLs" do
      it "returns `StatusResult`" do
        VCR.use_cassette "github.com/all-alive" do
          urls = [
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/rails/rails", "rails"),
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/whitequark/ast", "ast")
          ]

          result = client.query(urls: urls)
          expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)

          collection = result.collection
          expect(collection["rails"].alive).to eq true
          expect(collection["ast"].alive).to eq true
        end
      end
    end

    context "with URLs include an archived repository" do
      it "returns `StatusResult`" do
        VCR.use_cassette "github.com/includes-archived" do
          urls = [
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/rails/rails", "rails"),
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/rails/journey", "journey")
          ]

          result = client.query(urls: urls)
          expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)

          collection = result.collection
          expect(collection["rails"].alive).to eq true
          expect(collection["journey"].alive).to eq false
        end
      end
    end

    context "with URL which gem name and repository name are different" do
      it "returns `StatusResult`" do
        VCR.use_cassette "github.com/gem_name-and-repository-different" do
          urls = [
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/rails/rails", "rails"),

            # different!
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/faye/websocket-driver-ruby",
                                                        "websocket-extensions")
          ]

          result = client.query(urls: urls)
          expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)

          collection = result.collection
          expect(collection["rails"].alive).to eq true
          expect(collection["websocket-extensions"].alive).to eq true
        end
      end
    end

    context "with URL which repository url and the nameWithOwner case-sensitivity are not same" do
      it "returns `StatusResult`" do
        VCR.use_cassette "github.com/tod" do
          urls = [
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/JackC/tod", "tod")
          ]

          result = client.query(urls: urls)
          expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)

          collection = result.collection
          expect(collection["tod"].alive).to eq true
        end
      end
    end

    context "with forked repository URL" do
      it "returns `StatusResult`" do
        VCR.use_cassette "github.com/masutaka/compare_linker" do
          urls = [
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/masutaka/compare_linker", "compare_linker")
          ]

          result = client.query(urls: urls)
          expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)

          collection = result.collection
          expect(collection["compare_linker"].alive).to eq true
        end
      end
    end

    context "without urls" do
      it "raises a `ArgumentError`" do
        expect { client.query }.to raise_error(ArgumentError)
      end
    end

    context "when unknown error is raised" do
      it "returns `StatusResult` includes an error" do
        # mock
        github_api_client_mock = double("GitHub API Client")
        allow(github_api_client_mock).to receive(:query).and_raise(StandardError, "Unknown Error")
        client.instance_variable_set(:@client, github_api_client_mock)

        urls = [
          Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/whitequark/ast", "aws")
        ]

        result = client.query(urls: urls)
        expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)
        expect(result.rate_limit_exceeded).to eq false
        expect(result.error_messages).to eq ["Unknown Error"]
      end
    end
  end
end
