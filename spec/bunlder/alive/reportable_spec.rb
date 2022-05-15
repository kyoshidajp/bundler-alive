# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::CLI::Reportable do
  let!(:cli_instance) do
    base = ::Thor::Shell::Basic.new
    base.extend described_class
    base
  end

  describe "#print_report" do
    context "when including not alive gems" do
      let!(:report) do
        gem1 = build(:status, name: "gem1")
        gem2 = build(:status, name: "gem2")
        collection = Bundler::Alive::StatusCollection.new
                                                     .add(gem1.name, gem1).add(gem2.name, gem2)
        result = build(:status_result, collection: collection)
        build(:report, result: result)
      end
      it "reports result" do
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
      let!(:report) do
        gem1 = build(:status, name: "gem1", alive: true)
        gem2 = build(:status, name: "gem2", alive: Bundler::Alive::Status::ALIVE_UNKNOWN)
        collection = Bundler::Alive::StatusCollection.new
                                                     .add(gem1.name, gem1).add(gem2.name, gem2)
        result = build(:status_result, collection: collection, rate_limit_exceeded: true)
        build(:report, result: result)
      end
      it "reports result" do
        expected = <<~RESULT



          Total: 2 (Dead: 0, Alive: 1, Unknown: 1)
          Too many requested! Retry later.
          Unknown gems are found!
        RESULT
        expect do
          cli_instance.print_report(report)
        end.to output(expected).to_stdout
      end
    end

    context "when including not alive gems" do
      let!(:report) do
        gem1 = build(:status, name: "gem1", alive: false,
                              repository_url: build(:source_code_repository_url,
                                                    url: "http://github.com/kyoshidajp/gem1", name: "gem1"))
        gem2 = build(:status, name: "gem2", alive: Bundler::Alive::Status::ALIVE_UNKNOWN,
                              repository_url: build(:source_code_repository_url,
                                                    url: "http://github.com/kyoshidajp/gem2", name: "gem2"))
        gem3 = build(:status, name: "gem3", alive: true,
                              repository_url: build(:source_code_repository_url,
                                                    url: "http://github.com/kyoshidajp/gem3", name: "gem3"))
        gem4 = build(:status, name: "gem4", alive: true,
                              repository_url: build(:source_code_repository_url,
                                                    url: "http://github.com/kyoshidajp/gem4", name: "gem4"))
        gem5 = build(:status, name: "gem5", alive: true,
                              repository_url: build(:source_code_repository_url,
                                                    url: "http://github.com/kyoshidajp/gem5", name: "gem5"))
        gem6 = build(:status, name: "gem6", alive: true,
                              repository_url: build(:source_code_repository_url,
                                                    url: "http://github.com/kyoshidajp/gem6", name: "gem6"))
        collection = Bundler::Alive::StatusCollection.new
                                                     .add(gem1.name, gem1).add(gem2.name, gem2)
                                                     .add(gem3.name, gem3).add(gem4.name, gem4)
                                                     .add(gem5.name, gem5).add(gem6.name, gem6)
        messages = [
          "gem2 is not found in gems.org.",
          "Unknown url: "
        ]
        result = build(:status_result, collection: collection, rate_limit_exceeded: false,
                                       error_messages: messages)
        build(:report, result: result)
      end
      it "reports result" do
        expected = <<~RESULT

          Name: gem1
          URL: http://github.com/kyoshidajp/gem1
          Status: false

          gem2 is not found in gems.org.
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
