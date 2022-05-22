# frozen_string_literal: true

require "gitlab"
require "json"

module Bundler
  module Alive
    module Client
      #
      # API Client for GitLab API
      #
      # @see https://docs.gitlab.com/ee/api/projects.html#get-single-project
      #
      module GitlabApi
        # Environment variable name of GitLab Access Token
        ACCESS_TOKEN_ENV_NAME = "BUNDLER_ALIVE_GITLAB_TOKEN"

        # Endpoint of GitLab API
        ENDPOINT = "https://gitlab.com/api/v4"

        def self.extended(base)
          base.instance_eval do
            @rate_limit_exceeded = false
            @retries_on_too_many_requests = 0
          end
        end

        #
        # Creates a GitLab client
        #
        # @return [Octokit::Client]
        #
        def create_client
          Gitlab.client(
            endpoint: ENDPOINT,
            private_token: ENV.fetch(ACCESS_TOKEN_ENV_NAME, nil)
          )
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
          name_with_archived = get_name_with_statuses(urls)
          urls.each do |url|
            gem_name = url.gem_name
            alive = name_with_archived.key?(gem_name) && !name_with_archived[gem_name]
            status = Status.new(name: gem_name, repository_url: url, alive: alive, checked_at: Time.now)
            collection = collection.add(gem_name, status)
          end

          StatusResult.new(collection: collection, error_messages: @error_messages,
                           rate_limit_exceeded: @rate_limit_exceeded)
        end

        private

        #
        # Search status of repositories
        #
        # @param [Array<RepositoryUrl>] urls
        #
        # @return [Hash<String, Boolean>]
        #   gem name with archived or not
        #
        def get_name_with_statuses(urls)
          name_with_status = {}
          urls.each do |url|
            $stdout.write "."
            project = search_repositories_with_retry(url)
            next if project.nil? || project.empty?

            name = url.gem_name
            name_with_status[name] = project["archived"]
          end
          name_with_status
        end

        def project_path_from_url(url)
          uri = URI.parse(url.url)
          uri.path.split("/")[1..].join("/")
        end

        def search_repositories_with_retry(url)
          project_path = project_path_from_url(url)

          # Must be converted to hash due to warnings
          @client.project(project_path).to_h
        rescue StandardError => e
          @error_messages << e.message
          []
        end
      end
    end
  end
end
