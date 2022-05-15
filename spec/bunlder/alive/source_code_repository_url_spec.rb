# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::SourceCodeRepositoryUrl do
  describe "#initialize" do
    context "with a valid github.com URL" do
      let!(:url) { "https://github.com/rails/rails" }
      let!(:repository_url) { described_class.new(url, "rails") }

      it "returns `Bundler::Alive::RepositoryUrl`" do
        expect(repository_url).to be_a(Bundler::Alive::SourceCodeRepositoryUrl)
      end

      it "has url" do
        expect(repository_url.url).to eq url
      end

      it "has service_name" do
        expect(repository_url.service_name).to eq :github
      end
    end

    context "with www.github.com URL" do
      let!(:url) { "https://www.github.com/rails/rails" }
      let!(:repository_url) { described_class.new(url, "rails") }

      it "returns `Bundler::Alive::RepositoryUrl`" do
        expect(repository_url).to be_a(Bundler::Alive::SourceCodeRepositoryUrl)
      end

      it "has service_name" do
        expect(repository_url.service_name).to eq :github
      end
    end

    context "with an invalid URL" do
      it "returns `Bundler::Alive::RepositoryUrl::UnSupportedUrl`" do
        expect do
          described_class.new("https://example.com/owner/name", "name")
        end.to raise_error(Bundler::Alive::SourceCodeRepositoryUrl::UnSupportedUrl)
      end
    end
  end
end
