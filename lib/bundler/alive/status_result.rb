# frozen_string_literal: true

module Bundler
  module Alive
    #
    # Represents Result of Status
    #
    class StatusResult
      attr_reader :collection, :error_messages, :rate_limit_exceeded

      #
      # Creates a new StatusResult instance
      #
      # @param [StatusCollection|nil] :collection
      # @param [Array|nil] :error_messages
      # @param [Boolean|nil] :rate_limit_exceeded
      #
      # @return [StatusResult]
      #
      def initialize(collection: nil, error_messages: nil, rate_limit_exceeded: nil)
        @collection = collection
        @error_messages = error_messages
        @rate_limit_exceeded = rate_limit_exceeded

        freeze
      end

      #
      # Merge `StatusResult`, then returns new one
      #
      # @param [StatusResult] result
      #
      # @return [StatusResult]
      #
      def merge(result)
        self.class.new(collection: result.collection,
                       error_messages: result.error_messages,
                       rate_limit_exceeded: result.rate_limit_exceeded)
      end
    end
  end
end
