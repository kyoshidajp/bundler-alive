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

  describe "#total_size" do
    gem1 = Bundler::Alive::Gem.new(name: "gem1", repository_url: "", alive: true, checked_at: Time.now)
    gem2 = Bundler::Alive::Gem.new(name: "gem2", repository_url: "", alive: false, checked_at: Time.now)
    gem3 = Bundler::Alive::Gem.new(name: "gem3", repository_url: "", alive: "unknown", checked_at: Time.now)
    gem4 = Bundler::Alive::Gem.new(name: "gem4", repository_url: "", alive: true, checked_at: Time.now)
    collection = described_class.new
                                .add(gem1.name, gem1).add(gem2.name, gem2)
                                .add(gem3.name, gem3).add(gem4.name, gem4)

    it "returns 4" do
      expect(collection.total_size).to eq 4
    end
  end

  describe "#alive_size" do
    gem1 = Bundler::Alive::Gem.new(name: "gem1", repository_url: "", alive: true, checked_at: Time.now)
    gem2 = Bundler::Alive::Gem.new(name: "gem2", repository_url: "", alive: false, checked_at: Time.now)
    gem3 = Bundler::Alive::Gem.new(name: "gem3", repository_url: "", alive: "unknown", checked_at: Time.now)
    gem4 = Bundler::Alive::Gem.new(name: "gem4", repository_url: "", alive: true, checked_at: Time.now)
    collection = described_class.new
                                .add(gem1.name, gem1).add(gem2.name, gem2)
                                .add(gem3.name, gem3).add(gem4.name, gem4)

    it "returns 2" do
      expect(collection.alive_size).to eq 2
    end
  end

  describe "#dead_size" do
    gem1 = Bundler::Alive::Gem.new(name: "gem1", repository_url: "", alive: true, checked_at: Time.now)
    gem2 = Bundler::Alive::Gem.new(name: "gem2", repository_url: "", alive: false, checked_at: Time.now)
    gem3 = Bundler::Alive::Gem.new(name: "gem3", repository_url: "", alive: "unknown", checked_at: Time.now)
    gem4 = Bundler::Alive::Gem.new(name: "gem4", repository_url: "", alive: false, checked_at: Time.now)
    collection = described_class.new
                                .add(gem1.name, gem1).add(gem2.name, gem2)
                                .add(gem3.name, gem3).add(gem4.name, gem4)

    it "returns 2" do
      expect(collection.dead_size).to eq 2
    end
  end

  describe "#unknown_size" do
    gem1 = Bundler::Alive::Gem.new(name: "gem1", repository_url: "", alive: true, checked_at: Time.now)
    gem2 = Bundler::Alive::Gem.new(name: "gem2", repository_url: "", alive: false, checked_at: Time.now)
    gem3 = Bundler::Alive::Gem.new(name: "gem3", repository_url: "", alive: "unknown", checked_at: Time.now)
    gem4 = Bundler::Alive::Gem.new(name: "gem4", repository_url: "", alive: "unknown", checked_at: Time.now)
    collection = described_class.new
                                .add(gem1.name, gem1).add(gem2.name, gem2)
                                .add(gem3.name, gem3).add(gem4.name, gem4)

    it "returns 2" do
      expect(collection.unknown_size).to eq 2
    end
  end
end
