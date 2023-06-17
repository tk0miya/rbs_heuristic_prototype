# frozen_string_literal: true

require_relative "base"

module RbsHeuristicPrototype
  module Filters
    class BooleanMethodsFilter < Base
      def process_member(member)
        case member
        when RBS::AST::Members::MethodDefinition
          if member.name.end_with?("?")
            overloads = member.overloads.map do |overload|
              overload.update(method_type: process_method_type(overload.method_type))
            end
            member.update(overloads:)
          else
            member
          end
        else
          super
        end
      end

      def process_method_type(method_type)
        type = process_type(method_type.type)
        method_type.update(type:)
      end

      def process_type(type)
        # @type var location: untyped
        name = RBS::TypeName.new(namespace: RBS::Namespace.empty, name: :boolish)
        location = type.return_type.location
        return_type = RBS::Types::Alias.new(name:, args: [], location:)
        type.update(return_type:)
      end
    end
  end
end
