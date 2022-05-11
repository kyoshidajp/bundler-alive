# frozen_string_literal: true

module Bundler
  module Alive
    #
    # Represents Result of Status
    #
    class StatusResult
      attr_reader :collection, :error_messages, :rate_limit_exceeded

      def initialize(collection: nil, error_messages: nil, rate_limit_exceeded: nil)
        @collection = collection
        @error_messages = error_messages
        @rate_limit_exceeded = rate_limit_exceeded
      end

      def merge(result)
        self.class.new(collection: result.collection,
                       error_messages: result.error_messages,
                       rate_limit_exceeded: result.rate_limit_exceeded)
      end
    end
  end
end
