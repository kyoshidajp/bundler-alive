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
        doctor = initialize_doctor
        doctor.diagnose
        doctor.report
        doctor.save_as_file

        exit 0 if doctor.all_alive

        puts "Not alive gems are found!"
        exit 1
      end

      private

      def initialize_doctor
        Doctor.new(options[:gemfile_lock])
      rescue Bundler::GemfileLockNotFound
        exit 1
      end
    end
  end
end
