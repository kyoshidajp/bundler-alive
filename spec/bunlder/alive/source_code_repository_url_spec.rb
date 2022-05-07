# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::SourceCodeRepositoryUrl do
  let(:repository_url) { described_class.new(url) }

  describe "#initialize" do
    context "with a valid github.com URL" do
      let(:url) { "https://github.com/rails/rails" }

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

    context "with an invalid URL" do
      let(:url) { "https://example.com/owner/name" }

      it "returns `Bundler::Alive::RepositoryUrl::UnSupportedUrl`" do
        expect { repository_url }.to raise_error(Bundler::Alive::SourceCodeRepositoryUrl::UnSupportedUrl)
      end
    end
  end
end
