# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::SourceCodeClient do
  describe "#initialize" do
    context "with github.com" do
      it "includes `Client::GitHubApi`" do
        client = described_class.new(service_name: :github)
        expect(client).to be_a_kind_of(Client::GitHubApi)
      end
    end

    context "with unknown service_name" do
      it "raises a `ArgumentError`" do
        expect { described_class.new(service_name: "gitlab") }.to raise_error(ArgumentError)
      end
    end
  end
end
