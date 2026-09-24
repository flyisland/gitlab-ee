# frozen_string_literal: true

# Prepended onto ::QA::Runtime::Env
module QA
  module JH
    module Runtime
      module Env
        def skip_update_driver?
          enabled?(ENV['QA_SKIP_UPDATE_DRIVER'], default: false)
        end

        def user_phone
          ENV['QA_USER_PHONE']
        end

        def gitee_password
          ENV['QA_GITEE_PASSWORD']
        end

        def gitee_access_token
          ENV['QA_GITEE_ACCESS_TOKEN'].to_s.strip
        end

        def chrome_default_download_path
          ENV['QA_DEFAULT_CHROME_DOWNLOAD_PATH'] || Dir.tmpdir
        end

        def gitee_api_address
          ENV['QA_GITEE_API_ADDRESS'].to_s.strip
        end

        def fulfillment_payment
          ENV['QA_PAYMENT'] || 'unionpay'
        end

        def payment_user_name
          ENV['QA_PAYMENT_USER_NAME'] || '全渠道'
        end

        def credential_card_num
          ENV['QA_CREDENTIAL_CARD_NUM'] || '341126197709218366'
        end

        def phone_sms_code
          ENV['QA_PHONE_SMS_CODE'] || '123456'
        end

        def bank_account
          ENV['QA_BANK_ACCOUNT'] || '6216261000000000018'
        end

        def default_storage
          ENV['QA_DEFAULT_STORAGE'] || 2
        end

        def default_kubernetes_agent_project_path
          ENV['QA_DEFAULT_KUBERNETES_AGENT_PROJECT_PATH'] || 'jh-sre-demos/kubernetes-agent'
        end

        def kubernetes_agent
          ENV['QA_KUBERNETES_AGENT'] || 'sh-tstg-service-test'
        end

        def kubernetes_job
          ENV['QA_KUBERNETES_JOB'] || 'test-kas'
        end

        def duo_agent_platform_model
          ENV['QA_DUO_AGENT_PLATFORM_MODEL']
        end

        def duo_workflow_use_hardened_image?
          enabled?(ENV['QA_DUO_WORKFLOW_USE_HARDENED_IMAGE'], default: false)
        end

        def duo_workflow_max_duration
          ENV.fetch('QA_DUO_WORKFLOW_MAX_DURATION', 900).to_i
        end

        def customerdot_url
          # We only have 2 customerdot envs, if new envs are added, we just set the env var.
          return ENV['QA_CUSTOMERDOT'] unless ENV['QA_CUSTOMERDOT'].nil?

          case ENV['QA_JH_ENV']
          when 'staging'
            'https://customers-stg.jihulab.com'
          when 'production'
            'https://customers.jihulab.com'
          else
            QA::Runtime::Logger.error('QA_JH_ENV and QA_CUSTOMERDOT are both empty!')
          end
        end

        def customer_portal_url
          return ENV['QA_CUSTOMER_PORTAL_URL'] unless ENV['QA_CUSTOMER_PORTAL_URL'].nil?

          case ENV['QA_JH_ENV']
          when 'staging'
            'https://customer-portal-stg.jihulab.com'
          when 'production'
            'https://customer-portal.jihulab.com'
          else
            QA::Runtime::Logger.error('QA_CUSTOMER_PORTAL_URL is not configured!')
          end
        end

        def customerdot_sync_spend_credits_token
          ENV['QA_CUSTOMERDOT_SYNC_SPEND_CREDITS_TOKEN'].to_s.strip
        end

        # Override running_on_dot_com to be compatible with hk saas
        def running_on_dot_com?
          super || hk_env?
        end

        # Check if running on HK environment (gitlab.hk)
        # HK environment does not support certain features like phone login
        def hk_env?
          URI.parse(QA::Runtime::Scenario.gitlab_address).host.end_with?('.hk')
        end
      end
    end
  end
end
