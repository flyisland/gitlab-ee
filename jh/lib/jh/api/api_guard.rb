# frozen_string_literal: true

module JH
  module API
    module APIGuard
      module HelperMethods
        extend ActiveSupport::Concern
        include GrapePathHelpers::NamedRouteMatcher

        prepended do
          extend ::Gitlab::Utils::Override

          # The only difference from the Upstream code is the addition of this line:
          #   "return user if request&.path == api_v4_user_path && request.get? && user.state == 'blocked'"
          # JiHu allows blocked users to query their own personal information
          override :find_current_user!
          def find_current_user!
            user = find_user_from_sources
            return unless user

            ::Gitlab::Auth::CurrentUserMode.bypass_session!(user.id) if bypass_session_for_admin_mode?(user)

            allowed_paths_for_blocked_user = [api_v4_user_path, api_v4_namespaces_path]

            if request&.get? && allowed_paths_for_blocked_user.include?(request.path) && \
                user.respond_to?(:state) && user.state == 'blocked'
              return user
            end

            forbidden!(api_access_denied_message(user)) unless api_access_allowed?(user)

            check_language_server_client!(user)
            check_dpop!(user)

            user
          end
        end
      end
    end
  end
end
