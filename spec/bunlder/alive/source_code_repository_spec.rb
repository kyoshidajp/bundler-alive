# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::SourceCodeRepository do
  let(:url) { SourceCodeRepositoryUrl.new("https://github.com/rails/rails") }
  let(:repository) { described_class.new(url: url) }

  describe "#new" do
    context "with a valid param" do
      it "returns a `SourceCodeRepository`" do
        expect(repository).to be_a_kind_of(SourceCodeRepository)
      end
    end

    context "with a not RepositoryUrl as an url param" do
      let(:url) { "https://github.com/rails/rails" }
      it "raises a `ArgumentError`" do
        expect { repository }.to raise_error(ArgumentError)
      end
    end
  end
end
