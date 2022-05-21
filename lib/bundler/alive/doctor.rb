# frozen_string_literal: true

require "bundler"
require "octokit"

module Bundler
  module Alive
    #
    # Diagnoses a `Gemfile.lock`
    #
    class Doctor
      #
      # A new instance of Doctor
      #
      # @param [String] lock_file lock file of gem
      # @param [String] config_file config file
      # @param [Array<String>] ignore_gems ignore gems
      #
      def initialize(lock_file, config_file, ignore_gems)
        @lock_file = lock_file
        @gem_client = Client::GemsApiClient.new(config_file)
        @ignore_gems = ignore_gems
        @result = nil
        @rate_limit_exceeded = false
        @error_messages = []
      end

      #
      # Diagnoses gems in lock file of gem
      #
      # @raise [Client::SourceCodeClient::RateLimitExceededError]
      #   When exceeded access rate limit
      #
      # @raise [StandardError]
      #   When raised unexpected error
      #
      # @return [Report]
      #
      def diagnose
        message = "#{collection_from_gemfile.total_size + ignore_gems.size} gems are in Gemfile.lock"
        message = "#{message} (#{ignore_gems.size} gems are ignored)" if ignore_gems.size.positive?
        $stdout.puts message

        result = _diagnose
        Report.new(result)
      end

      private

      attr_reader :lock_file, :gem_client, :ignore_gems,
                  :result, :error_messages, :rate_limit_exceeded

      def diagnose_by_service(service, urls)
        client = Client::SourceCodeClient.new(service_name: service)
        client.query(urls: urls)
      end

      def result_by_search(collection)
        gems_api_response = gem_client.gems_api_response(collection.names)
        service_with_urls = gems_api_response.service_with_urls
        error_messages.concat(gems_api_response.error_messages)

        result = StatusResult.new
        service_with_urls.each do |service, urls|
          result = result.merge(diagnose_by_service(service, urls))
        end
        result
      end

      def collection_from_gemfile
        gems_from_lockfile.each_with_object(StatusCollection.new) do |gem, collection|
          gem_name = gem.name
          next if ignore_gems.include?(gem_name)

          status = Status.new(name: gem_name,
                              repository_url: nil,
                              alive: nil,
                              checked_at: nil)
          collection.add(gem_name, status)
        end
      end

      def _diagnose
        collection = collection_from_gemfile
        result = result_by_search(collection)
        new_collection = collection_from_gemfile.merge(result.collection)

        messages = error_messages.concat(result.error_messages)
        StatusResult.new(collection: new_collection,
                         error_messages: messages,
                         rate_limit_exceeded: result.rate_limit_exceeded)
      end

      def gems_from_lockfile
        lock_file_body = File.read(@lock_file)
        lock_file = Bundler::LockfileParser.new(lock_file_body)
        lock_file.specs
      end
    end
  end
end
