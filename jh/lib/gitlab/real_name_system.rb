# frozen_string_literal: true

module Gitlab
  module RealNameSystem
    def self.enabled?
      ::Gitlab.com? && ::Gitlab.jh? && ::Gitlab::CurrentSettings.phone_verification_code_enabled?
    end
  end
end
