# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::SourceCodeRepository do
  let(:url) { SourceCodeRepositoryUrl.new("https://github.com/rails/rails") }
  let(:client) { Client::SourceCodeClient.new(service_name: :github) }
  let(:repository) { described_class.new(url: url, client: client) }

  describe "#new" do
    context "with valid params" do
      it "returns a `SourceCodeRepository`" do
        expect(repository).to be_a_kind_of(SourceCodeRepository)
      end
    end

    context "with a not RepositoryUrl as an url param" do
      let(:url) { "https://github.com/rails/rails" }
      it "raises a `ArgumentError`" do
        expect { repository }.to raise_error(ArgumentError)
      end
    end

    context "with a not `Client::SourceCodeClient` as a client param" do
      let(:client) { "client" }
      it "raises a `ArgumentError`" do
        expect { repository }.to raise_error(ArgumentError)
      end
    end
  end
end
