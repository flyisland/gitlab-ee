# frozen_string_literal: true

module Cd
  module Environments
    class CreateService
      def initialize(parent:, current_user: nil, params: {})
        @parent = parent
        @current_user = current_user
        @params = params.dup
      end

      def execute
        environment = ::Cd::Environment.new(params.merge(organization: parent))

        if environment.save
          ServiceResponse.success(payload: { environment: environment })
        else
          ServiceResponse.error(
            message: environment.errors.full_messages,
            payload: { environment: environment }
          )
        end
      end

      private

      attr_reader :parent, :current_user, :params
    end
  end
end
