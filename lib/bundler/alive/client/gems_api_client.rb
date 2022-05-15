# frozen_string_literal: true

require "faraday"
require "json"

module Bundler
  module Alive
    module Client
      #
      # RubyGems.org API Client
      #
      # @see https://guides.rubygems.org/rubygems-org-api/
      #
      class GemsApiClient
        #
        # Not found in rubygems.org error
        #
        class NotFound < StandardError
        end

        def initialize
          @error_messages = []
        end

        #
        # Gets gems from RubyGems.org
        #
        # @param [Array<String>] gem_names
        #
        # @return [Client::GemsApiResponse]
        #
        def gems_api_response(gem_names, &block)
          urls = service_with_urls(gem_names, &block)
          $stdout.puts <<~MESSAGE

            Get all source code repository URLs of gems are done!
          MESSAGE
          Client::GemsApiResponse.new(
            service_with_urls: urls,
            error_messages: error_messages
          )
        end

        private

        attr_accessor :error_messages

        def api_url(gem_name)
          "https://rubygems.org/api/v1/gems/#{gem_name}.json"
        end

        def connection
          Faraday.new do |connection|
            connection.adapter :net_http
          end
        end

        def service_with_urls(gem_names, &block)
          urls = get_repository_urls(gem_names, &block)
          urls.each_with_object({}) do |url, hash|
            service_name = url.service_name
            hash[service_name] = Array(hash[service_name]) << url
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

          raise NotFound, "Gem: #{gem_name} is not found in RubyGems.org." unless response.success?

          body = JSON.parse(response.body)
          raw_url = body["source_code_uri"] || body["homepage_uri"]
          SourceCodeRepositoryUrl.new(raw_url, gem_name)
        end

        def get_repository_urls(gem_names)
          result = gem_names.map do |gem_name|
            yield if block_given?
            get_repository_url(gem_name)
          rescue StandardError => e
            $stdout.write "W"
            error_messages << e.message
          end

          result.find_all { |obj| obj.instance_of?(Alive::SourceCodeRepositoryUrl) }
        end
      end
    end
  end
end
