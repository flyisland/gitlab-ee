# frozen_string_literal: true

module JH
  module IdentityProviderPolicy
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      desc "Provider is SAML, CAS3"
      condition(:protected_provider, scope: :subject, score: 0) { %w[saml cas3].include?(@subject.to_s) }

      rule { anonymous }.prevent_all

      rule { default }.policy do
        enable :unlink
        enable :link
      end

      rule { protected_provider }.prevent(:unlink)
    end
  end
end
