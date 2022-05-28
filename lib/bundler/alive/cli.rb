# frozen_string_literal: true

require "bundler/alive"
require "bundler/alive/doctor"
require "bundler/alive/reportable"

require "thor"

module Bundler
  module Alive
    #
    # The `bundler-alive` command.
    #
    class CLI < ::Thor
      default_task :check
      map "--version" => :version

      desc "check [DIR]", "Checks the Gemfile.lock"
      method_option :ignore, type: :array, aliases: "-i", default: []
      method_option :follow_redirect, type: :boolean, aliases: "-r"
      method_option :gemfile_lock, type: :string, aliases: "-G",
                                   default: "Gemfile.lock"
      method_option :config, type: :string, aliases: "-c", default: ".bundler-alive.yml"

      def check(_dir = Dir.pwd)
        extend Reportable
        report = check_by_doctor
        print_report(report)

        exit_status = report.result.all_alive? ? 0 : 1
        exit exit_status
      end

      desc "version", "Prints the bundler-alive version"
      def version
        puts "bundler-alive #{VERSION}"
      end

      private

      def check_by_doctor
        doctor = initialize_doctor

        begin
          doctor.diagnose
        rescue Bundler::Alive::Client::GitlabApi::AccessTokenNotFoundError => e
          say "\n#{e.message}", :yellow
          exit 1
        end
      end

      def initialize_doctor
        Doctor.new(options[:gemfile_lock], options[:config], options[:ignore],
                   follow_redirect: options[:follow_redirect])
      rescue Bundler::GemfileLockNotFound
        exit 1
      end
    end
  end
end
