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

        REPOSITORY_SERVICES = {
          github: GitHubApi
        }.freeze

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
          raise ArgumentError, "Unknown service: #{service_name}" unless REPOSITORY_SERVICES.key?(service_name)

          service = REPOSITORY_SERVICES[service_name]
          extend service

          @client = create_client

          super()
        end
      end
    end
  end
end
