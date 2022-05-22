# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::StatusResult do
  describe "#initialize" do
    context "without arguments" do
      it "has attributes" do
        status_result = described_class.new
        expect(status_result.collection).to be_an_instance_of(StatusCollection)
        expect(status_result.error_messages).to eq []
        expect(status_result.rate_limit_exceeded).to eq false
      end
    end

    context "with arguments" do
      it "has these attributes" do
        collection = StatusCollection.new
        status_result = described_class.new(collection: collection, error_messages: ["error"],
                                            rate_limit_exceeded: true)
        expect(status_result.collection).to eq collection
        expect(status_result.error_messages).to eq ["error"]
        expect(status_result.rate_limit_exceeded).to eq true
      end
    end
  end

  describe "#merge" do
    it "merged by parameter of `StatusResult`" do
      gem1 = build(:status, name: "gem1", alive: false)
      collection1 = build(:status_collection).add(gem1.name, gem1)
      status_result1 = build(:status_result, collection: collection1, error_messages: ["first"],
                                             rate_limit_exceeded: false)

      gem2 = build(:status, name: "gem2", alive: false)
      collection2 = build(:status_collection).add(gem2.name, gem2)
      status_result2 = build(:status_result, collection: collection2, error_messages: ["second"],
                                             rate_limit_exceeded: true)

      merged_status_result = status_result1.merge(status_result2)
      expect(merged_status_result.collection.names).to eq %w[gem1 gem2]
      expect(merged_status_result.error_messages).to eq %w[first second]
      expect(merged_status_result.rate_limit_exceeded).to eq true
    end
  end
end
