# frozen_string_literal: true

module Resolvers
  module Cd
    class ApplicationsResolver < BaseResolver
      type ::Types::Cd::ApplicationType.connection_type, null: true

      def resolve
        return unless Feature.enabled?(:ai_native_deploy, current_user)

        ::Cd::Application.for_groups(object.self_and_descendants)
      end
    end
  end
end
