# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Doctor do
  let!(:lock_file) { "spec/fixtures/files/Gemfile.lock" }
  let!(:result_file) { "spec/fixtures/files/result.toml" }
  let!(:result_file_org) do
    file_path = "#{lock_file}.org"
    FileUtils.cp(result_file, file_path)
    file_path
  end
  let!(:doctor) { described_class.new(lock_file, result_file) }

  before(:each) do
    result_file_org
  end

  after(:each) do
    # restore result file
    # this could not be run due to unexpected Error
    FileUtils.mv(result_file_org, result_file, **{ force: true })
  end

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

      it "updates status only alive is true or unknown" do
        VCR.use_cassette "rubygems.org/multi_search" do
          report = doctor.diagnose

          result = report.result
          original_toml = TomlRB.load_file(result_file_org)

          expect(result["ast"].alive).to eq true
          expect(result["ast"].checked_at).to be > Time.parse("2022-05-07T10:58:50Z")
          expect(result["parallel"].alive).to eq true
          expect(result["parallel"].checked_at).to be > Time.parse("2022-05-07T12:24:11Z")
          expect(result["journey"].alive).to eq original_toml["journey"]["alive"]
          expect(result["journey"].checked_at).to eq original_toml["journey"]["checked_at"]
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
