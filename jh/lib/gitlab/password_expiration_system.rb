# frozen_string_literal: true

module Gitlab
  module PasswordExpirationSystem
    def self.enabled?
      visible? && ::Gitlab::CurrentSettings.password_expiration_enabled?
    end

    def self.visible?
      ::License.feature_available?(:password_expiration)
    end
  end
end
