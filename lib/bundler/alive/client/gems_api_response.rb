# frozen_string_literal: true

module Bundler
  module Alive
    module Client
      #
      # Represents API Response of RubyGems.org
      #
      class GemsApiResponse
        attr_reader :service_with_urls, :error_messages

        #
        # Creates a new StatusResult instance
        #
        # @param [StatusCollection|nil] :collection
        # @param [Array] :error_messages
        #
        # @return [GemsApiResponse]
        #
        def initialize(service_with_urls:, error_messages:)
          @service_with_urls = service_with_urls
          @error_messages = error_messages

          freeze
        end
      end
    end
  end
end
