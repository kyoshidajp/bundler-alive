# frozen_string_literal: true

require "bundler"
require "octokit"
require "toml-rb"

module Bundler
  module Alive
    # Diagnoses a `Gemfile.lock` with a TOML file
    class Doctor
      attr_reader :all_alive

      def initialize(lock_file, toml_file = "result.toml")
        @lock_file = lock_file
        @toml_file = toml_file
        @gem_client = Client::GemsApi.new
        @repository_client = Client::SourceCodeClient.new(service_name: :github)
        @result = nil
        @all_alive = nil
      end

      def diagnose
        @result = gems.each_with_object(GemStatusCollection.new) do |spec, collection|
          gem_name = spec.name
          gem_status = collection_from_file.get_unchecked(gem_name)
          gem_status = diagnose_each_gem(gem_name) if should_diagnose_gem?(gem_status)

          collection.add(gem_name, gem_status)
        end
      end

      def report
        need_to_report_gems = result.need_to_report_gems
        @all_alive = need_to_report_gems.size.zero?
        need_to_report_gems.each do |_name, gem_status|
          print gem_status.report
        end
      end

      def save_as_file
        toml = TomlRB.dump(result.to_h)
        File.write(toml_file, toml)
      end

      private

      attr_reader :lock_file, :toml_file, :gem_client, :repository_client, :result

      def should_diagnose_gem?(gem_status)
        gem_status.nil? || gem_status.alive
      end

      def collection_from_file
        return @collection_from_file if instance_variable_defined?(:@collection_from_file)

        return GemStatusCollection.new unless File.exist?(toml_file)

        toml_hash = TomlRB.load_file(toml_file)
        @collection_from_file = collection_from_hash(toml_hash)
      end

      def collection_from_hash(hash)
        hash.each_with_object(GemStatusCollection.new) do |(gem_name, v), collection|
          url = v["repository_url"]
          next if url.to_sym == GemStatus::GITHUB_URL_UNKNOWN

          gem_status = GemStatus.new(name: gem_name,
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

      def diagnose_each_gem(gem_name)
        begin
          source_code_uri = gem_client.get_repository_uri(gem_name)
          is_alive = SourceCodeRepository.new(uri: source_code_uri, client: repository_client).alive?
        rescue Client::GemsApi::NotFound, Client::SourceCodeClient::SearchRepositoryError => e
          puts e.message
        end

        GemStatus.new(name: gem_name,
                      repository_url: source_code_uri,
                      alive: is_alive,
                      checked_at: Time.now)
      end
    end
  end
end
