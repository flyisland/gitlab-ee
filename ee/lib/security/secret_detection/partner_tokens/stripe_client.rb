# frozen_string_literal: true

module Security
  module SecretDetection
    module PartnerTokens
      # Verifier for Stripe live secret keys.
      #
      # Approach: call `GET /v1/balance` with the key as HTTP Basic username.
      #   - 200 => active
      #   - 401 => inactive (invalid/revoked/expired key)
      # Stripe uniquely lets us integration-test the happy path too, because it
      # issues real *test-mode* keys (sk_test_...) whose balance endpoint
      # responds 200 without any side effects.
      #
      # Stripe's other credentials (StripeLiveShortSecretKey, rk_live_, pk_live_)
      # are separate detection rules, so under ADR-006 each needs its own
      # verifier class. Tracked in https://gitlab.com/gitlab-org/gitlab/-/work_items/588601.
      #
      # Ref: https://docs.stripe.com/api/balance/balance_retrieve
      class StripeClient < BaseClient
        API_ENDPOINT = 'https://api.stripe.com/v1/balance'

        private

        def verify_partner_token(token_value)
          response = make_stripe_request(token_value)
          analyze_stripe_response(response)
        end

        def make_stripe_request(token_value)
          # Stripe uses HTTP Basic with the secret key as the username and an
          # empty password.
          encoded = Base64.strict_encode64("#{token_value}:")
          headers = {
            'Authorization' => "Basic #{encoded}",
            'Accept' => 'application/json'
          }

          make_request(API_ENDPOINT, method: :get, headers: headers)
        end

        def analyze_stripe_response(response)
          case response.code.to_i
          when 200
            token_response(:active)
          when 401
            token_response(:inactive)
          when 429
            raise RateLimitError, "Stripe API rate limited: #{response.code}"
          when 500, 502, 503, 504
            raise NetworkError, "Stripe service error: #{response.code}"
          else
            token_response(:unknown)
          end
        end
      end
    end
  end
end
