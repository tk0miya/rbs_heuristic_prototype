# frozen_string_literal: true

require "pathname"
require "rake"
require "rake/tasklib"

module RbsHeuristicPrototype
  class RakeTask < Rake::TaskLib
    FILTERS = {
      active_model_validations: "RbsHeuristicPrototype::Filters::ActiveModelValidationsFilter",
      boolean_methods: "RbsHeuristicPrototype::Filters::BooleanMethodsFilter",
      deep_module: "RbsHeuristicPrototype::Filters::DeepModuleFilter",
      symbol_array_constants: "RbsHeuristicPrototype::Filters::SymbolArrayConstantsFilter",
      type_args: "RbsHeuristicPrototype::Filters::TypeArgsFilter"
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
        require "rbs_heuristic_prototype"  # load RbsHeuristicPrototype lazily

        path.find do |entry|
          next unless entry.file?

          env = FILTERS.inject(load_env(entry)) do |result, (_name, filter)|
            filter.constantize.new(result).apply
          end

          write_env(entry, env)
        end
      end
    end

    def load_env(path)
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path: path)
      RBS::Environment.from_loader(loader)
    end

    def write_env(path, env)
      path.open("wt") do |out|
        RBS::Writer.new(out: out).write(env.declarations)
      end
    end
  end
end
