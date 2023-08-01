# frozen_string_literal: true

require_relative "base"

module RbsHeuristicPrototype
  module Filters
    class DeepModuleFilter < Base
      attr_reader :stack

      def initialize(env)
        super
        @stack = [::Kernel]
      end

      def process_module(decl) # rubocop:disable Metrics/AbcSize
        if decl.name.namespace.empty?
          namespaces = []
          stack << const_get(decl)
          super
        else
          namespaces = namespace_to_decl!(decl.name.namespace)
          decl = decl.dup
          decl.instance_eval { @name = RBS::TypeName.new(name: name.name, namespace: RBS::Namespace.empty) }
          (_ = namespaces.last).members << super
          namespaces.first or raise
        end
      ensure
        namespaces.size.succ.times { stack.pop }
      end

      def process_class(decl) # rubocop:disable Metrics/AbcSize
        if decl.name.namespace.empty?
          namespaces = []
          stack << const_get(decl)
          super
        else
          namespaces = namespace_to_decl!(decl.name.namespace)
          decl = decl.dup
          decl.instance_eval { @name = RBS::TypeName.new(name: name.name, namespace: RBS::Namespace.empty) }
          stack << stack.last&.const_get(decl.name.name)
          (_ = namespaces.last).members << super
          namespaces.first or raise
        end
      ensure
        namespaces.size.succ.times { stack.pop }
      end

      def namespace_to_decl!(namespace)
        namespaces = []
        namespace.path.each do |path|
          obj = stack.last&.const_get(path)
          stack << obj
          decl = obj_to_decl(obj)
          namespaces.last.members << decl unless namespaces.empty?
          namespaces << decl
        end
        namespaces
      end

      def obj_to_decl(obj) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        if obj.is_a?(Class)
          if (superclass = obj.superclass)
            super_class = RBS::AST::Declarations::Class::Super.new(name: TypeName(superclass.name.to_s),
                                                                   args: [],
                                                                   location: nil)
          end
          RBS::AST::Declarations::Class.new(
            name: TypeName(obj.name.to_s.split("::").last.to_s),
            type_params: [],
            super_class: super_class,
            members: [],
            annotations: [],
            location: nil,
            comment: nil
          )
        else
          RBS::AST::Declarations::Module.new(
            name: TypeName(obj.name.to_s.split("::").last.to_s),
            type_params: [],
            members: [],
            self_types: [],
            annotations: [],
            location: nil,
            comment: nil
          )
        end
      end
    end
  end
end
