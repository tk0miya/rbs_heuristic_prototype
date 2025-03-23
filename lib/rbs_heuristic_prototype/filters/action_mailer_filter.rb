# frozen_string_literal: true

require "action_mailer"
require_relative "base"

module RbsHeuristicPrototype
  module Filters
    class ActionMailerFilter < Base
      def process_class(decl)
        klass = const_get(decl)
        if klass&.ancestors&.include?(::ActionMailer::Base)
          process_mailer_class(decl, klass)
        else
          super
        end
      end

      def process_mailer_class(decl, _klass)
        RBS::AST::Declarations::Class.new(
          name: decl.name,
          type_params: decl.type_params,
          super_class: decl.super_class,
          members: process_mailer_members(decl.members),
          annotations: decl.annotations,
          location: decl.location,
          comment: decl.comment
        )
      end

      def process_mailer_members(members)
        visible = true
        members.map do |member|
          case member
          when RBS::AST::Members::MethodDefinition
            process_mailer_method(member, visible)
          when RBS::AST::Members::Public
            visible = true
            process_member(member)
          when RBS::AST::Members::Private
            visible = false
            process_member(member)
          when RBS::AST::Members::Base
            process_member(member)
          else
            process(member)
          end
        end
      end

      def process_mailer_method(member, visible)
        return member if member.visibility == :private || !visible

        RBS::AST::Members::MethodDefinition.new(
          name: member.name,
          kind: :singleton,
          overloads: member.overloads.map { |overload| process_mailer_method_overload(overload) },
          annotations: member.annotations,
          location: member.location,
          comment: member.comment,
          overloading: member.overloading,
          visibility: member.visibility
        )
      end

      def process_mailer_method_overload(overload)
        method_type = process_mailer_method_method_type(overload.method_type)
        overload.update(method_type: method_type)
      end

      def process_mailer_method_method_type(method_type)
        # @type var location: untyped
        name = RBS::TypeName.parse("::ActionMailer::MessageDelivery")
        location = method_type.type.return_type.location
        return_type = RBS::Types::Alias.new(name: name, args: [], location: location)
        method_type.update(type: method_type.type.update(return_type: return_type))
      end
    end
  end
end
