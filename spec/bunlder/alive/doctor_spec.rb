# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Doctor do
  let!(:lock_file) { "spec/fixtures/files/Gemfile.lock" }
  let!(:config) { "spec/fixtures/files/.bundler-alive.yml" }
  let!(:doctor) { described_class.new(lock_file: lock_file, config_file: config, ignore_gems: []) }

  describe "#diagnose" do
    context "when not exceeding GitHub's rate limit" do
      it "diagnose gems" do
        VCR.use_cassette "github.com/schema.json" do
          VCR.use_cassette "rubygems.org/multi_search" do
            VCR.use_cassette "github/bulk_search2" do
              report = doctor.diagnose

              expect(report).to be_a_kind_of(Report)
              expect(report.result.to_h.keys).to eq %w[ast bundle-alive journey parallel parser rainbow]
            end
          end
        end
      end
    end
  end
end
