# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::GitlabApi do
  let!(:client) do
    client = Client::SourceCodeClient.new(service_name: :gitlab)
    client.extend described_class
    client
  end

  describe "#create_client" do
    it "returns `Gitlab::Client` instance" do
      obj = Object.new
      obj.extend described_class
      expect(obj.create_client).to be_an_instance_of(Gitlab::Client)
    end
  end

  describe "#query" do
    context "with all alive repository URLs" do
      it "returns `StatusResult`" do
        VCR.use_cassette "gitlab.com/gitlab-org/gitlab-omniauth-openid-connect" do
          VCR.use_cassette "gitlab.com/gitlab-org/gitlab-chronic" do
            urls = [
              Bundler::Alive::SourceCodeRepositoryUrl.new(
                "https://gitlab.com/gitlab-org/gitlab-omniauth-openid-connect", "gitlab-omniauth-openid-connect"
              ),
              Bundler::Alive::SourceCodeRepositoryUrl.new("https://gitlab.com/gitlab-org/gitlab-chronic",
                                                          "gitlab-chronic")
            ]

            result = client.query(urls: urls)
            expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)

            collection = result.collection
            expect(collection["gitlab-omniauth-openid-connect"].alive).to eq true
            expect(collection["gitlab-chronic"].alive).to eq true
          end
        end
      end
    end

    context "when unknown error is raised" do
      it "returns `StatusResult` includes an error" do
        VCR.use_cassette "gitlab.com/gitlab-org/declarative-policy" do
          urls = [
            Bundler::Alive::SourceCodeRepositoryUrl.new("https://gitlab.com/gitlab-org/declarative-policy",
                                                        "declarative-policy")
          ]

          result = client.query(urls: urls)
          expect(result).to be_an_instance_of(Bundler::Alive::StatusResult)

          collection = result.collection
          expect(collection["declarative-policy"].alive).to eq false
          expect(result.error_messages.empty?).to eq false
        end
      end
    end
  end
end
