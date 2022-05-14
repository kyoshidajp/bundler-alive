# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::Status do
  let!(:checked_at) { Time.now }
  let!(:status) do
    build(:status,
          name: "gem1",
          alive: false,
          checked_at: checked_at,
          repository_url: build(:source_code_repository_url,
                                url: "http://github.com/kyoshidajp/gem1", name: "gem1"))
  end
  describe "#to_h" do
    it "returns decorated hash" do
      expected = {
        repository_url: "http://github.com/kyoshidajp/gem1",
        alive: false,
        checked_at: checked_at
      }
      expect(status.to_h).to eq expected
    end
  end
end
