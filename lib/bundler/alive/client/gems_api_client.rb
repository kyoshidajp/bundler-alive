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

        #
        # A new instance of `GemApiClient`
        #
        # @param [String] config_path
        #
        # @return [GemApiClient]
        #
        def initialize(config_path = nil)
          @error_messages = []
          @config_gems = get_config_gems(config_path)

          freeze
        end

        #
        # Gets gems from RubyGems.org
        #
        # @param [Array<String>] gem_names
        #
        # @return [Client::GemsApiResponse]
        #
        def gems_api_response(gem_names)
          urls = service_with_urls(gem_names)
          $stdout.puts <<~MESSAGE

            Get all source code repository URLs of gems are done!
          MESSAGE
          Client::GemsApiResponse.new(
            service_with_urls: urls,
            error_messages: error_messages
          )
        end

        private

        attr_accessor :error_messages, :config_gems

        def api_url(gem_name)
          "https://rubygems.org/api/v1/gems/#{gem_name}.json"
        end

        def connection
          Faraday.new do |connection|
            connection.adapter :net_http
          end
        end

        def get_config_gems(path)
          return {} if path.nil? || !File.exist?(path)

          config = YAML.load_file(path)
          config["gems"]
        end

        def service_with_urls(gem_names)
          urls = get_repository_urls(gem_names)
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
          url_from_config = get_repository_url_from_config(gem_name)
          return url_from_config unless url_from_config.nil?

          url = api_url(gem_name)
          response = connection.get(url)

          raise NotFound, "[#{gem_name}] Not found in RubyGems.org." unless response.success?

          body = JSON.parse(response.body)
          raw_url = source_code_url(body: body, gem_name: gem_name)
          SourceCodeRepositoryUrl.new(raw_url, gem_name)
        end

        def get_repository_url_from_config(gem_name)
          return nil if config_gems.nil?
          return nil unless config_gems.key?(gem_name)

          gem = config_gems[gem_name]
          SourceCodeRepositoryUrl.new(gem["url"], gem_name)
        end

        def source_code_url(body:, gem_name:)
          url = body["source_code_uri"]
          return url if SourceCodeRepositoryUrl.support_url?(url)

          url = body["homepage_uri"]
          return url if SourceCodeRepositoryUrl.support_url?(url)

          message = "[#{gem_name}] Source code repository is not found in RubyGems.org,"\
                    " or not supported. URL: https://rubygems.org/gems/#{gem_name}"
          raise NotFound, message
        end

        def get_repository_urls(gem_names)
          result = gem_names.map do |gem_name|
            $stdout.write "."
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
