# frozen_string_literal: true

FactoryBot.define do
  factory :status_result do
    collection { build(:status_collection) }
    error_messages { [] }
    rate_limit_exceeded { false }

    initialize_with do
      new(collection: collection,
          error_messages: error_messages,
          rate_limit_exceeded: rate_limit_exceeded)
    end
  end
end
