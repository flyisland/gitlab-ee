# frozen_string_literal: true

module Integrations
  module LigaaiFields
    class << self
      def fields
        [
          {
            name: :url,
            title: -> { s_('JH|LigaaiIntegration|LigaAI web URL') },
            placeholder: 'https://ligaai.cn',
            help: -> { s_('JH|LigaaiIntegration|Base URL of the LigaAI instance.') },
            required: true
          },
          {
            name: :api_url,
            title: -> { s_('JH|LigaaiIntegration|LigaAI API URL (optional)') },
            help: -> { s_('JH|LigaaiIntegration|If different from web URL.') },
            required: false
          },
          {
            type: :password,
            name: :project_key,
            title: -> { s_('JH|LigaaiIntegration|LigaAI project ID') },
            non_empty_password_title: -> { s_('JH|LigaaiIntegration|LigaAI project ID') },
            non_empty_password_help: -> { s_('JH|LigaaiIntegration|LigaAI project ID.') },
            required: true
          },
          {
            type: :password,
            name: :user_key,
            title: -> { s_('JH|LigaaiIntegration|LigaAI client ID') },
            non_empty_password_title: -> { s_('JH|LigaaiIntegration|LigaAI client ID') },
            non_empty_password_help: -> { s_('JH|LigaaiIntegration|LigaAI client ID.') },
            required: true
          },
          {
            type: :password,
            name: :api_token,
            title: -> { s_('JH|LigaaiIntegration|LigaAI Secret Key') },
            non_empty_password_title: -> { s_('JH|LigaaiIntegration|LigaAI Secret Key') },
            non_empty_password_help: -> { s_('JH|LigaaiIntegration|Leave blank to use your current token.') },
            required: true
          }
        ]
      end

      def api_arguments
        fields.map do |field|
          {
            required: field[:required] || false,
            name: field[:name],
            type: String,
            desc: field[:title]
          }
        end
      end
    end
  end
end
