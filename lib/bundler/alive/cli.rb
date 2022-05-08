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

        if doctor.rate_limit_exceeded_error
          puts "Too many requested! Retry later."
          exit 1
        end

        exit 0 if doctor.all_alive

        puts "Not alive gems are found!"
        exit 1
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
        doctor.report
        doctor.save_as_file
        doctor
      end
    end
  end
end
