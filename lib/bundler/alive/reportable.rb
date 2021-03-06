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

          unknown_gems = result.unknown_gems
          print_archived_gems(unknown_gems, header: "Unknown gems:") if unknown_gems.size.positive?

          archived_gems = result.archived_gems
          print_archived_gems(archived_gems, header: "Archived gems:") if archived_gems.size.positive?

          print_summary(result)
          print_message(result, report.rate_limit_exceeded)
        end

        private

        # soo messy
        def print_archived_gems(gems, header:)
          $stdout.puts
          $stdout.puts header
          gems_to_report = gems.map do |_name, gem|
            gem.report.split("\n").each_with_object([]) do |line, gem_str|
              gem_str << "    #{line}"
            end.join("\n")
          end
          $stdout.puts gems_to_report.join("\n\n")
        end

        def print_error(error_messages)
          return if error_messages.empty?

          $stdout.puts <<~ERROR


            Errors:
                #{error_messages.join("\n    ")}
          ERROR
        end

        def print_summary(result)
          $stdout.puts <<~RESULT

            Total: #{result.total_size} (Archived: #{result.archived_size}, Unknown: #{result.unknown_size}, Alive: #{result.alive_size})
          RESULT
        end

        def print_message(result, rate_limit_exceeded)
          if result.all_alive?
            say "All gems are alive!", :green
            return
          end

          say "Too many requested! Retry later.", :yellow if rate_limit_exceeded
          if result.archived_size.positive?
            say "Not alive gems are found!", :red
            return
          end
          say "Unknown gems are found!", :yellow if result.unknown_size.positive?
        end
      end
    end
  end
end
