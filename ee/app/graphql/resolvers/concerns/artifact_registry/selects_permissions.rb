# frozen_string_literal: true

module ArtifactRegistry
  module SelectsPermissions
    extend ActiveSupport::Concern

    included do
      extras [:lookahead]
    end

    private

    def permissions_selected?(lookahead)
      lookahead.selects?(:user_permissions)
    end
  end
end
