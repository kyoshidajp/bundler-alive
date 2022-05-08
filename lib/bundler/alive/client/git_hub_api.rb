# frozen_string_literal: true

require "octokit"
require "json"

module Bundler
  module Alive
    module Client
      #
      # API Client for GitHub API
      #
      module GitHubApi
        #
        # Creates a GitHub client
        #
        # @return [Octokit::Client]
        #
        def create_client
          Octokit::Client.new(access_token: ENV.fetch("BUNDLER_ALIVE_GITHUB_TOKEN", nil))
        end

        #
        # Returns repository URL is archived?
        #
        # @param [SourceCodeRepositoryUrl] repository_url
        #
        # @raise [ArgumentError]
        #   when repository_uri is not `SourceCodeRepositoryUrl`
        #
        # @raise [Octokit::TooManyRequests]
        #   when too many requested to GitHub.com
        #
        # @raise [SourceCodeClient::SearchRepositoryError]
        #   when Error without `Octokit::TooManyRequests`
        #
        # @return [Boolean]
        #
        # rubocop:disable Metrics/MethodLength
        def archived?(repository_url)
          unless repository_url.instance_of?(SourceCodeRepositoryUrl)
            raise ArgumentError, "UnSupported url: #{repository_url}"
          end

          query = "repo:#{slug(repository_url.url)}"

          begin
            result = @client.search_repositories(query)
            result[:items][0][:archived]
          rescue Octokit::TooManyRequests => e
            raise SourceCodeClient::RateLimitExceededError, e.message
          rescue StandardError => e
            raise SourceCodeClient::SearchRepositoryError, e.message
          end
        end
        # rubocop:enable Metrics/MethodLength

        #
        # Returns slug of repository URL
        #
        # @param [String] repository_url
        #
        # @return [String]
        #
        def slug(repository_url)
          Octokit::Repository.from_url(repository_url).slug
        end
      end
    end
  end
end
