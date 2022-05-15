# frozen_string_literal: true

module Bundler
  module Alive
    # Represents a source code repository
    class SourceCodeRepositoryUrl
      # service domain with service
      DOMAIN_WITH_SERVICES = {
        "github.com" => SourceCodeRepository::Service::GITHUB,
        "www.github.com" => SourceCodeRepository::Service::GITHUB
      }.freeze

      private_constant :DOMAIN_WITH_SERVICES

      # No supported URL Error
      class UnSupportedUrl < StandardError
        #
        # @param [String] :url
        # @param [String] :name
        #
        # @return [UnSupportedUrl]
        #
        def initialize(url:, name:)
          decorated_url = if url.nil? || url == ""
                            "(blank)"
                          else
                            url
                          end
          message = "[#{name}] is not support URL: #{decorated_url}"
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
        raise UnSupportedUrl.new(url: url, name: name) if url.nil?

        @url = url
        @service_name = service(url: url, name: name)
        @gem_name = name
      end

      private

      def service(url:, name:)
        uri = URI.parse(url)
        host = uri.host

        raise UnSupportedUrl.new(url: url, name: name) unless DOMAIN_WITH_SERVICES.key?(host)

        DOMAIN_WITH_SERVICES[host]
      end
    end
  end
end
