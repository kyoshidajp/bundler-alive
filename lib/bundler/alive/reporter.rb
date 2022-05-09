# frozen_string_literal: true

require "bundler"

module Bundler
  module Alive
    #
    # Reports
    #
    class Reporter
      #
      # A new instance of Reporter
      #
      # @param [GemCollection] :result
      # @param [Array] :error_messages
      # @param [Boolean] :rate_limit exceeded
      #
      def initialize(result:, error_messages:, rate_limit_exceeded:)
        @output = $stdout
        @result = result
        @error_messages = error_messages
        @rate_limit_exceeded = rate_limit_exceeded
      end

      #
      # Reports result
      #
      def report
        output.puts

        gems = result.need_to_report_gems
        gems.each do |_name, gem|
          output.puts gem.report
        end

        output.puts summary
      end

      private

      attr_reader :output, :error_messages, :result, :rate_limit_exceeded

      def summary
        <<~RESULT
          #{error_messages.join("\n")}

          Total: #{result.total_size} (Dead: #{result.dead_size}, Alive: #{result.alive_size}, Unknown: #{result.unknown_size})
          #{message}
        RESULT
      end

      def message
        return "Too many requested! Retry later." if rate_limit_exceeded

        return "All gems are alive!" if result.all_alive?

        "Not alive gems are found!"
      end
    end
  end
end
