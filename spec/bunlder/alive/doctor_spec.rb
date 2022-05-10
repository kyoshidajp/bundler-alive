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
      report = doctor.diagnose

      expect(report).to be_a_kind_of(Report)
      expect(report.result.to_h.keys).to eq %w[ast bundle-alive journey parallel parser rainbow]
    end

    it "updates status of gems only unknown" do
      report = doctor.diagnose

      result = report.result
      original_toml = TomlRB.load_file(result_file_org)

      expect(result["ast"].alive).to eq original_toml["ast"]["alive"]
      expect(result["ast"].checked_at).to eq original_toml["ast"]["checked_at"]
      expect(result["parallel"].alive).to eq true
      expect(result["parallel"].checked_at).to be > Time.parse("2022-05-07T12:24:11Z")
      expect(result["journey"].alive).to eq original_toml["journey"]["alive"]
      expect(result["journey"].checked_at).to eq original_toml["journey"]["checked_at"]
    end

    context "when raised a GitHub's rate limit exceeded error" do
      before(:each) do
        VCR.insert_cassette("github.com/sickill/rate-limit-exceeded-rainbow")
      end
      after(:each) do
        VCR.eject_cassette("github.com/sickill/rate-limit-exceeded-rainbow")
      end

      it "all of gems are exist" do
        report = doctor.diagnose

        expect(report.result.to_h.keys).to eq %w[ast bundle-alive journey parallel parser rainbow]
      end

      it "gems that failed to get are added" do
        report = doctor.diagnose

        result = report.result
        expect(result["rainbow"].alive).to eq "unknown"
        expect(result["rainbow"].repository_url.url).to eq "http://github.com/sickill/rainbow"
        expect(result["rainbow"].checked_at).not_to be nil
      end
    end
  end

  describe "#all_alive?" do
    context "when all gems are alive" do
      before do
        collection = double(GemCollection)
        allow(collection).to receive(:all_alive?).and_return(true)
        allow(doctor).to receive(:result).and_return(collection)
      end
      it "returns true" do
        expect(doctor.all_alive?).to eq true
      end
    end

    context "when included not alive gems" do
      before do
        collection = double(GemCollection)
        allow(collection).to receive(:all_alive?).and_return(false)
        allow(doctor).to receive(:result).and_return(collection)
      end
      it "returns false" do
        expect(doctor.all_alive?).to eq false
      end
    end
  end
end
