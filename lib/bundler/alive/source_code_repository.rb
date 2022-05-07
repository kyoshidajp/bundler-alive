# frozen_string_literal: true

module Bundler
  module Alive
    # Represents a source code repository
    class SourceCodeRepository
      def initialize(uri:, client:)
        raise ArgumentError, "Unknown uri: #{uri}" unless uri.instance_of?(SourceCodeRepositoryUrl)
        raise ArgumentError, "Unknown client: #{client}" unless client.instance_of?(Client::SourceCodeClient)

        @uri = uri
        @client = client
      end

      def alive?
        !client.archived?(uri)
      end

      private

      attr_reader :uri, :client
    end
  end
end
