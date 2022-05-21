# frozen_string_literal: true

module Bundler
  module Alive
    # Represents a source code repository
    class SourceCodeRepository
      module Service
        GITHUB = :github
      end

      #
      # Creates a `SourceCodeRepository`
      #
      # @param [SourceCodeRepositoryUrl] url
      #
      def initialize(url:)
        raise ArgumentError, "Unknown url: #{url}" unless url.instance_of?(SourceCodeRepositoryUrl)

        @url = url

        freeze
      end

      private

      attr_reader :url
    end
  end
end
