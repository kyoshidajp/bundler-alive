# frozen_string_literal: true

module Bundler
  module Alive
    # Represents a source code repository
    class SourceCodeRepository
      def initialize(url:, client:)
        raise ArgumentError, "Unknown url: #{url}" unless url.instance_of?(SourceCodeRepositoryUrl)
        raise ArgumentError, "Unknown client: #{client}" unless client.instance_of?(Client::SourceCodeClient)

        @url = url
        @client = client
      end

      def alive?
        !client.archived?(url)
      end

      private

      attr_reader :url, :client
    end
  end
end
