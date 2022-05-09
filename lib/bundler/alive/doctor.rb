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
      attr_reader :all_alive, :rate_limit_exceeded

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
        @all_alive = nil
        @rate_limit_exceeded = false
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
        @result = gems.each_with_object(GemCollection.new) do |spec, collection|
          gem_name = spec.name
          gem_status = diagnose_gem(gem_name)

          collection.add(gem_name, gem_status)
        end
        @all_alive = result.all_alive?

        save_as_file
      end

      #
      # Reports the result
      #
      def report
        need_to_report_gems = result.need_to_report_gems
        need_to_report_gems.each do |_name, gem_status|
          print gem_status.report
        end
      end

      private

      attr_reader :lock_file, :result_file, :gem_client, :result

      def save_as_file
        body = TomlRB.dump(result.to_h)
        File.write(result_file, body)
      end

      def diagnosed_gem?(gem_status)
        !gem_status.nil? && !gem_status.unknown?
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

          gem_status = Gem.new(name: gem_name,
                               repository_url: SourceCodeRepositoryUrl.new(url),
                               alive: v["alive"],
                               checked_at: v["checked_at"])
          collection.add(gem_name, gem_status)
        end
      end

      def gems
        lock_file_body = File.read(@lock_file)
        lock_file = Bundler::LockfileParser.new(lock_file_body)
        lock_file.specs.each
      end

      def diagnose_gem(gem_name)
        gem_status = collection_from_file.get_unchecked(gem_name)
        return gem_status if diagnosed_gem?(gem_status)

        unless @rate_limit_exceeded
          source_code_url = gem_source_code_url(gem_name)
          is_alive = gem_alive?(source_code_url)
        end

        Gem.new(name: gem_name,
                repository_url: source_code_url,
                alive: is_alive,
                checked_at: Time.now)
      end

      def gem_source_code_url(gem_name)
        gem_client.get_repository_url(gem_name)
      rescue Client::SourceCodeClient::RateLimitExceededError => e
        @rate_limit_exceeded = true
        puts e.message
      rescue StandardError => e
        puts e.message
      end

      def gem_alive?(source_code_url)
        SourceCodeRepository.new(url: source_code_url).alive?
      rescue Client::SourceCodeClient::RateLimitExceededError => e
        @rate_limit_exceeded = true
        puts e.message
      rescue StandardError => e
        puts e.message
      end
    end
  end
end
