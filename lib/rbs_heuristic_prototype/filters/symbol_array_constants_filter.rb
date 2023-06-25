# frozen_string_literal: true

require_relative "base"

module RbsHeuristicPrototype
  module Filters
    class SymbolArrayConstantsFilter < Base
      def process_constant(constant)
        if constant.name.to_s =~ /^[A-Z][A-Z0-9_]*$/ && symbol_array?(constant.type)
          RBS::AST::Declarations::Constant.new(
            name: constant.name,
            type: process_constant_type(constant.type),
            location: constant.location,
            comment: constant.comment
          )
        else
          constant
        end
      end

      def process_constant_type(type)
        # @type var location: untyped
        name = RBS::TypeName.new(namespace: RBS::Namespace.root, name: :Symbol)
        location = type.location
        symbol = RBS::Types::Alias.new(name:, args: [], location:)
        RBS::Types::ClassInstance.new(name: type.name, args: [symbol], location:)
      end

      def symbol_array?(type)
        array?(type) && ((type.args.size == 1 && symbol_union?(type.args.first)) || type.args.all? { |t| symbol?(t) })
      end

      def array?(type)
        type.is_a?(RBS::Types::ClassInstance) && type.name.to_s == "::Array"
      end

      def symbol_union?(type)
        if type.is_a?(RBS::Types::Union) && type.types.all? { |t| symbol?(t) }
          true
        else
          false
        end
      end

      def symbol?(type)
        type.is_a?(RBS::Types::Literal) && type.literal.is_a?(Symbol)
      end
    end
  end
end