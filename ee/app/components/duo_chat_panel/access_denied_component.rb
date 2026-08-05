# frozen_string_literal: true

module DuoChatPanel
  class AccessDeniedComponent < ViewComponent::Base
    include DuoChatPanel::DuoChatHelper
    include DuoChatPanel::LegacyCallout

    def initialize(source:, user:)
      @source = source
      @user = user
    end

    private

    attr_reader :source, :user

    def data
      {
        access_denied: true.to_s,
        container_type: source.is_a?(Project) ? 'project' : 'group',
        auto_expand: auto_expanded?(user).to_s
      }.compact
    end
  end
end
