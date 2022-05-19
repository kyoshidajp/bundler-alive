# frozen_string_literal: true

module Bundler
  module Alive
    #
    # Represents Report
    #
    class Report
      attr_reader :result, :error_messages, :rate_limit_exceeded

      #
      # A result of report
      #
      # @param [StatusResult] result
      #
      def initialize(result)
        @result = result.collection
        @error_messages = result.error_messages
        @rate_limit_exceeded = result.rate_limit_exceeded

        freeze
      end
    end
  end
end
