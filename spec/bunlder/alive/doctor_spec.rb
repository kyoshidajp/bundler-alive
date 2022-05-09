# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Bundler::Alive::Doctor do
  let(:lock_file) { "spec/fixtures/files/Gemfile.lock" }
  let(:result_file) { "spec/fixtures/files/result.toml" }
  let(:result_file_org) do
    file_path = "#{lock_file}.org"
    FileUtils.cp(result_file, file_path)
    file_path
  end
  let(:doctor) { described_class.new(lock_file, result_file) }

  before(:each) do
    result_file_org

    VCR.insert_cassette("github.com/whitequark/ast")
    VCR.insert_cassette("github.com/whitequark/parser")
    VCR.insert_cassette("github.com/grosser/parallel")
    VCR.insert_cassette("github.com/sickill/rainbow")
    VCR.insert_cassette("github.com/rails/journey")
    VCR.insert_cassette("rubygems.org/bundle-alive")
    VCR.insert_cassette("rubygems.org/ast")
    VCR.insert_cassette("rubygems.org/parallel")
    VCR.insert_cassette("rubygems.org/parser")
    VCR.insert_cassette("rubygems.org/rainbow")
    VCR.insert_cassette("rubygems.org/journey")
  end

  after(:each) do
    # restore result file
    # this could not be run due to unexpected Error
    FileUtils.mv(result_file_org, result_file, **{ force: true })

    VCR.eject_cassette("github.com/whitequark/ast")
    VCR.eject_cassette("github.com/whitequark/parser")
    VCR.eject_cassette("github.com/grosser/parallel")
    VCR.eject_cassette("github.com/sickill/rainbow")
    VCR.eject_cassette("github.com/rails/journey")
    VCR.eject_cassette("rubygems.org/bundle-alive")
    VCR.eject_cassette("rubygems.org/ast")
    VCR.eject_cassette("rubygems.org/parallel")
    VCR.eject_cassette("rubygems.org/parser")
    VCR.eject_cassette("rubygems.org/rainbow")
    VCR.eject_cassette("rubygems.org/journey")
  end

  describe "#diagnose" do
    it "diagnose gems" do
      doctor.diagnose

      updated_toml = TomlRB.load_file(result_file)
      expect(updated_toml.keys).to eq %w[ast bundle-alive journey parallel parser rainbow]
    end

    it "updates status of gems only unknown" do
      doctor.diagnose

      updated_toml = TomlRB.load_file(result_file)
      original_toml = TomlRB.load_file(result_file_org)

      expect(updated_toml["ast"]["alive"]).to eq original_toml["ast"]["alive"]
      expect(updated_toml["ast"]["checked_at"]).to eq original_toml["ast"]["checked_at"]
      expect(updated_toml["parallel"]["alive"]).to eq true
      expect(updated_toml["parallel"]["checked_at"]).to be > Time.parse("2022-05-07T12:24:11Z")
      expect(updated_toml["journey"]["alive"]).to eq original_toml["journey"]["alive"]
      expect(updated_toml["journey"]["checked_at"]).to eq original_toml["journey"]["checked_at"]
    end

    it "has not alive gems are found" do
      doctor.diagnose
      expect(doctor.message).to eq "Not alive gems are found!"
    end

    context "when all gems are alive" do
      before do
        allow(doctor).to receive(:all_alive).and_return(true)
        allow(doctor).to receive(:rate_limit_exceeded).and_return(false)
      end
      it "has all gems are alive" do
        doctor.diagnose
        expect(doctor.message).to eq "All gems are alive!"
      end
    end

    context "when raised a GitHub's rate limit exceeded error" do
      before(:each) do
        VCR.insert_cassette("github.com/sickill/rate-limit-exceeded-rainbow")
      end
      after(:each) do
        VCR.eject_cassette("github.com/sickill/rate-limit-exceeded-rainbow")
      end

      it "all of gems are exist" do
        doctor.diagnose

        updated_toml = TomlRB.load_file(result_file)
        expect(updated_toml.keys).to eq %w[ast bundle-alive journey parallel parser rainbow]
      end

      it "gems that failed to get are added" do
        doctor.diagnose

        updated_toml = TomlRB.load_file(result_file)
        expect(updated_toml["rainbow"]["alive"]).to eq "unknown"
        expect(updated_toml["rainbow"]["repository_url"]).to eq "http://github.com/sickill/rainbow"
        expect(updated_toml["rainbow"]["checked_at"]).not_to be nil
      end

      it "has too many error message" do
        doctor.diagnose
        expect(doctor.message).to eq "Too many requested! Retry later."
      end
    end
  end

  describe "#report" do
    it "reports result" do
      doctor.diagnose

      expected = <<~RESULT
        Name: journey
        URL: http://github.com/rails/journey
        Status: false

      RESULT
      expect { doctor.report }.to output(expected).to_stdout
    end
  end
end
