# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Report do
  describe "#save_as_file" do
    let(:result_file_path) { "spec/fixtures/files/result-for-report.toml" }
    before do
      FileUtils.remove_file(result_file_path) if File.exist?(result_file_path)
    end
    after do
      FileUtils.remove_file(result_file_path)
    end

    let(:gem1) do
      build(:status,
            name: "gem1",
            repository_url: build(:source_code_repository_url,
                                  url: "http://github.com/kyoshidajp/gem1", name: "gem1"))
    end
    let(:gem2) do
      build(:status,
            name: "gem2",
            repository_url: build(:source_code_repository_url,
                                  url: "http://github.com/kyoshidajp/gem2", name: "gem2"))
    end

    subject(:result) do
      collection = Bundler::Alive::StatusCollection.new.add(gem1.name, gem1).add(gem2.name, gem2)
      messages = [
        "bundle-alive is not found in gems.org.",
        "Unknown url: "
      ]
      build(:status_result, collection: collection, error_messages: messages, rate_limit_exceeded: false)
    end
    it "updates status of gems only unknown" do
      report = Report.new(result)
      report.save_as_file(result_file_path)
      report_from_file = TomlRB.load_file(result_file_path)
      expect(report_from_file["gem1"]["repository_url"]).to eq gem1.repository_url.url
      expect(report_from_file["gem2"]["repository_url"]).to eq gem2.repository_url.url
    end
  end
end
