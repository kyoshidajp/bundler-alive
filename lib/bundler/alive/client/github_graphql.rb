# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

module Bundler
  module Alive
    module Client
      # GitHub GraphQL Module
      module GithubGraphql
        #
        # Access token isn't set error
        #
        # @see https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
        #
        class AccessTokenNotFoundError < StandardError
          def initialize(_message = nil)
            message = "Environment variable #{ACCESS_TOKEN_ENV_NAME} is not set."\
                      " Need to set GitHub Personal Access Token to be authenticated at GitHub GraphQL API."\
                      " See: https://docs.github.com/en/graphql/guides/forming-calls-with-graphql#the-graphql-endpoint"
            super(message)
          end
        end

        # Environment variable name of GitHub Access Token
        ACCESS_TOKEN_ENV_NAME = "BUNDLER_ALIVE_GITHUB_TOKEN"

        # GraphQL API endpoint
        # @see https://docs.github.com/en/graphql/guides/forming-calls-with-graphql#the-graphql-endpoint
        ENDPOINT = "https://api.github.com/graphql"
        private_constant :ENDPOINT

        QUERY = <<~QUERY
          query($var_query: String!, $var_first: Int!) {
            search(
              query: $var_query
              type: REPOSITORY
              first: $var_first
            ) {
              repositoryCount
              nodes {
                ... on Repository {
                  isArchived
                  nameWithOwner
                  isMirror
                }
              }
            }
          }
        QUERY
        private_constant :QUERY

        HTTP = GraphQL::Client::HTTP.new(ENDPOINT) do
          def headers(_context)
            token = ENV.fetch(ACCESS_TOKEN_ENV_NAME, nil)
            raise AccessTokenNotFoundError if token.nil?

            {
              "Authorization" => "Bearer #{token}"
            }
          end
        end
        private_constant :HTTP

        if File.exist?(SCHEMA_PATH)
          SCHEMA = GraphQL::Client.load_schema(SCHEMA_PATH)
        else
          SCHEMA = GraphQL::Client.load_schema(HTTP)
          Dir.mkdir(USER_PATH) unless Dir.exist?(USER_PATH)
          GraphQL::Client.dump_schema(SCHEMA, SCHEMA_PATH)
        end
        private_constant :SCHEMA

        # GraphQL client
        CLIENT = GraphQL::Client.new(schema: SCHEMA, execute: HTTP)

        # query
        Query = CLIENT.parse(QUERY)
      end
    end
  end
end
