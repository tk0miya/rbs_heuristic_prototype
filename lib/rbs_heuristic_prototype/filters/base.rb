# frozen_string_literal: true

require "rbs"

module RbsHeuristicPrototype
  module Filters
    class Base
      attr_reader :env

      def initialize(env)
        @env = env
      end

      def apply
        decls = env.declarations.map do |decl|
          process(decl)
        end
        RBS::Environment.new.tap do |env|
          env.add_signature(buffer: RBS::Buffer.new(name: "dummy", content: ""), directives: [], decls:)
        end
      end

      def process(decl)
        case decl
        when RBS::AST::Declarations::Module
          process_module(decl)
        when RBS::AST::Declarations::Class
          process_class(decl)
        when RBS::AST::Declarations::Constant
          process_constant(decl)
        else
          decl
        end
      end

      def process_module(decl)
        members = decl.members.map do |member|
          case member
          when RBS::AST::Members::Base
            process_member(member)
          else
            process(member)
          end
        end

        RBS::AST::Declarations::Module.new(
          name: decl.name,
          type_params: decl.type_params,
          members:,
          self_types: decl.self_types,
          annotations: decl.annotations,
          location: decl.location,
          comment: decl.comment
        )
      end

      def process_class(decl)
        members = decl.members.map do |member|
          case member
          when RBS::AST::Members::Base
            process_member(member)
          else
            process(member)
          end
        end

        RBS::AST::Declarations::Class.new(
          name: decl.name,
          type_params: decl.type_params,
          super_class: decl.super_class,
          members:,
          annotations: decl.annotations,
          location: decl.location,
          comment: decl.comment
        )
      end

      def process_constant(constant)
        constant
      end

      def process_member(member)
        member
      end

      def const_get(decl)
        init = Kernel # : singleton(Class)?
        decl.name.to_namespace.path.inject(init) do |const, mod|
          const&.const_get(mod)
        end
      rescue StandardError
        nil
      end
    end
  end
end
