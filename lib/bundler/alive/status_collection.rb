# frozen_string_literal: true

require "forwardable"

module Bundler
  module Alive
    # Collection of `Status`
    class StatusCollection
      extend Forwardable
      delegate each: :collection
      delegate values: :collection

      attr_reader :alive_size, :dead_size, :unknown_size

      #
      # Generates instance of `StatusCollection`
      #
      # @param [StatusCollection|nil] collection
      #
      # @return [StatusCollection]
      #
      def initialize(collection = {})
        @collection = collection
        @statuses_values = collection.values || []

        @alive_size = _alive_size
        @unknown_size = _unknown_size
        @dead_size = _dead_size
        freeze
      end

      #
      # Fetch `Status` of `name`
      #
      # @param [String] name
      #
      # @return [Status]
      #
      def [](name)
        collection[name]
      end

      #
      # Names of gems
      #
      # @return [Array<String>]
      #
      def names
        values.map(&:name)
      end

      #
      # Add status
      #
      # @param [String] name
      # @param [Status] status
      #
      # @return [StatusCollection]
      #
      def add(name, status)
        collection[name] = status

        self.class.new(collection)
      end

      #
      # Merge collection
      #
      # @param [StatusCollection] collection
      #
      # @return [StatusCollection]
      #
      def merge(collection)
        return self.class.new(self.collection) if collection.nil?

        collection.each do |k, v|
          self.collection[k] = v
        end

        self.class.new(self.collection)
      end

      def to_h
        collection.transform_values(&:to_h)
      end

      def need_to_report_gems
        collection.find_all { |_name, gem| !!!gem.alive }
      end

      #
      # All of statuses are alive nor not
      #
      # @return [Boolean]
      #
      def all_alive?
        collection.find { |_name, status| !!!status.alive || status.unknown? }.nil?
      end

      #
      # Total size of collection
      #
      # @return [Integer]
      #
      def total_size
        collection.size
      end

      private

      attr_reader :collection, :statuses_values

      def _alive_size
        statuses_values.count { |gem| !!gem.alive && !gem.unknown? }
      end

      def _dead_size
        statuses_values.count { |gem| !gem.alive && !gem.unknown? }
      end

      def _unknown_size
        statuses_values.count { |gem| gem.alive == Status::ALIVE_UNKNOWN }
      end
    end
  end
end
