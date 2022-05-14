# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::GemsApi do
  let!(:client) { described_class.new }

  describe "#get_source_code_url" do
    context "with a exists gem on gems.org" do
      it "returns a `SourceCodeRepositoryUrl`" do
        VCR.use_cassette "rubygems.org/api/v1/gems/rails" do
          url = client.send(:get_repository_url, "rails")
          expect(url).to be_a_kind_of(SourceCodeRepositoryUrl)
          expect(url.url).to eq "https://github.com/rails/rails/tree/v7.0.2.4"
        end
      end
    end

    context "with a not exists gem on gems.org" do
      it "raises a `Client::GemsApi::NotFound`" do
        VCR.use_cassette "rubygems.org/api/v1/gems/not-found-gem" do
          expect do
            client.send(:get_repository_url, "not-found-gem")
          end.to raise_error(Client::GemsApi::NotFound)
        end
      end
    end
  end

  describe "#service_with_urls" do
    context "all gems are found" do
      it "returns a Hash<String, Array<SourceCodeRepositoryUrl>>" do
        VCR.use_cassette "rubygems.org/multi_search" do
          service_with_urls = client.service_with_urls(%w[ast journey parallel parser rainbow])
          expected = {
            github:
              [
                SourceCodeRepositoryUrl.new("https://github.com/whitequark/ast", "ast"),
                SourceCodeRepositoryUrl.new("http://github.com/rails/journey", "journey"),
                SourceCodeRepositoryUrl.new("https://github.com/grosser/parallel/tree/v1.22.1", "parallel"),
                SourceCodeRepositoryUrl.new("https://github.com/whitequark/parser/tree/v3.1.2.0", "parser"),
                SourceCodeRepositoryUrl.new("http://github.com/sickill/rainbow", "rainbow")
              ]
          }
          expect(service_with_urls.keys).to eq expected.keys
          expect(service_with_urls[:github].map(&:url)).to eq expected[:github].map(&:url)
        end
      end
    end

    context "when includes not found gems" do
      it "returns only found gems result" do
        VCR.use_cassette "rubygems.org/api/v1/gems/ast" do
          VCR.use_cassette "rubygems.org/api/v1/gems/not-found-gem" do
            service_with_urls = client.service_with_urls(%w[ast not-found-gem])
            expected = {
              github:
                [
                  SourceCodeRepositoryUrl.new("https://github.com/whitequark/ast", "ast")
                ]
            }
            expect(service_with_urls.keys).to eq expected.keys
            expect(service_with_urls[:github].map(&:url)).to eq expected[:github].map(&:url)
          end
        end
      end
    end
  end
end
