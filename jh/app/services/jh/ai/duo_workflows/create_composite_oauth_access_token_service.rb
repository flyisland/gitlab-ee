# frozen_string_literal: true

module JH
  module Ai
    module DuoWorkflows
      module CreateCompositeOauthAccessTokenService
        extend ::Gitlab::Utils::Override

        def self.prepended(base)
          base.send(:remove_const, :TOKEN_EXPIRES_IN) # rubocop:disable GitlabSecurity/PublicSend -- constant
          base.const_set(:TOKEN_EXPIRES_IN, 2.hours)
        end
      end
    end
  end
end
