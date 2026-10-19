# frozen_string_literal: true

module Integrations
  class Ones < Integration
    include Gitlab::Routing
    include IssueTrackerLimitation

    prop_accessor :url, :api_url, :namespace, :project_key, :user_key, :api_token

    validates :url, public_url: true, presence: true, if: :activated?
    validates :api_url, public_url: true, allow_blank: true
    validates :namespace, presence: true, if: :activated?
    validates :project_key, presence: true, if: :activated?
    validates :user_key, presence: true, if: :activated?
    validates :api_token, presence: true, if: :activated?

    # fill fields
    OnesFields.fields.each do |field_item|
      field_name = field_item.delete(:name)
      field field_name, **field_item
    end

    def self.title
      s_('JH|OnesIntegration|ONES')
    end

    def self.description
      s_("JH|OnesIntegration|Use ONES as this project's issue tracker.")
    end

    def self.help
      help_text = <<~TEXT.strip
        JH|OnesIntegration|\
        Before you enable this integration, you must configure ONES. \
        For more details, read the %{link_start}ONES integration documentation%{link_end}.
      TEXT

      build_help_page_url(
        'user/project/integrations/ones',
        s_(help_text)
      )
    end

    class << self
      def to_param
        'ones'
      end

      def supported_events
        %w[]
      end
    end

    def activated?
      active
    end

    def render?
      valid? && activated?
    end

    def test(*_args)
      ::Gitlab::Ones::Client.new(self).ping
    end

    def issue_tracker_path
      Gitlab::Utils.append_path(url, "/project/#/team/#{namespace}/project/#{project_key}")
    end
  end
end
