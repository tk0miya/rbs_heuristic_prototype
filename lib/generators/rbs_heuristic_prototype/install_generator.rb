# frozen_string_literal: true

require "rails"

module RbsHeuristicPrototype
  class InstallGenerator < Rails::Generators::Base
    def create_raketask
      create_file "lib/tasks/rbs_heuristic_prototype.rake", <<~RUBY
        begin
          require 'rbs_heuristic_prototype'
          RbsHeuristicPrototype::RakeTask.new
        rescue LoadError
          # failed to load rbs_heuristic_prototype. Skip to load rbs_heuristic_prototype tasks.
        end
      RUBY
    end
  end
end
