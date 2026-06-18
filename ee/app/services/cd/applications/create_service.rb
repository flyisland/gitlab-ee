# frozen_string_literal: true

module Cd
  module Applications
    class CreateService
      def initialize(parent:, current_user: nil, params: {})
        @parent = parent
        @current_user = current_user
        @params = params.dup
      end

      def execute
        application = ::Cd::Application.new(params.merge(owner_attributes))

        if application.save
          ServiceResponse.success(payload: { application: application })
        else
          ServiceResponse.error(
            message: application.errors.full_messages,
            payload: { application: application }
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
