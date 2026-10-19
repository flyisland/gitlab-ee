# frozen_string_literal: true

module JH
  module Users
    module BuildService
      extend ::Gitlab::Utils::Override

      private

      override :signup_params
      def signup_params
        if ::Gitlab::RealNameSystem.enabled?
          super + [:phone, :area_code]
        else
          super
        end
      end

      override :fallback_name
      def fallback_name
        # rubocop:disable Gitlab/ModuleWithInstanceVariables
        if @user_params[:preferred_language].in?(zh_locales)
          "#{user_params[:last_name]} #{user_params[:first_name]}"
        else
          "#{user_params[:first_name]} #{user_params[:last_name]}"
        end
        # rubocop:enable Gitlab/ModuleWithInstanceVariables
      end

      def zh_locales
        %w[zh_CN zh_HK zh_TW]
      end

      override :admin_create_params
      def admin_create_params
        super + [:preferred_language]
      end
    end
  end
end
