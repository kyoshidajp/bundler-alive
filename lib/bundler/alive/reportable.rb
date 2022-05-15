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

          output = $stdout
          output.puts

          gems = result.need_to_report_gems
          gems.each do |_name, gem|
            output.puts gem.report
          end

          output.puts summary(result, error_messages)
          message(result, report.rate_limit_exceeded)
        end

        private

        def summary(result, error_messages)
          <<~RESULT
            #{error_messages.join("\n")}

            Total: #{result.total_size} (Dead: #{result.dead_size}, Alive: #{result.alive_size}, Unknown: #{result.unknown_size})
          RESULT
        end

        def message(result, rate_limit_exceeded)
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
