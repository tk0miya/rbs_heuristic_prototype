# frozen_string_literal: true

require_relative "base"

module RbsHeuristicPrototype
  module Filters
    class ActiveModelValidationsFilter < Base
      attr_reader :klass

      def process_class(decl)
        klass = const_get(decl)

        if klass&.ancestors&.include?(ActiveModel::Validations)
          @klass = klass
          super
        else
          decl
        end
      ensure
        @klass = nil
      end

      def process_member(member)
        callbacks = klass ? klass.__callbacks.fetch(:validate, []).map(&:filter) : []

        case member
        when RBS::AST::Members::MethodDefinition
          if callbacks.include?(member.name)
            overloads = member.overloads.map do |overload|
              overload.update(method_type: process_method_type(overload.method_type))
            end
            member.update(overloads: overloads)
          else
            member
          end
        else
          super
        end
      end

      def process_method_type(method_type)
        type = process_type(method_type.type)
        method_type.update(type: type)
      end

      def process_type(type)
        # @type var location: untyped
        name = RBS::TypeName.new(namespace: RBS::Namespace.empty, name: :void)
        location = type.return_type.location
        return_type = RBS::Types::Alias.new(name: name, args: [], location: location)
        type.update(return_type: return_type)
      end
    end
  end
end
