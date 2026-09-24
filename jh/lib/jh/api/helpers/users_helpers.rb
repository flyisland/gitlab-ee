# frozen_string_literal: true

module JH
  module API
    module Helpers
      module UsersHelpers
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        prepended do
          params :optional_params_ee do
            # CommentStart: Same as EE
            optional :shared_runners_minutes_limit, type: Integer, desc: 'Pipeline minutes quota for this user'
            optional :extra_shared_runners_minutes_limit, type: Integer, desc: '(admin-only) Extra pipeline minutes quota for this user' # rubocop:disable Layout/LineLength
            optional :group_id_for_saml, type: Integer, desc: 'ID for group where SAML has been configured'
            optional :auditor, type: Grape::API::Boolean, desc: 'Flag indicating auditor status of the user'
            # CommentEnd: Same as EE
            optional :preferred_language, type: String, desc: 'User preferred language'
          end
        end
      end
    end
  end
end
