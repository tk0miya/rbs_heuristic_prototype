# frozen_string_literal: true

require_relative "base"
require "active_support/concern"

module RbsHeuristicPrototype
  module Filters
    class ControllerConcernsFilter < Base
      def process_module(decl)
        mod = const_get(decl)
        if mod && controller_concern?(mod) && decl.self_types.empty?
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
          decl
        end
      end

      def controller_concern?(mod)
        return false unless mod.singleton_class.ancestors.include?(ActiveSupport::Concern)

        source_location = Kernel.const_source_location(mod.name.to_s)
        return false unless source_location

        filename, = source_location.first
        return false unless filename

        filename.include?("app/controllers/concerns")
      end

      def self_types_for(mod)
        name = if Kernel.const_get("ApplicationController") && !(mod > ApplicationController)
                 TypeName("::ApplicationController")
               else
                 TypeName("::ActionController::Base")
               end

        [RBS::AST::Declarations::Module::Self.new(name: name, args: [], location: nil)]
      end
    end
  end
end
