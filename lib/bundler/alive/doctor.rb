# frozen_string_literal: true

require "bundler"
require "octokit"
require "toml-rb"

module Bundler
  module Alive
    #
    # Diagnoses a `Gemfile.lock` with a TOML file
    #
    class Doctor
      #
      # A new instance of Doctor
      #
      # @param [String] lock_file lock file of gem
      # @param [String] result_file file of result
      #
      def initialize(lock_file, result_file)
        @lock_file = lock_file
        @result_file = result_file
        @gem_client = Client::GemsApi.new
        @result = nil
        @rate_limit_exceeded = false
        @announcer = Announcer.new
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
        $stdout.puts "#{collection_from_gemfile.total_size} gems are in Gemfile.lock"
        result = _diagnose
        Report.new(result)
      end

      private

      attr_reader :lock_file, :result_file, :gem_client, :announcer,
                  :result, :error_messages, :rate_limit_exceeded

      #
      # @return [Array<String>]
      #
      def no_need_to_get_gems
        return [] unless File.exist?(result_file)

        toml_hash = TomlRB.load_file(result_file)
        toml_hash.each_with_object([]) do |(gem_name, v), array|
          alive = v["alive"]
          array << gem_name unless alive
        end
      end

      def diagnose_by_service(service, urls)
        client = Client::SourceCodeClient.new(service_name: service)
        client.query(urls: urls) do
          announcer.announce
        end
      end

      def result_by_search(collection)
        service_with_urls = gem_client.service_with_urls(collection.names) do
          announcer.announce
        end
        result = StatusResult.new
        service_with_urls.each do |service, urls|
          result = result.merge(diagnose_by_service(service, urls))
        end
        result
      end

      def fetch_target_collection(base_collection, gem_names)
        collection = StatusCollection.new
        base_collection.each do |name, status|
          next if gem_names.include?(name)

          collection = collection.add(name, status)
        end
        collection
      end

      def collection_from_gemfile
        gems_from_lockfile.each_with_object(StatusCollection.new) do |gem, collection|
          gem_name = gem.name
          status = Status.new(name: gem_name,
                              repository_url: nil,
                              alive: nil,
                              checked_at: nil)
          collection.add(gem_name, status)
        end
      end

      def _diagnose
        collection = fetch_target_collection(collection_from_gemfile, no_need_to_get_gems)
        result = result_by_search(collection)
        collection_from_toml_file = StatusCollection.new_from_toml_file(result_file)
        new_collection = collection_from_gemfile.merge(collection_from_toml_file)
                                                .merge(result.collection)
        StatusResult.new(collection: new_collection,
                         error_messages: result.error_messages,
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
