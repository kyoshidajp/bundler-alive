# frozen_string_literal: true

require "forwardable"

module Bundler
  module Alive
    # Collection of `Gem`
    class GemCollection
      extend Forwardable
      delegate each: :gems

      attr_reader :total_size, :alive_size, :dead_size, :unknown_size

      def initialize(gems = {})
        @gems = gems
        @gems_values = gems.values

        @alive_size = _alive_size
        @total_size = _total_size
        @unknown_size = _unknown_size
        @dead_size = _dead_size
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

      #
      # All of gems are alive nor not
      #
      # @return [Boolean]
      #
      def all_alive?
        gems.find { |_name, gem| !!!gem.alive || gem.unknown? }.nil?
      end

      private

      attr_reader :gems, :gems_values

      def _total_size
        gems_values.size
      end

      def _alive_size
        gems_values.count { |gem| !!gem.alive && !gem.unknown? }
      end

      def _dead_size
        gems_values.count { |gem| !gem.alive && !gem.unknown? }
      end

      def _unknown_size
        gems_values.count { |gem| gem.alive == Gem::ALIVE_UNKNOWN }
      end
    end
  end
end
