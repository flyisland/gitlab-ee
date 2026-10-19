# frozen_string_literal: true

module JH
  module GroupsHelper
    extend ::Gitlab::Utils::Override

    override :subgroup_creation_data
    def subgroup_creation_data(group)
      super.merge({
        identity_verification_required: false.to_s,
        identity_verification_path: '#'
      })
    end
  end
end
