# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::SourceCodeRepository do
  describe "#new" do
    context "with a valid param" do
      it "returns a `SourceCodeRepository`" do
        url = SourceCodeRepositoryUrl.new("https://github.com/rails/rails", "rails")
        repository = described_class.new(url: url)
        expect(repository).to be_a_kind_of(SourceCodeRepository)
      end
    end

    context "with a not RepositoryUrl as an url param" do
      it "raises a `ArgumentError`" do
        url = "https://github.com/rails/rails"
        expect { described_class.new(url: url) }.to raise_error(ArgumentError)
      end
    end
  end
end
