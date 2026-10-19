# frozen_string_literal: true

module JH
  module PasswordsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      skip_before_action :require_no_authentication, only: [:new, :edit, :update] if ::Gitlab::RealNameSystem.enabled?
    end
  end
end
