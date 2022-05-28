# frozen_string_literal: true

require "json"

module Bundler
  module Alive
    module Client
      #
      # API Client for GitHub GraphQL API
      #
      # @see https://docs.github.com/en/graphql
      #
      module GithubApi
        # Environment variable name of GitHub Access Token
        ACCESS_TOKEN_ENV_NAME = "BUNDLER_ALIVE_GITHUB_TOKEN"

        # Separator of query condition
        QUERY_CONDITION_SEPARATOR = " "
        private_constant :QUERY_CONDITION_SEPARATOR

        # Max number of conditional operator at once
        QUERY_MAX_OPERATORS_AT_ONCE = 50
        private_constant :QUERY_MAX_OPERATORS_AT_ONCE

        def self.extended(base)
          base.instance_eval do
            @rate_limit_exceeded = false
            @retries_on_too_many_requests = 0
            @name_with_archived = {}
          end
        end

        #
        # Creates a GraphQL client
        #
        # @return [GraphQL::Client]
        #
        def create_client
          require_relative "github_graphql"
          extend GithubGraphql

          GithubGraphql::CLIENT
        end

        #
        # Query repository statuses
        #
        # @param [Array<RepositoryUrl>] :urls
        #
        # @return [StatusResult]
        #
        def query(urls:)
          collection = StatusCollection.new
          @name_with_archived = get_name_with_statuses(urls)
          urls.each do |url|
            gem_name = url.gem_name
            alive = alive?(gem_name)
            status = Status.new(name: gem_name, repository_url: url, alive: alive, checked_at: Time.now)
            collection = collection.add(gem_name, status)
          end

          StatusResult.new(collection: collection, error_messages: @error_messages,
                           rate_limit_exceeded: @rate_limit_exceeded)
        end

        private

        def alive?(gem_name)
          return false unless @name_with_archived.key?(gem_name)

          value = @name_with_archived[gem_name]
          value == Status::ALIVE_UNKNOWN ? Status::ALIVE_UNKNOWN : !value
        end

        #
        # Search status of repositories
        #
        # @param [Array<RepositoryUrl>] urls
        #
        # @return [Hash<String, Boolean>]
        #   gem name with archived or not
        #
        # rubocop:disable Metrics/MethodLength
        def get_name_with_statuses(urls)
          name_with_status = {}
          urls.each_slice(QUERY_MAX_OPERATORS_AT_ONCE) do |sliced_urls|
            $stdout.print "." * sliced_urls.size

            q = search_query(sliced_urls)
            repositories = search_repositories_with_retry(q)
            next if repositories.nil?

            sliced_urls.each do |url|
              repository = find_repository_from_repositories(url: url,
                                                             repositories: repositories)
              alive_status = if repository.nil?
                               Status::ALIVE_UNKNOWN
                             else
                               repository["isArchived"]
                             end
              name_with_status[url.gem_name] = alive_status
            end
          end
          name_with_status
        end
        # rubocop:enable Metrics/MethodLength

        # @param [SourceCodeRepositoryUrl] :url
        # @param [Array<Sawyer::Resource>] :repositories
        #
        # @return [Sawyer::Resource|nil]
        def find_repository_from_repositories(url:, repositories:)
          repositories.find do |repository|
            # e.g.) tod's URL is https://github.com/JackC/tod
            # but, the `nameWithOwner` is `jacks/tod`
            slug(url.url).downcase == repository["nameWithOwner"].downcase
          end
        end

        #
        # Search query of repositories
        #
        # @param [Array<RepositoryUrl>] urls
        #
        # @return [String]
        #
        def search_query(urls)
          urls.map do |url|
            "repo:#{slug(url.url)}"
          end.join(QUERY_CONDITION_SEPARATOR)
        end

        #
        # Search repositories
        #
        # @param [String] query
        #
        # @return [Array<Sawyer::Resource>|nil]
        #
        def search_repositories(query)
          result = @client.query(GithubGraphql::Query,
                                 variables: { var_query: query, var_first: QUERY_MAX_OPERATORS_AT_ONCE })
          result.data.search.nodes.map(&:to_h)
        rescue StandardError => e
          @error_messages << e.message
          []
        end

        def search_repositories_with_retry(query)
          search_repositories(query)
        end

        #
        # Returns slug of repository URL
        #
        # @param [String] repository_url
        #
        # @return [String]
        #
        def slug(repository_url)
          # from https://github.com/octokit/octokit.rb/blob/v4.22.0/lib/octokit/repository.rb#L12-L17
          github_slug = URI.parse(repository_url).path[1..]
                           .gsub(%r{^repos/}, "")
                           .split("/", 3)[0..1]
                           .join("/")

          github_slug.gsub(/\.git/, "")
        end
      end
    end
  end
end
