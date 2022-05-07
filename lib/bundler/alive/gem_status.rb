# frozen_string_literal: true

module Bundler
  module Alive
    # Result of gem status
    class GemStatus
      REPOSITORY_URL_UNKNOWN = :unknown
      ALIVE_UNKNOWN = :unknown

      attr_reader :name, :repository_url, :alive, :checked_at

      def initialize(name:, repository_url:, alive:, checked_at:)
        repository_url = REPOSITORY_URL_UNKNOWN if repository_url.nil?
        alive = ALIVE_UNKNOWN if alive.nil?

        @name = name
        @repository_url = repository_url
        @alive = alive
        @checked_at = checked_at

        freeze
      end

      def unknown?
        alive == ALIVE_UNKNOWN
      end

      def to_h
        {
          repository_url: decorated_repository_url,
          alive: decorated_alive,
          checked_at: checked_at
        }
      end

      def report
        <<~REPORT
          Name: #{name}
          URL: #{decorated_repository_url}
          Status: #{decorated_alive}

        REPORT
      end

      private

      def decorated_repository_url
        if repository_url == REPOSITORY_URL_UNKNOWN
          REPOSITORY_URL_UNKNOWN.to_s
        else
          repository_url.url
        end
      end

      def decorated_alive
        if alive == ALIVE_UNKNOWN
          ALIVE_UNKNOWN.to_s
        else
          alive
        end
      end
    end
  end
end
