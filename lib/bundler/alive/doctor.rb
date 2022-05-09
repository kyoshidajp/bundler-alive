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
      def initialize(lock_file, result_file = "result.toml")
        @lock_file = lock_file
        @result_file = result_file
        @gem_client = Client::GemsApi.new
        @result = nil
        @rate_limit_exceeded = false
        @announcer = Announcer.new
        @error_messages = []

        @output = $stdout
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
      def diagnose
        announcer.announce(gems.size) do
          collection = GemCollection.new
          gems.each do |spec|
            name = spec.name
            gem = diagnose_gem_with_announce(name)
            collection = collection.add(name, gem)
          end
          @result = collection
        end

        save_as_file
      end

      #
      # Reports the result
      #
      def report
        reporter = Reporter.new(result: result,
                                error_messages: error_messages,
                                rate_limit_exceeded: rate_limit_exceeded)
        reporter.report
      end

      def all_alive?
        result.all_alive?
      end

      private

      attr_reader :lock_file, :result_file, :gem_client, :result,
                  :rate_limit_exceeded, :output, :announcer,
                  :error_messages

      def save_as_file
        body = TomlRB.dump(result.to_h)
        File.write(result_file, body)
      end

      def collection_from_file
        return @collection_from_file if instance_variable_defined?(:@collection_from_file)

        return GemCollection.new unless File.exist?(result_file)

        toml_hash = TomlRB.load_file(result_file)
        @collection_from_file = collection_from_hash(toml_hash)
      end

      def collection_from_hash(hash)
        hash.each_with_object(GemCollection.new) do |(gem_name, v), collection|
          url = v["repository_url"]
          next if url == Gem::REPOSITORY_URL_UNKNOWN

          gem = Gem.new(name: gem_name,
                        repository_url: SourceCodeRepositoryUrl.new(url),
                        alive: v["alive"],
                        checked_at: v["checked_at"])
          collection.add(gem_name, gem)
        end
      end

      def gems
        lock_file_body = File.read(@lock_file)
        lock_file = Bundler::LockfileParser.new(lock_file_body)
        lock_file.specs.each
      end

      def diagnose_gem_with_announce(name)
        announcer.announce_each do
          diagnose_gem(name)
        end
      end

      def diagnose_gem(name)
        gem = collection_from_file.get_unchecked(name)
        return gem if gem&.diagnosed?

        unless @rate_limit_exceeded
          source_code_url = gem_source_code_url(name)
          is_alive = gem_alive?(source_code_url)
        end

        Gem.new(name: name,
                repository_url: source_code_url,
                alive: is_alive,
                checked_at: Time.now)
      end

      def gem_source_code_url(gem_name)
        gem_client.get_repository_url(gem_name)
      rescue Client::SourceCodeClient::RateLimitExceededError => e
        @rate_limit_exceeded = true
        error_messages << e.message
        nil
      rescue StandardError => e
        error_messages << e.message
        nil
      end

      def gem_alive?(source_code_url)
        SourceCodeRepository.new(url: source_code_url).alive?
      rescue Client::SourceCodeClient::RateLimitExceededError => e
        @rate_limit_exceeded = true
        error_messages << e.message
        nil
      rescue StandardError => e
        error_messages << e.message
        nil
      end
    end
  end
end
