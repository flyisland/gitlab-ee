# frozen_string_literal: true

module Integrations
  class Ligaai < Integration
    include Gitlab::Routing
    include IssueTrackerLimitation

    prop_accessor :url, :api_url, :project_key, :user_key, :api_token

    validates :url, public_url: true, presence: true, if: :activated?
    validates :api_url, public_url: true, allow_blank: true
    validates :project_key, presence: true, if: :activated?
    validates :user_key, presence: true, if: :activated?
    validates :api_token, presence: true, if: :activated?

    # fill fields
    LigaaiFields.fields.each do |field_item|
      field_name = field_item.delete(:name)
      field field_name, **field_item
    end

    def self.title
      s_('JH|LigaaiIntegration|LigaAI')
    end

    def self.description
      s_("JH|LigaaiIntegration|Use LigaAI as this project's issue tracker.")
    end

    def self.help
      help_text = <<~TEXT.strip
        JH|LigaaiIntegration|\
        Before you enable this integration, you must configure LigaAI. \
        For more details, read the %{link_start}LigaAI integration documentation%{link_end}.
      TEXT

      build_help_page_url(
        'user/project/integrations/ligaai',
        s_(help_text)
      )
    end

    class << self
      def to_param
        'ligaai'
      end

      def supported_events
        %w[]
      end

      def issues_license_available?(project)
        project&.licensed_feature_available?(:integration_with_ligaai_issues)
      end
    end

    def activated?
      active
    end

    def render?
      return false unless ::Feature.enabled?(:integration_with_ligaai_issues, project)

      valid? && activated?
    end

    def test(*_args)
      ::Gitlab::Ligaai::Client.new(self).ping
    end

    def issue_tracker_path
      url
    end
  end
end
