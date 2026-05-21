# frozen_string_literal: true

module Security
  module DependencyFirewallPolicies
    class BypassSettings
      include Gitlab::Utils::StrongMemoize

      def initialize(bypass_settings)
        @bypass_settings = bypass_settings || {}
      end

      def access_token_ids
        bypass_settings[:access_tokens]&.pluck(:id) || []
      end
      strong_memoize_attr :access_token_ids

      def user_ids
        bypass_settings[:users]&.pluck(:id) || []
      end
      strong_memoize_attr :user_ids

      def user_bypassed?(user)
        return false unless user

        user_ids.include?(user.id)
      end

      def access_token_bypassed?(user)
        return false unless user
        return false if access_token_ids.empty?

        user.personal_access_tokens
            .active
            .id_in(access_token_ids)
            .exists?
      end

      private

      attr_reader :bypass_settings
    end
  end
end
