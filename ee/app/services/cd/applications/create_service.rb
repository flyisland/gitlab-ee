# frozen_string_literal: true

module Cd
  module Applications
    class CreateService
      def initialize(parent:, current_user: nil, params: {})
        @parent = parent
        @current_user = current_user
        @params = params.dup
        @services = Array(@params.delete(:services))
      end

      def execute
        application = ::Cd::Application.new(params.merge(organization: parent))

        ::Cd::Application.transaction do
          application.save!

          services.each do |service_params|
            application.services.create!(service_params.merge(organization: parent))
          end
        end

        ServiceResponse.success(payload: { application: application })
      rescue ActiveRecord::RecordInvalid => e
        ServiceResponse.error(
          message: e.record.errors.full_messages,
          payload: { application: application }
        )
      end

      private

      attr_reader :parent, :current_user, :params, :services
    end
  end
end
