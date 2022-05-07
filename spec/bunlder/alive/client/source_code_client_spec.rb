# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::SourceCodeClient do
  let(:service_name) { :github }
  let(:client) { described_class.new(service_name: service_name) }

  describe "#initialize" do
    context "with github.com" do
      let(:service_name) { :github }
      it "includes `Client::GitHubApi`" do
        expect(client).to be_a_kind_of(Client::GitHubApi)
      end
    end

    context "with unknown service_name" do
      let(:service_name) { "gitlab" }
      it "raises a `ArgumentError`" do
        expect { client }.to raise_error(ArgumentError)
      end
    end
  end
end
