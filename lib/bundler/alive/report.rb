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
