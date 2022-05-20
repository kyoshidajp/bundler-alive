# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive::StatusCollection do
  describe "#all_alive?" do
    context "all gems are alive" do
      subject(:collection) do
        gem1 = build(:status, name: "gem1", alive: true)
        gem2 = build(:status, name: "gem2", alive: true)
        described_class.new.add(gem1.name, gem1).add(gem2.name, gem2)
      end

      it "returns true" do
        expect(collection.all_alive?).to eq true
      end
    end

    context "includes unknown gem" do
      subject(:collection) do
        gem1 = build(:status, name: "gem1")
        gem2 = build(:status, name: "gem2", alive: Bundler::Alive::Status::ALIVE_UNKNOWN)
        described_class.new.add(gem1.name, gem1).add(gem2.name, gem2)
      end

      it "returns false" do
        expect(collection.all_alive?).to eq false
      end
    end

    context "includes not alive gem" do
      subject(:collection) do
        gem1 = build(:status, name: "gem1", alive: true)
        gem2 = build(:status, name: "gem2", alive: false)
        described_class.new.add(gem1.name, gem1).add(gem2.name, gem2)
      end

      it "returns false" do
        expect(collection.all_alive?).to eq false
      end
    end
  end

  describe "#total_size" do
    subject(:collection) do
      gem1 = build(:status, name: "gem1")
      gem2 = build(:status, name: "gem2")
      gem3 = build(:status, name: "gem3")
      gem4 = build(:status, name: "gem4")
      described_class.new.add(gem1.name, gem1).add(gem2.name, gem2)
                     .add(gem3.name, gem3).add(gem4.name, gem4)
    end

    it "returns 4" do
      expect(collection.total_size).to eq 4
    end
  end

  describe "#alive_size" do
    subject(:collection) do
      gem1 = build(:status, name: "gem1", alive: false)
      gem2 = build(:status, name: "gem2", alive: true)
      gem3 = build(:status, name: "gem3", alive: false)
      gem4 = build(:status, name: "gem4", alive: true)
      described_class.new
                     .add(gem1.name, gem1).add(gem2.name, gem2)
                     .add(gem3.name, gem3).add(gem4.name, gem4)
    end

    it "returns 2" do
      expect(collection.alive_size).to eq 2
    end
  end

  describe "#archived_size" do
    subject(:collection) do
      gem1 = build(:status, name: "gem1", alive: false)
      gem2 = build(:status, name: "gem2", alive: true)
      gem3 = build(:status, name: "gem3", alive: false)
      gem4 = build(:status, name: "gem4", alive: false)
      described_class.new
                     .add(gem1.name, gem1).add(gem2.name, gem2)
                     .add(gem3.name, gem3).add(gem4.name, gem4)
    end

    it "returns 3" do
      expect(collection.archived_size).to eq 3
    end
  end

  describe "#unknown_size" do
    subject(:collection) do
      gem1 = build(:status, name: "gem1", alive: false)
      gem2 = build(:status, name: "gem2", alive: Bundler::Alive::Status::ALIVE_UNKNOWN)
      gem3 = build(:status, name: "gem3", alive: false)
      gem4 = build(:status, name: "gem4", alive: false)
      described_class.new
                     .add(gem1.name, gem1).add(gem2.name, gem2)
                     .add(gem3.name, gem3).add(gem4.name, gem4)
    end
    it "returns 1" do
      expect(collection.unknown_size).to eq 1
    end
  end
end
