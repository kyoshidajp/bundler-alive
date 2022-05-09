# frozen_string_literal: true

require "bundler"

module Bundler
  module Alive
    #
    # Announces check progress
    #
    class Announcer
      DOT = "."

      #
      # A new instance of Reporter
      #
      def initialize
        @output = $stdout
      end

      def announce(total_gem_size)
        output.puts "#{total_gem_size} gems are in Gemfile.lock"

        yield

        output.puts
      end

      def announce_each
        output.write DOT

        yield
      end

      private

      attr_reader :output
    end
  end
end
