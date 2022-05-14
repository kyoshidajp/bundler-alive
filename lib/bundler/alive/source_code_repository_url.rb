# frozen_string_literal: true

module Bundler
  module Alive
    # Represents a source code repository
    class SourceCodeRepositoryUrl
      # service domain with service
      DOMAIN_WITH_SERVICES = {
        "github.com" => SourceCodeRepository::Service::GITHUB
      }.freeze

      private_constant :DOMAIN_WITH_SERVICES

      # No supported URL Error
      class UnSupportedUrl < StandardError
        def initialize(url)
          message = "UnSupported URL: #{url}"
          super(message)
        end
      end

      attr_reader :url, :service_name, :gem_name

      #
      # Creates a `SourceCodeRepositoryUrl`
      #
      # @param [String] url
      # @param [String] name
      #
      # @raise [UnSupportedUrl]
      #
      def initialize(url, name)
        @url = url
        @service_name = service(url)
        @gem_name = name
      end

      private

      def service(url)
        uri = URI.parse(url)
        host = uri.host

        raise UnSupportedUrl, url unless DOMAIN_WITH_SERVICES.key?(host)

        DOMAIN_WITH_SERVICES[host]
      end
    end
  end
end
