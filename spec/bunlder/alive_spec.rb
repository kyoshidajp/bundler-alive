# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bundler::Alive do
  it "has a version number" do
    expect(Bundler::Alive::VERSION).not_to be nil
  end
end
