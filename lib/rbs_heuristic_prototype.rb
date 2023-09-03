# frozen_string_literal: true

require_relative "rbs_heuristic_prototype/filters/active_model_validations_filter"
require_relative "rbs_heuristic_prototype/filters/boolean_methods_filter"
require_relative "rbs_heuristic_prototype/filters/controller_concerns_filter"
require_relative "rbs_heuristic_prototype/filters/deep_module_filter"
require_relative "rbs_heuristic_prototype/filters/symbol_array_constants_filter"
require_relative "rbs_heuristic_prototype/filters/type_args_filter"
require_relative "rbs_heuristic_prototype/rake_task"
require_relative "rbs_heuristic_prototype/version"

module RbsHeuristicPrototype
  class Error < StandardError; end
  # Your code goes here...
end
