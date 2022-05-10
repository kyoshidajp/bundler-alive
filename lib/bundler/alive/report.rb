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
      # @param [GemCollection] :result
      # @param [Array] :error_messages
      # @param [Boolean] :rate_limit_exceeded
      #
      def initialize(result:, error_messages:, rate_limit_exceeded:)
        @result = result
        @error_messages = error_messages
        @rate_limit_exceeded = rate_limit_exceeded

        freeze
      end

      #
      # Save result to file
      #
      # @param [String] file_path
      #
      def save_as_file(file_path)
        body = TomlRB.dump(result.to_h)
        File.write(file_path, body)
      end
    end
  end
end
