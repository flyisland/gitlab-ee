# frozen_string_literal: true

module Integrations
  module OnesFields
    class << self
      def fields
        [
          {
            name: :url,
            title: -> { s_('JH|OnesIntegration|ONES web URL') },
            placeholder: 'https://www.ones.ai',
            help: -> { s_('JH|OnesIntegration|Base URL of the ONES instance.') },
            required: true
          },
          {
            name: :api_url,
            title: -> { s_('JH|OnesIntegration|ONES API URL (optional)') },
            help: -> { s_('JH|OnesIntegration|If different from web URL.') },
            required: false
          },
          {
            name: :namespace,
            title: -> { s_('JH|OnesIntegration|ONES team ID') },
            required: true
          },
          {
            type: :password,
            name: :project_key,
            title: -> { s_('JH|OnesIntegration|ONES project ID') },
            non_empty_password_title: -> { s_('JH|OnesIntegration|ONES project ID') },
            non_empty_password_help: -> { s_('JH|OnesIntegration|ONES project ID.') },
            required: true
          },
          {
            type: :password,
            name: :user_key,
            title: -> { s_('JH|OnesIntegration|ONES user ID') },
            non_empty_password_title: -> { s_('JH|OnesIntegration|ONES user ID') },
            non_empty_password_help: -> { s_('JH|OnesIntegration|ONES user ID.') },
            required: true
          },
          {
            type: :password,
            name: :api_token,
            title: -> { s_('JH|OnesIntegration|ONES API token') },
            non_empty_password_title: -> { s_('JH|OnesIntegration|ONES API token') },
            non_empty_password_help: -> { s_('JH|OnesIntegration|Leave blank to use your current token.') },
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
