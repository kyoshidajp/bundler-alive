# frozen_string_literal: true

module Bundler
  module Alive
    USER_PATH = File.expand_path(File.join(Gem.user_home, ".local", "share", "bundler-alive"))
    SCHEMA_PATH = File.join(USER_PATH, "schema.json")
  end
end

require_relative "alive/version"
require_relative "alive/doctor"
require_relative "alive/source_code_repository"
require_relative "alive/source_code_repository_url"
require_relative "alive/status"
require_relative "alive/status_result"
require_relative "alive/status_collection"
require_relative "alive/report"
require_relative "alive/client/gems_api_client"
require_relative "alive/client/gems_api_response"
require_relative "alive/client/github_api"
require_relative "alive/client/gitlab_api"
require_relative "alive/client/source_code_client"
require_relative "alive/reportable"
