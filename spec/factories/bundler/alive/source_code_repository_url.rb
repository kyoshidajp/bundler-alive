# frozen_string_literal: true

FactoryBot.define do
  factory :source_code_repository_url do
    url { "https://github.com/rails/rails" }
    name { "sample" }

    initialize_with { new(url, name) }
  end
end
