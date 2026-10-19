# frozen_string_literal: true

module JH
  module Namespaces
    module Storage
      class RepoLimitMailer < ApplicationMailer
        include ::EmailsHelper
        include ::SafeFormatHelper
        include ::GitlabRoutingHelper

        helper ::EmailsHelper
        helper ::SafeFormatHelper

        layout 'mailer'

        def notify_out_of_storage(project:, recipients:, usage_percentage: nil)
          @usage_percentage = usage_percentage

          compose(project, recipients) do
            safe_format(
              s_('JH|NamespaceStorage|Action required: %{project_name} is read-only'), { project_name: project.name }
            )
          end
        end

        def notify_limit_warning(project:, recipients:, usage_percentage: nil)
          @usage_percentage = usage_percentage

          compose(project, recipients) do
            safe_format(
              s_('JH|NamespaceStorage|Action required: Unusually high storage usage on %{project_name}'),
              { project_name: project.name }
            )
          end
        end

        def notify_group_out_of_storage(namespace:, recipients:, usage_percentage: nil)
          @usage_percentage = usage_percentage

          compose_group(namespace, recipients) do
            safe_format(
              s_('JH|NamespaceStorage|Action required: %{group_name} has used up its purchased storage'),
              { group_name: namespace.name }
            )
          end
        end

        def notify_group_limit_warning(namespace:, recipients:, usage_percentage: nil)
          @usage_percentage = usage_percentage

          compose_group(namespace, recipients) do
            safe_format(
              s_('JH|NamespaceStorage|Action required: Unusually high purchased storage usage for %{group_name}'),
              { group_name: namespace.name }
            )
          end
        end

        private

        def compose(project, recipients)
          @project_name = project.name
          @project_url = project_url(project)

          ::Gitlab::I18n.with_locale(recipient_locale(to: recipients)) do
            mail_with_locale(bcc: recipients, subject: yield)
          end
        end

        def compose_group(namespace, recipients)
          @group_name = namespace.name
          @group_url = usage_quotas_url(namespace, anchor: 'storage-quota-tab')

          ::Gitlab::I18n.with_locale(recipient_locale(to: recipients)) do
            mail_with_locale(bcc: recipients, subject: yield)
          end
        end
      end
    end
  end
end
