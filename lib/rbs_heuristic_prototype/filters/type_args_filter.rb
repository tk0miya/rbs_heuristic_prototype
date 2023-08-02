# frozen_string_literal: true

require_relative "base"

module RbsHeuristicPrototype
  module Filters
    class TypeArgsFilter < Base
      def process_class(decl)
        decl = super(decl)
        RBS::AST::Declarations::Class.new(
          name: decl.name,
          type_params: decl.type_params,
          super_class: process_super_class(decl.super_class),
          members: decl.members,
          annotations: decl.annotations,
          location: decl.location,
          comment: decl.comment
        )
      end

      def process_super_class(decl)
        return unless decl

        class_decl = external_env.class_decls[decl.name.absolute!]
        if class_decl && decl.args.empty?
          RBS::AST::Declarations::Class::Super.new(
            name: decl.name,
            args: class_decl.type_params.size.times.map { :untyped },
            location: decl.location
          )
        else
          decl
        end
      end

      def process_member(decl)
        case decl
        when RBS::AST::Members::Include
          process_include(decl)
        else
          super
        end
      end

      def process_include(decl)
        class_decl = external_env.class_decls[decl.name.absolute!]
        if class_decl && decl.args.empty?
          RBS::AST::Members::Include.new(
            name: decl.name,
            args: class_decl.type_params.size.times.map { :untyped },
            annotations: decl.annotations,
            location: decl.location,
            comment: decl.comment
          )
        else
          decl
        end
      end

      def external_env
        loader = RBS::EnvironmentLoader.new
        RBS::Environment.from_loader(loader)
      end
    end
  end
end
