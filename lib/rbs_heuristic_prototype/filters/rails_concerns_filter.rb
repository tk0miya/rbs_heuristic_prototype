# frozen_string_literal: true

require_relative "base"
require "active_support/concern"

module RbsHeuristicPrototype
  module Filters
    class RailsConcernsFilter < Base
      attr_reader :stack

      def initialize(env)
        super
        @stack = [::Kernel]
      end

      def process_module(decl)
        mod = stack.last&.const_get(decl.name.to_s)
        stack << mod
        if mod && concern?(mod) && decl.self_types.empty?
          RBS::AST::Declarations::Module.new(
            name: decl.name,
            type_params: decl.type_params,
            members: decl.members,
            self_types: self_types_for(mod),
            annotations: decl.annotations,
            location: decl.location,
            comment: decl.comment
          )
        else
          super
        end
      ensure
        stack.pop
      end

      def concern?(mod)
        mod.singleton_class.ancestors.include?(ActiveSupport::Concern)
      end

      def self_types_for(mod)
        names = case module_type_for(mod)
                when :controller
                  self_types_for_controller(mod)
                else
                  []
                end

        names.map do |name|
          RBS::AST::Declarations::Module::Self.new(name: name, args: [], location: nil)
        end
      end

      def self_types_for_controller(mod)
        if const_get("ApplicationController") && !(mod > ApplicationController)
          [TypeName("::ApplicationController")]
        else
          [TypeName("::ActionController::Base")]
        end
      end

      def module_type_for(mod)
        source_location = Kernel.const_source_location(mod.name.to_s)
        return :unknown unless source_location

        filename, = source_location.first

        case filename
        when %r{app/controllers/concerns}
          :controller
        else
          :unknown
        end
      end
    end
  end
end
