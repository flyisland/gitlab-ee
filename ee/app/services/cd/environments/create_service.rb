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
        environment = ::Cd::Environment.new(params.merge(owner_attributes))

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

      # organization_id is the required sharding key; when scoped to a group we
      # also persist the group as the optional owner.
      def owner_attributes
        if parent.is_a?(::Group)
          { group: parent, organization: parent.organization }
        else
          { organization: parent }
        end
      end
    end
  end
end
