# frozen_string_literal: true

require_relative "base"
require "active_support/concern"

module RbsHeuristicPrototype
  module Filters
    class RailsHelpersFilter < Base
      attr_reader :stack

      def initialize(env)
        super
        @stack = [::Kernel]
      end

      def process_module(decl)
        mod = stack.last&.const_get(decl.name.to_s)
        stack << mod
        if mod && helper?(mod) && decl.self_types.empty?
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

      def process_class(decl)
        mod = stack.last&.const_get(decl.name.to_s)
        stack << mod
        super
      ensure
        stack.pop
      end

      def helper?(mod)
        return false unless mod.name.to_s.end_with?("Helper")

        source_location = Kernel.const_source_location(mod.name.to_s)
        return false unless source_location

        filename, = source_location.first
        return false unless filename

        filename.include?("app/helpers")
      end

      def self_types_for(mod)
        names = []
        names << if const_get("ApplicationController")
                   RBS::TypeName.parse("::ApplicationController")
                 else
                   RBS::TypeName.parse("::ActionController::Base")
                 end
        names << if mod.name == "ApplicationHelper"
                   RBS::TypeName.parse("::ActionView::Base")
                 else
                   RBS::TypeName.parse("::ApplicationHelper")
                 end

        names.map do |name|
          RBS::AST::Declarations::Module::Self.new(name: name, args: [], location: nil)
        end
      end
    end
  end
end
