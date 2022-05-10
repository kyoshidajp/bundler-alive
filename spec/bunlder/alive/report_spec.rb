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
    it "updates status of gems only unknown" do
      gem1 = Bundler::Alive::Gem.new(name: "journey",
                                     repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/rails/journey"),
                                     alive: false, checked_at: Time.now)
      gem2 = Bundler::Alive::Gem.new(name: "gem2",
                                     repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem2"),
                                     alive: true, checked_at: Time.now)
      gem3 = Bundler::Alive::Gem.new(name: "gem3",
                                     repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem3"),
                                     alive: "unknown", checked_at: Time.now)
      gem4 = Bundler::Alive::Gem.new(name: "gem4",
                                     repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem4"),
                                     alive: true, checked_at: Time.now)
      gem5 = Bundler::Alive::Gem.new(name: "gem5",
                                     repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem5"),
                                     alive: true, checked_at: Time.now)
      gem6 = Bundler::Alive::Gem.new(name: "gem6",
                                     repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem6"),
                                     alive: true, checked_at: Time.now)
      collection = Bundler::Alive::GemCollection.new
                                                .add(gem1.name, gem1).add(gem2.name, gem2)
                                                .add(gem3.name, gem3).add(gem4.name, gem4)
                                                .add(gem5.name, gem5).add(gem6.name, gem6)
      messages = [
        "bundle-alive is not found in gems.org.",
        "Unknown url: "
      ]
      report = Report.new(result: collection, error_messages: messages, rate_limit_exceeded: false)
      report.save_as_file(result_file_path)
      report_from_file = TomlRB.load_file(result_file_path)
      expect(report_from_file["journey"]["repository_url"]).to eq gem1.repository_url.url
      expect(report_from_file["gem2"]["repository_url"]).to eq gem2.repository_url.url
      expect(report_from_file["gem3"]["repository_url"]).to eq gem3.repository_url.url
      expect(report_from_file["gem4"]["repository_url"]).to eq gem4.repository_url.url
      expect(report_from_file["gem5"]["repository_url"]).to eq gem5.repository_url.url
      expect(report_from_file["gem6"]["repository_url"]).to eq gem6.repository_url.url
    end
  end
end
