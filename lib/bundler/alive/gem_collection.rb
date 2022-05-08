# frozen_string_literal: true

require "forwardable"

module Bundler
  module Alive
    # Collection of `Gem`
    class GemCollection
      extend Forwardable
      delegate each: :gems

      def initialize(gems = {})
        @gems = gems
        freeze
      end

      def add(name, gem_status)
        gems[name] = gem_status

        self.class.new(gems)
      end

      def get_unchecked(name)
        return nil unless gems.key?(name)

        gem_status = gems[name]
        return nil if gem_status.unknown?

        gem_status
      end

      def to_h
        hash = {}
        gems.each do |k, v|
          hash[k] = v.to_h
        end
        hash
      end

      def need_to_report_gems
        gems.find_all { |_name, gem| !!!gem.alive }
      end

      private

      attr_reader :gems
    end
  end
end
