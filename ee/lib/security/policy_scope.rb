# frozen_string_literal: true

module Security
  class PolicyScope
    MATCH_MODE_ALL = 'all'
    MATCH_MODE_ANY = 'any'
    DEFAULT_MATCH_MODE = MATCH_MODE_ALL
    BUSINESS_IMPACT_TEMPLATE_TYPE = 'business_impact'

    def initialize(policy_scope)
      @policy_scope = policy_scope || {}
    end

    def match_mode
      policy_scope[:match_mode] || DEFAULT_MATCH_MODE
    end

    def match_mode_any?
      match_mode == MATCH_MODE_ANY
    end

    def compliance_frameworks
      policy_scope[:compliance_frameworks] || []
    end

    def projects
      policy_scope[:projects] || {}
    end

    def groups
      policy_scope[:groups] || {}
    end

    def business_impact
      policy_scope[:business_impact] || {}
    end

    private

    attr_reader :policy_scope
  end
end
