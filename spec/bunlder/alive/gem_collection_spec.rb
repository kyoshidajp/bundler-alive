# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::GemCollection do
  describe "#all_alive?" do
    context "all gems are alive" do
      gem1 = Bundler::Alive::Gem.new(name: "gem1", repository_url: "", alive: true, checked_at: Time.now)
      gem2 = Bundler::Alive::Gem.new(name: "gem2", repository_url: "", alive: true, checked_at: Time.now)
      collection = described_class.new.add(gem1.name, gem1).add(gem2.name, gem2)

      it "returns true" do
        expect(collection.all_alive?).to eq true
      end
    end

    context "includes unknown gem" do
      gem1 = Bundler::Alive::Gem.new(name: "gem1", repository_url: "", alive: true, checked_at: Time.now)
      gem2 = Bundler::Alive::Gem.new(name: "gem2", repository_url: "",
                                     alive: Bundler::Alive::Gem::ALIVE_UNKNOWN, checked_at: Time.now)
      collection = described_class.new.add(gem1.name, gem1).add(gem2.name, gem2)

      it "returns false" do
        expect(collection.all_alive?).to eq false
      end
    end

    context "includes not alive gem" do
      gem1 = Bundler::Alive::Gem.new(name: "gem1", repository_url: "", alive: true, checked_at: Time.now)
      gem2 = Bundler::Alive::Gem.new(name: "gem2", repository_url: "", alive: false, checked_at: Time.now)
      collection = described_class.new.add(gem1.name, gem1).add(gem2.name, gem2)

      it "returns false" do
        expect(collection.all_alive?).to eq false
      end
    end
  end
end
