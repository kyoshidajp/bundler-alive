# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Client::GitlabApi do
  describe "#create_client" do
    context "when access token is set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch)
          .with(Bundler::Alive::Client::GitlabApi::ACCESS_TOKEN_ENV_NAME, nil)
          .and_return("something")
      end
      it "returns `Gitlab::Client` instance" do
        obj = Object.new
        obj.extend described_class
        expect(obj.create_client).to be_an_instance_of(Gitlab::Client)
      end
    end

    context "when access token isn't set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch)
          .with(Bundler::Alive::Client::GitlabApi::ACCESS_TOKEN_ENV_NAME, nil)
          .and_return(nil)
      end
      it "raises `AccessTokenNotFoundError`" do
        obj = Object.new
        obj.extend described_class
        message = "Environment variable #{Bundler::Alive::Client::GitlabApi::ACCESS_TOKEN_ENV_NAME} is not set."\
                  " Need to set GitLab Personal Access Token to be authenticated at gitlab.com API."\
                  " See: https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html"
        expect do
          obj.create_client
        end.to raise_error(Bundler::Alive::Client::GitlabApi::AccessTokenNotFoundError, message)
      end
    end
  end

  describe "#query" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch)
        .with(Bundler::Alive::Client::GitlabApi::ACCESS_TOKEN_ENV_NAME, nil)
        .and_return("something")
    end

    context "with all alive repository URLs" do
      it "returns `StatusResult`" do
        client = Client::SourceCodeClient.new(service_name: :gitlab)
        client.extend described_class

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
        client = Client::SourceCodeClient.new(service_name: :gitlab)
        client.extend described_class

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
