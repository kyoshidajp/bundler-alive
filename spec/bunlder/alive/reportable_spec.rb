# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Bundler::Alive::CLI::Reportable do
  let(:cli_instance) do
    base = ::Thor::Shell::Basic.new
    base.extend described_class
    base
  end

  describe "#print_report" do
    context "when including not alive gems" do
      it "reports result" do
        gem1 = Bundler::Alive::Gem.new(name: "gem1",
                                       repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem1"),
                                       alive: true, checked_at: Time.now)
        gem2 = Bundler::Alive::Gem.new(name: "gem2",
                                       repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem2"),
                                       alive: true, checked_at: Time.now)
        collection = Bundler::Alive::GemCollection.new
                                                  .add(gem1.name, gem1).add(gem2.name, gem2)
        report = Report.new(result: collection, error_messages: [], rate_limit_exceeded: false)
        expected = <<~RESULT



          Total: 2 (Dead: 0, Alive: 2, Unknown: 0)
          All gems are alive!
        RESULT
        expect do
          cli_instance.print_report(report)
        end.to output(expected).to_stdout
      end
    end

    context "when rate limit exceeded" do
      it "reports result" do
        gem1 = Bundler::Alive::Gem.new(name: "gem1",
                                       repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem1"),
                                       alive: true, checked_at: Time.now)
        gem2 = Bundler::Alive::Gem.new(name: "gem2",
                                       repository_url: Bundler::Alive::SourceCodeRepositoryUrl.new("http://github.com/kyoshidajp/gem2"),
                                       alive: "unknown", checked_at: Time.now)
        collection = Bundler::Alive::GemCollection.new
                                                  .add(gem1.name, gem1).add(gem2.name, gem2)
        report = Report.new(result: collection, error_messages: [], rate_limit_exceeded: true)
        expected = <<~RESULT



          Total: 2 (Dead: 0, Alive: 1, Unknown: 1)
          Too many requested! Retry later.
        RESULT
        expect do
          cli_instance.print_report(report)
        end.to output(expected).to_stdout
      end
    end

    context "when including not alive gems" do
      it "reports result" do
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
        expected = <<~RESULT

          Name: journey
          URL: http://github.com/rails/journey
          Status: false

          bundle-alive is not found in gems.org.
          Unknown url:#{" "}

          Total: 6 (Dead: 1, Alive: 4, Unknown: 1)
          Not alive gems are found!
        RESULT
        expect do
          cli_instance.print_report(report)
        end.to output(expected).to_stdout
      end
    end
  end
end
