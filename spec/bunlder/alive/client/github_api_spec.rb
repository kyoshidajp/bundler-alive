# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::GithubApi do
  let!(:client) do
    client = Client::SourceCodeClient.new(service_name: :github)
    client.extend described_class
    client
  end

  describe "#create_client" do
    it "returns `Octokit::Client` instance" do
      obj = Object.new
      obj.extend described_class
      expect(obj.create_client).to be_an_instance_of(Octokit::Client)
    end
  end

  describe "#query" do
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

    context "without urls" do
      it "raises a `ArgumentError`" do
        expect { client.query }.to raise_error(ArgumentError)
      end
    end

    context "when API rate limit exceeded" do
      it "returns `StatusResult` includes an error" do
        stub_const("Bundler::Alive::Client::GithubApi::RETRIES_ON_TOO_MANY_REQUESTS", 1)
        stub_const("Bundler::Alive::Client::GithubApi::RETRY_INTERVAL_SEC_ON_TOO_MANY_REQUESTS", 0)

        VCR.use_cassette("github.com/rate-limit-exceeded", allow_playback_repeats: true) do
          urls = [
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/whitequark/ast", "aws"),
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/rails/journey", "journey"),
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/grosser/parallel", "parallel"),
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/whitequark/parser", "parser"),
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/sickill/rainbow", "rainbow")
          ]

          result = client.query(urls: urls)
          expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)
          expect(result.rate_limit_exceeded).to eq true
          expect(result.error_messages).not_to be_nil
        end
      end
    end

    context "when unknown error is raised" do
      it "returns `StatusResult` includes an error" do
        # mock
        github_api_client_mock = double("GitHub API Client")
        allow(github_api_client_mock).to receive(:search_repositories).and_raise(StandardError, "Unknown Error")
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
