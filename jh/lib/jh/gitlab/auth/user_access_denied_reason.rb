# frozen_string_literal: true

module JH
  module Gitlab
    module Auth
      module UserAccessDeniedReason
        extend ::Gitlab::Utils::Override

        #  rubocop:disable Gitlab/ModuleWithInstanceVariables
        override :rejection_message
        def rejection_message
          case rejection_type
          when :phone_not_verified
            format(s_('JH|You (%{reference}) must verify your phone in order to perform this action, ' \
              'please access JiHu GitLab from a web browser at %{url}.'),
              reference: @user.to_reference, url: ::Gitlab.config.gitlab.url)
          else
            super
          end
        end

        private

        override :rejection_type
        def rejection_type
          if @user.phone_required? && !@user.phone_present?
            :phone_not_verified
          else
            super
          end
        end

        #  rubocop:enable Gitlab/ModuleWithInstanceVariables
      end
    end
  end
end
