# frozen_string_literal: true

module JH
  module Admin
    module UsersController
      extend ::Gitlab::Utils::Override

      override :index

      def index
        super
        return unless ::Gitlab.jh? && ::Gitlab.com?

        return unless params[:search_query].present?

        @users = User.search_by_phone(@users, params[:search_query]) if params[:search_query]&.match?(/\A\+\d+\z/)

        return unless params[:search_query]&.match?(/\A\d{11}\z/)

        @users = User.search_by_phone(@users,
          "#{JH::Sms::AreaCode::MAINLAND}#{params[:search_query]}")
      end
    end
  end
end
