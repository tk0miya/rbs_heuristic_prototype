# frozen_string_literal: true

require "pathname"
require "rake"
require "rake/tasklib"

module RbsHeuristicPrototype
  class RakeTask < Rake::TaskLib
    FILTERS = {
      boolean_methods: Filters::BooleanMethodsFilter
    }.freeze

    attr_reader :name, :path

    def initialize(name = :"rbs:prototype:heuristic", &block)
      super()

      @name = name
      @path = Pathname(Rails.root / "sig/prototype")

      block&.call(self)

      define_apply_task
      define_setup_task
    end

    def define_setup_task
      desc "Run all tasks of rbs_heuristic_prototype"

      deps = [:"#{name}:apply"]
      task("#{name}:setup": deps)
    end

    def define_apply_task
      desc "Apply heuristic filters to prototype signatures"
      task("#{name}:apply": :environment) do
        path.find do |entry|
          next unless entry.file?

          env = FILTERS.inject(load_env(entry)) do |result, filter|
            filter.new(result).apply
          end

          write_env(entry, env)
        end
      end
    end

    def load_env(path)
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path:)
      RBS::Environment.from_loader(loader)
    end

    def write_env(path, env)
      path.open("wt") do |out|
        RBS::Writer.new(out:).write(env.declarations)
      end
    end
  end
end
