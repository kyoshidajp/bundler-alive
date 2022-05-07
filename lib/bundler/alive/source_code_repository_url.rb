# frozen_string_literal: true

module Bundler
  module Alive
    # Represents a source code repository
    class SourceCodeRepositoryUrl
      # No supported URL Error
      class UnSupportedUrl < StandardError
        def initialize(url)
          message = "UnSupported URL: #{url}"
          super(message)
        end
      end

      GITHUB_DOMAIN = "github.com"

      attr_reader :url

      def initialize(url)
        raise UnSupportedUrl, url unless github_url?(url)

        @url = url
      end

      private

      def github_url?(url)
        uri = URI.parse(url)
        uri.host == GITHUB_DOMAIN
      end
    end
  end
end
