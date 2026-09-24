# frozen_string_literal: true

require 'api/validations/validators/phone'

module JH
  module API
    module Users
      extend ActiveSupport::Concern

      prepended do
        helpers do
          def jh_saas_only!
            not_found! unless ::Gitlab.com? && ::Gitlab.jh?
          end
        end

        resource :users do
          before do
            jh_saas_only!
            authenticated_as_admin!
          end

          desc 'Update a user phone. Available only for admins.'
          params do
            requires :user_id, type: Integer, desc: 'The ID of the user'
            requires :phone, type: String, allow_blank: false, phone: true, desc: 'The phone number of the user'
          end

          # rubocop: disable CodeReuse/ActiveRecord
          put ":user_id/phone", feature_category: :user_profile, urgency: :default do
            user = ::User.find_by_id(params.delete(:user_id))
            not_found!('User') unless user

            conflict!('Phone has already been taken') if params[:phone] &&
              ::UserDetail.by_encrypted_phone(params[:phone]).exists?

            user_params = { phone: ::Gitlab::CryptoHelper.aes256_gcm_encrypt(params[:phone]) }

            result = ::Users::UpdateService.new(current_user, user_params.merge(user: user)).execute

            if result[:status] == :success
              present user, with: ::API::Entities::UserPhone
            else
              render_api_error!('400 Bad Request', 400)
            end
          end
          # rubocop: enable CodeReuse/ActiveRecord

          desc "Get the phone of a user. Available only for admins."
          params do
            requires :user_id, type: Integer, desc: 'The ID of the user'
          end
          get ":user_id/phone", feature_category: :user_profile, urgency: :default do
            user = ::User.find_by_id(params.delete(:user_id))
            not_found!('User') unless user

            present user, with: ::API::Entities::UserPhone
          end
        end
      end
    end
  end
end
