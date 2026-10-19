# frozen_string_literal: true

module JH
  module Ai
    module DuoWorkflows
      # JH additions to the upstream source_type enum. JH values start at 100
      # so upstream additions never collide with ours. The enum call itself
      # keeps instance_methods/scopes off: redefining upstream's generated
      # methods would raise, so the JH values' own predicates, bangs and scopes
      # are defined directly here.
      module Workflow
        JH_SOURCE_TYPES = { dingtalk: 100, feishu: 101 }.freeze

        def self.prepended(base)
          # Extends whatever upstream defines rather than restating it, so values
          # upstream adds later are kept.
          base.enum :source_type, base.source_types.symbolize_keys.merge(JH_SOURCE_TYPES),
            prefix: :source, instance_methods: false, scopes: false

          JH_SOURCE_TYPES.each_key do |source_type|
            base.scope :"source_#{source_type}", -> { where(source_type: source_type) }
            base.scope :"not_source_#{source_type}", -> { where.not(source_type: source_type) }

            base.define_method(:"source_#{source_type}?") { self.source_type == source_type.to_s }
            base.define_method(:"source_#{source_type}!") { update!(source_type: source_type) }
          end
        end
      end
    end
  end
end
