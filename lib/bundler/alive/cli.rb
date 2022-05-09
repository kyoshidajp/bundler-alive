# frozen_string_literal: true

require "bundler/alive"
require "bundler/alive/doctor"

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
      method_option :gemfile_lock, type: :string, aliases: "-G",
                                   default: "Gemfile.lock"

      def check(_dir = Dir.pwd)
        doctor = check_by_doctor
        doctor.report

        exit_status = doctor.all_alive? ? 0 : 1
        exit exit_status
      end

      desc "version", "Prints the bundler-alive version"
      def version
        puts "bundler-alive #{VERSION}"
      end

      private

      def check_by_doctor
        doctor = begin
          Doctor.new(options[:gemfile_lock])
        rescue Bundler::GemfileLockNotFound
          exit 1
        end

        doctor.diagnose
        doctor
      end
    end
  end
end
