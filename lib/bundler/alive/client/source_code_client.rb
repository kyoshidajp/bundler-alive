# frozen_string_literal: true

module Bundler
  module Alive
    module Client
      #
      # Represents a source code client
      #
      class SourceCodeClient
        class SearchRepositoryError < StandardError
        end

        class RateLimitExceededError < StandardError
        end

        SERVICE_WITH_STRATEGIES = {
          SourceCodeRepository::Service::GITHUB => GitHubApi
        }.freeze

        private_constant :SERVICE_WITH_STRATEGIES

        #
        # A new instance of SourceCodeClient
        #
        # @param [Symbol] service_name
        #
        # @raise [ArgumentError]
        #
        # @return [SourceCodeClient]
        #
        def initialize(service_name:)
          raise ArgumentError, "Unknown service: #{service_name}" unless SERVICE_WITH_STRATEGIES.key?(service_name)

          strategy = SERVICE_WITH_STRATEGIES[service_name]
          extend strategy

          @client = create_client
          @error_messages = []

          super()
        end
      end
    end
  end
end
