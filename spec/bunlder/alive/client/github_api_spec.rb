# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::GitHubApi do
  let(:client) do
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

    context "without urls" do
      it "raises a `ArgumentError`" do
        expect { client.query }.to raise_error(ArgumentError)
      end
    end

    context "when API rate limit exceeded" do
      it "returns `StatusResult` includes an error" do
        VCR.use_cassette "github.com/rate-limit-exceeded" do
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
  end
end
