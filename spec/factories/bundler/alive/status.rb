# frozen_string_literal: true

FactoryBot.define do
  factory :status do
    name { "bundle-alive" }
    repository_url { build(:source_code_repository_url) }
    alive { true }
    checked_at { Time.now }

    initialize_with { new(name: name, repository_url: repository_url, alive: alive, checked_at: checked_at) }
  end
end
