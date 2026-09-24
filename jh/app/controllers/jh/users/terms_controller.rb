# frozen_string_literal: true

module JH
  module Users
    module TermsController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override
      include CheckPhoneAndCode

      prepended do
        skip_before_action :enforce_phone_verification!
      end
    end
  end
end
