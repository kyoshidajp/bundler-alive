# frozen_string_literal: true

require "bundler"

module Bundler
  module Alive
    #
    # Announces check progress
    #
    class Announcer
      DOT = "."

      private_constant :DOT

      #
      # A new instance of Reporter
      #
      def initialize
        @output = $stdout
      end

      def announce
        output.write DOT
      end

      private

      attr_reader :output
    end
  end
end
