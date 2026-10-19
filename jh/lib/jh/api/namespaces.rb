# frozen_string_literal: true

module JH
  module API
    module Namespaces
      extend ActiveSupport::Concern

      prepended do
        helpers do
          extend ::Gitlab::Utils::Override

          override :update_namespace
          def update_namespace(namespace)
            result = super
            if result && ::Gitlab.com? && !::Gitlab::Utils.to_boolean(params[:trial]) && params[:trial_ends_on].blank?
              user_ids = if namespace.is_a?(Group)
                           namespace.billed_user_ids[:user_ids]
                         else
                           namespace.owner_id
                         end

              UserCustomAttribute.by_key(::JH::User::FREE_TRIAL_LEFT_DAYS).by_user_id(user_ids).delete_all
            end

            result
          end
        end
      end
    end
  end
end
