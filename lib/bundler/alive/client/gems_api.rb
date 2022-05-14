# frozen_string_literal: true

require "faraday"
require "json"

module Bundler
  module Alive
    module Client
      #
      # API Client for RubyGems.org API
      #
      # @see https://guides.rubygems.org/rubygems-org-api/
      #
      class GemsApi
        #
        # Not found in rubygems.org error
        #
        class NotFound < StandardError
        end

        #
        # Returns repository urls
        #
        # @param [Array<String>] gem_names
        #
        # @return [Hash<String, SourceCodeRepositoryUrl>]
        #
        def service_with_urls(gem_names, &block)
          urls = get_repository_urls(gem_names, &block)
          urls.each_with_object({}) do |url, hash|
            service_name = url.service_name
            hash[service_name] = Array(hash[service_name]) << url
          end
        end

        private

        def api_url(gem_name)
          "https://rubygems.org/api/v1/gems/#{gem_name}.json"
        end

        def connection
          Faraday.new do |connection|
            connection.adapter :net_http
          end
        end

        #
        # Returns repository url
        #
        # @param [String] gem_name
        #
        # @return [SourceCodeRepositoryUrl]
        #
        def get_repository_url(gem_name)
          url = api_url(gem_name)
          response = connection.get(url)

          raise NotFound, gem_name unless response.success?

          body = JSON.parse(response.body)
          raw_url = body["source_code_uri"] || body["homepage_uri"]
          SourceCodeRepositoryUrl.new(raw_url, gem_name)
        end

        def get_repository_urls(gem_names)
          result = gem_names.map do |gem_name|
            yield if block_given?
            get_repository_url(gem_name)
          rescue StandardError => e
            p e
          end

          result.find_all { |obj| obj.instance_of?(Alive::SourceCodeRepositoryUrl) }
        end
      end
    end
  end
end
