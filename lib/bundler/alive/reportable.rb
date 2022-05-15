# frozen_string_literal: true

require "bundler"

require "thor"

module Bundler
  module Alive
    class CLI < ::Thor
      #
      # Reports
      #
      module Reportable
        #
        # Reports result
        #
        # @param [Report] report
        #
        def print_report(report)
          result = report.result
          error_messages = report.error_messages
          print_error(error_messages)

          gems = result.need_to_report_gems
          $stdout.puts if gems.size.positive?
          gems.each do |_name, gem|
            $stdout.puts gem.report
          end

          print_summary(result)
          print_message(result, report.rate_limit_exceeded)
        end

        private

        def print_error(error_messages)
          return if error_messages.nil?

          $stdout.puts <<~ERROR

            #{error_messages.join("\n")}
          ERROR
        end

        def print_summary(result)
          $stdout.puts <<~RESULT
            Total: #{result.total_size} (Dead: #{result.dead_size}, Alive: #{result.alive_size}, Unknown: #{result.unknown_size})
          RESULT
        end

        def print_message(result, rate_limit_exceeded)
          if result.all_alive?
            say "All gems are alive!", :green
            return
          end

          say "Too many requested! Retry later.", :yellow if rate_limit_exceeded
          if result.dead_size.positive?
            say "Not alive gems are found!", :red
            return
          end
          say "Unknown gems are found!", :yellow if result.unknown_size.positive?
        end
      end
    end
  end
end
