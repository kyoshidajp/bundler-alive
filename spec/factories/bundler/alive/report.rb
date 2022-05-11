# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    result { build(:result) }

    initialize_with { new(result) }
  end
end
