# frozen_string_literal: true

module Gitlab
  module SubscriptionPortal
    module Clients
      module Rest
        extend ActiveSupport::Concern

        class_methods do
          SubscriptionPortalRESTException = Class.new(RuntimeError)

          def generate_trial(params)
            return request_disabled_error unless requests_enabled?

            trial_user_params = params[:trial_user] ? params : { trial_user: params }
            http_post("trials", admin_headers, trial_user_params)
          end

          def generate_self_managed_ultimate_trial(params)
            http_post("trials/self_managed/ultimates", json_headers, params)
          end

          def generate_trial_lead(params)
            return request_disabled_error unless requests_enabled?

            trial_user_params = params[:trial_user] ? params : { trial_user: params }
            http_post("leads/gitlab_com/ultimates", admin_headers, trial_user_params)
          end

          def generate_addon_trial(params)
            return request_disabled_error unless requests_enabled?

            trial_user_params = params[:trial_user] ? params : { trial_user: params }
            http_post("trials/create_addon", admin_headers, trial_user_params)
          end

          def generate_lead(params)
            return request_disabled_error unless requests_enabled?

            http_post("leads/gitlab_com/hand_raises", admin_headers, params)
          end

          def generate_iterable(params)
            return request_disabled_error unless requests_enabled?

            http_post("trials/create_iterable", admin_headers, params)
          end

          def opt_in_lead(params)
            http_post("api/marketo_leads/opt_in", admin_headers, params)
          end

          def payment_form_params(payment_type, user_id)
            http_get("payment_forms/#{payment_type}", admin_headers, { user_id: user_id }.compact)
          end

          def validate_payment_method(id, params)
            http_post("api/payment_methods/#{id}/validate", admin_headers, params)
          end

          def create_seat_link(seat_link)
            raise TypeError unless seat_link.is_a?(Gitlab::SeatLinkData)

            http_post("api/v1/seat_links", json_headers, seat_link)
          end

          def namespace_eligible_trials(params)
            return request_disabled_error unless requests_enabled?

            http_get('api/v1/gitlab/namespaces/trials/eligibility', admin_headers, params)
          end

          def namespace_trial_types
            return request_disabled_error unless requests_enabled?

            http_get('api/v1/gitlab/namespaces/trials/trial_types', admin_headers)
          end

          def verify_usage_quota(params)
            headers = if Gitlab.com? # rubocop:disable Gitlab/AvoidGitlabInstanceChecks -- Available on gitlab.com only
                        admin_headers
                      else
                        license_checksum_headers
                      end

            http_head('api/v1/consumers/resolve', headers, params, base_url_to_call: usage_quota_base_url)
          end

          private

          def requests_enabled?
            ::Gitlab::Saas.feature_available?(:cdot_requests)
          end

          def error_message
            _('Our team has been notified. Please try again.')
          end

          def request_disabled_error
            {
              success: false,
              data: { errors: 'Subscription portal requests disabled for non-SaaS.' }
            }.with_indifferent_access
          end

          def track_exception(message)
            Gitlab::ErrorTracking.track_exception(SubscriptionPortalRESTException.new(message))
          end

          def base_url
            ::Gitlab::Routing.url_helpers.subscription_portal_url
          end

          def http_get(path, headers, query = {})
            process_http_call { Gitlab::HTTP.get("#{base_url}/#{path}", query: query, headers: headers) }
          end

          def http_post(path, headers, params = {})
            process_http_call do
              Gitlab::HTTP.post("#{base_url}/#{path}", body: params.to_json, headers: headers)
            end
          end

          def http_head(path, headers, query = {}, base_url_to_call: base_url)
            process_http_call do
              Gitlab::HTTP.head("#{base_url_to_call}/#{path}", query: query, headers: headers)
            end
          end

          def process_http_call
            response = yield
            parse_response(response).tap do |result|
              result[:cache_ttl] = extract_cache_ttl(response)
            end
          rescue *Gitlab::HTTP::HTTP_ERRORS => e
            track_exception(e.message)
            { success: false, data: { errors: error_message } }.with_indifferent_access
          end

          def extract_cache_ttl(response)
            cache_control = response.headers&.[]('cache-control')
            return unless cache_control

            match = cache_control.match(/max-age=(\d+)/)
            match[1].to_i if match
          end

          def usage_quota_base_url
            return base_url unless use_mock_usage_quota_endpoint?

            env_url = ENV['MOCK_CUSTOMER_DOT_PORTAL_SERVER_URL']
            return env_url if env_url.present?

            'http://localhost:4567'
          end

          def use_mock_usage_quota_endpoint?
            Rails.env.development? &&
              Feature.enabled?(:use_mock_dot_api_for_usage_quota, :instance)
          end
        end
      end
    end
  end
end
