# frozen_string_literal: true

require "faraday"
require "json"

module Bundler
  module Alive
    module Client
      # API Client for RubyGems.org API
      class GemsApi
        class NotFound < StandardError
        end

        def get_repository_uri(gem_name)
          url = api_url(gem_name)
          response = connection.get(url)

          raise NotFound, "#{gem_name} is not found in gems.org." if response.status == 404

          body = JSON.parse(response.body)
          raw_uri = body["source_code_uri"] || body["homepage_uri"]
          SourceCodeRepositoryUrl.new(raw_uri)
        end

        private

        def api_url(gem_name)
          "https://rubygems.org/api/v1/gems/#{gem_name}.json"
        end

        def connection
          return @connection if instance_variable_defined?(:@connection)

          @connection = Faraday.new do |connection|
            connection.adapter :net_http
          end
        end
      end
    end
  end
end
