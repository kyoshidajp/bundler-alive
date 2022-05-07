# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::GemsApi do
  let(:client) { described_class.new }

  describe "#get_source_code_url" do
    context "with a exists gem on gems.org" do
      it "returns a `SourceCodeRepositoryUrl`" do
        VCR.use_cassette "rubygems.org/rails" do
          url = client.get_repository_url("rails")
          expect(url).to be_a_kind_of(SourceCodeRepositoryUrl)
          expect(url.url).to eq "https://github.com/rails/rails/tree/v7.0.2.4"
        end
      end
    end

    context "with a not exists gem on gems.org" do
      it "raises a `Client::GemsApi::NotFound`" do
        VCR.use_cassette "rubygems.org/not-found-gem" do
          expect do
            client.get_repository_url("not-found-gem")
          end.to raise_error(Client::GemsApi::NotFound)
        end
      end
    end
  end
end
