# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::GitHubApi do
  let(:client) do
    client = Client::SourceCodeClient.new(service_name: :github)
    client.extend described_class
    client
  end

  describe "#archived?" do
    context "with an alive repository URL" do
      it "returns false" do
        VCR.use_cassette "github.com/rails/rails" do
          url = Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/rails/rails")
          expect(client.archived?(url)).to eq false
        end
      end
    end

    context "with an archived repository URL" do
      it "returns true" do
        VCR.use_cassette "github.com/rails/journey" do
          url = Bundler::Alive::SourceCodeRepositoryUrl.new("https://github.com/rails/journey")
          expect(client.archived?(url)).to eq true
        end
      end
    end

    context "with a not RepositoryURL" do
      it "raises a `NotImplementedError`" do
        url = "https://github.com/rails/rails"
        expect { client.archived?(url) }.to raise_error(NotImplementedError)
      end
    end
  end
end
