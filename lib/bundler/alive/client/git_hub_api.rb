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
        # @raise [SourceCodeClient::SearchRepositoryError]
        #
        # @return [Boolean]
        #
        def archived?(repository_url)
          unless repository_url.instance_of?(SourceCodeRepositoryUrl)
            raise NotImplementedError, "UnSupported url: #{repository_url}"
          end

          query = "repo:#{slug(repository_url.url)}"

          begin
            result = @client.search_repositories(query)
            result[:items][0][:archived]
          rescue Octokit::TooManyRequests, Octokit::UnprocessableEntity => e
            raise SourceCodeClient::SearchRepositoryError, e.message
          end
        end

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
