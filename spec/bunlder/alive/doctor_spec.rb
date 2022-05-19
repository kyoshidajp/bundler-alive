# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Doctor do
  let!(:lock_file) { "spec/fixtures/files/Gemfile.lock" }
  let!(:config) { "spec/fixtures/files/.bundler-alive.yml" }
  let!(:doctor) { described_class.new(lock_file, config) }

  describe "#diagnose" do
    context "when not exceeding GitHub's rate limit" do
      it "diagnose gems" do
        VCR.use_cassette "rubygems.org/multi_search" do
          VCR.use_cassette "github/bulk_search2" do
            report = doctor.diagnose

            expect(report).to be_a_kind_of(Report)
            expect(report.result.to_h.keys).to eq %w[ast bundle-alive journey parallel parser rainbow]
          end
        end
      end
    end

    context "when exceeding GitHub's rate limit" do
      it "report rate limit exceeded" do
        # without retrying
        stub_const("Bundler::Alive::Client::GitHubApi::RETRIES_ON_TOO_MANY_REQUESTS", 0)

        VCR.use_cassette "rubygems.org/multi_search" do
          VCR.use_cassette("github.com/rate-limit-exceeded2") do
            report = doctor.diagnose

            expect(report.rate_limit_exceeded).to eq true
          end
        end
      end
    end
  end
end
