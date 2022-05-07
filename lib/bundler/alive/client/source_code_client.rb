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

          service = SERVICE_WITH_STRATEGIES[service_name]
          extend service

          @client = create_client

          super()
        end
      end
    end
  end
end
