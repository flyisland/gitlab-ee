# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SubscriptionPortal::Clients::Rest, :without_license, feature_category: :subscription_management do
  let(:client) { Gitlab::SubscriptionPortal::Client }
  let(:message) { nil }
  let(:http_method) { :post }
  let(:response) { nil }
  let(:parsed_response) { nil }
  let(:response_headers) { nil }
  let(:gitlab_http_response) do
    instance_double(
      HTTParty::Response,
      code: response.code,
      response: response,
      body: {},
      parsed_response: parsed_response,
      headers: response_headers
    )
  end

  let(:headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'X-Admin-Email' => 'gl_com_api@gitlab.com',
      'X-Admin-Token' => 'customer_admin_token',
      'User-Agent' => "GitLab/#{Gitlab::VERSION}"
    }
  end

  before do
    stub_env('GITLAB_QA_USER_AGENT', nil)
    # `namespace_trial_types` is stubbed globally and therefore needs to be un-stubbed in here
    allow(Gitlab::SubscriptionPortal::Client).to receive(:namespace_trial_types).and_call_original
  end

  shared_examples 'when response is successful' do
    let(:response) { Net::HTTPSuccess.new(1.0, '201', 'OK') }

    it 'has a successful status' do
      url = "#{::Gitlab::Routing.url_helpers.subscription_portal_url}/#{route_path}"
      allow(Gitlab::HTTP).to receive(http_method)
        .with(url, instance_of(Hash))
        .and_return(gitlab_http_response)

      expect(subject[:success]).to eq(true)
    end

    context 'when response body is not available' do
      let(:parsed_response) { nil }

      it 'has a successful status' do
        allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)

        expect(subject[:success]).to eq(true)
        expect(subject[:data]).to be_nil
      end
    end
  end

  shared_examples 'when http call raises an exception' do
    let(:message) { 'Our team has been notified. Please try again.' }

    it 'overrides the error message' do
      exception = Gitlab::HTTP::HTTP_ERRORS.first.new
      allow(Gitlab::HTTP).to receive(http_method).and_raise(exception)

      expect(subject[:success]).to eq(false)
      expect(subject[:data][:errors]).to eq(message)
    end
  end

  shared_examples 'when response code is 422' do
    let(:response) { Net::HTTPUnprocessableEntity.new(1.0, '422', 'Error') }
    let(:message) { 'Email has already been taken' }
    let(:reason) { 'invalid_email' }
    let(:error_attribute_map) { { "email" => ["taken"] } }
    let(:parsed_response) { { errors: message, error_attribute_map: error_attribute_map }.stringify_keys }

    it 'has a unprocessable entity status' do
      allow(Gitlab::ErrorTracking).to receive(:log_exception)
      allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)

      expect(subject[:success]).to eq(false)

      expect(Gitlab::ErrorTracking).to have_received(:log_exception).with(
        instance_of(::Gitlab::SubscriptionPortal::Client::ResponseError),
        { status: response.code, errors: parsed_response }
      )
    end

    it 'returns the error message along with the error_attribute_map' do
      allow(Gitlab::ErrorTracking).to receive(:log_exception)
      allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)

      expect(subject[:success]).to eq(false)
      expect(subject[:data][:errors]).to eq(message)
      expect(subject[:data][:error_attribute_map]).to eq(error_attribute_map)
    end

    context "when response body is not available" do
      let(:parsed_response) { nil }

      it 'returns the unprocessable entity status' do
        allow(Gitlab::ErrorTracking).to receive(:log_exception)
        allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)

        expect(subject[:success]).to eq(false)
        expect(subject[:data][:errors]).to eq("HTTP status code: 422")

        expect(Gitlab::ErrorTracking).to have_received(:log_exception).with(
          instance_of(::Gitlab::SubscriptionPortal::Client::ResponseError),
          { status: response.code, errors: "HTTP status code: 422" }
        )
      end
    end
  end

  shared_examples 'when response code is 500' do
    let(:response) { Net::HTTPServerError.new(1.0, '500', 'Error') }

    it 'has a server error status' do
      allow(Gitlab::ErrorTracking).to receive(:log_exception)
      allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)

      expect(subject[:success]).to eq(false)

      expect(Gitlab::ErrorTracking).to have_received(:log_exception).with(
        instance_of(::Gitlab::SubscriptionPortal::Client::ResponseError),
        { status: response.code, errors: "HTTP status code: #{response.code}" }
      )
    end
  end

  shared_examples 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header' do
    let(:response) { Net::HTTPSuccess.new(1.0, '201', 'OK') }

    it 'sends the default User-Agent' do
      headers['User-Agent'] = "GitLab/#{Gitlab::VERSION}"

      expect(Gitlab::HTTP).to receive(http_method).with(anything,
        hash_including(headers: headers)).and_return(gitlab_http_response)

      subject
    end

    it 'sends GITLAB_QA_USER_AGENT env variable value in the "User-Agent" header' do
      expected_headers = headers.merge({ 'User-Agent' => 'GitLab/QA' })

      stub_env('GITLAB_QA_USER_AGENT', 'GitLab/QA')

      expect(Gitlab::HTTP).to receive(http_method).with(anything,
        hash_including(headers: expected_headers)).and_return(gitlab_http_response)

      subject
    end
  end

  shared_examples 'when request is disabled' do
    let(:message) { 'Subscription portal requests disabled for non-SaaS.' }

    it 'returns disabled error message' do
      allow(Gitlab::HTTP).to receive(http_method)

      expect(Gitlab::HTTP).not_to receive(http_method)
      expect(subject[:success]).to eq(false)
      expect(subject[:data][:errors]).to eq(message)
    end
  end

  describe 'request methods - non saas environment' do
    let(:headers) do
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'X-License-Token' => License.current.checksum,
        'User-Agent' => "GitLab/#{Gitlab::VERSION}"
      }
    end

    before_all do
      TestLicense.init
    end

    describe '#generate_trial' do
      subject do
        client.generate_trial({})
      end

      let(:route_path) { 'trials' }

      it_behaves_like 'when request is disabled'
    end

    describe '#generate_trial_lead' do
      subject do
        client.generate_trial_lead({})
      end

      let(:route_path) { 'leads/gitlab_com/ultimates' }

      it_behaves_like 'when request is disabled'
    end

    describe '#generate_addon_trial' do
      subject do
        client.generate_addon_trial({})
      end

      let(:route_path) { 'trials/create_addon' }

      it_behaves_like 'when request is disabled'
    end

    describe '#generate_lead' do
      subject do
        client.generate_lead({})
      end

      let(:route_path) { 'leads/gitlab_com/hand_raises' }

      it_behaves_like 'when request is disabled'
    end

    describe '#generate_iterable' do
      subject do
        client.generate_iterable({})
      end

      let(:route_path) { 'trials/create_iterable' }

      it_behaves_like 'when request is disabled'
    end

    describe '#generate_self_managed_ultimate_trial' do
      subject do
        client.generate_self_managed_ultimate_trial(trial_params)
      end

      let(:headers) do
        {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      end

      let(:trial_params) do
        {
          name: 'John Doe',
          company: 'ACME Corp',
          email: 'john@example.com',
          language: 'en'
        }
      end

      let(:route_path) { 'trials/self_managed/ultimates' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'

      it 'passes params directly without nesting' do
        expect(client).to receive(:http_post).with(
          'trials/self_managed/ultimates',
          anything,
          trial_params
        )

        client.generate_self_managed_ultimate_trial(trial_params)
      end
    end

    describe '#namespace_eligible_trials' do
      subject do
        client.namespace_eligible_trials(namespace_ids: ['1'])
      end

      let(:http_method) { :get }
      let(:route_path) { 'api/v1/gitlab/namespaces/trials/eligibility' }

      it_behaves_like 'when request is disabled'
    end

    describe '#namespace_trial_types' do
      subject do
        client.namespace_trial_types
      end

      let(:http_method) { :get }
      let(:route_path) { 'api/v1/gitlab/namespaces/trials/trial_types' }

      it_behaves_like 'when request is disabled'
    end

    describe '#verify_usage_quota' do
      subject(:verify_usage_quota_request) { client.verify_usage_quota(params) }

      let(:params) do
        {
          event_type: 'ai_request',
          feature_qualified_name: 'duo_chat',
          realm: 'self-managed',
          user_id: 1,
          unique_instance_id: "00000000-0000-0000-0000-000000000000"
        }
      end

      let(:http_method) { :head }
      let(:route_path) { 'api/v1/consumers/resolve' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'

      context 'when response code is 402' do
        let(:response) { Net::HTTPPaymentRequired.new(1.0, '402', 'Payment Required') }

        it 'returns the "Payment required" error' do
          allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)

          expect(verify_usage_quota_request[:success]).to eq(false)
          expect(verify_usage_quota_request[:data][:errors]).to eq("HTTP status code: 402")
        end
      end

      describe 'cache_ttl from response headers' do
        let(:response) { Net::HTTPSuccess.new(1.0, '200', 'OK') }

        before do
          allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)
        end

        context 'when Cache-Control header contains max-age' do
          let(:response_headers) { { 'cache-control' => 'max-age=300' } }

          it 'extracts the cache TTL' do
            expect(verify_usage_quota_request[:cache_ttl]).to eq(300)
          end
        end

        context 'when Cache-Control header contains max-age with other directives' do
          let(:response_headers) { { 'cache-control' => 'public, max-age=3600, must-revalidate' } }

          it 'extracts the cache TTL' do
            expect(verify_usage_quota_request[:cache_ttl]).to eq(3600)
          end
        end

        context 'when Cache-Control header is missing' do
          let(:response_headers) { nil }

          it 'returns nil cache_ttl' do
            expect(verify_usage_quota_request[:cache_ttl]).to be_nil
          end
        end

        context 'when Cache-Control header has no max-age' do
          let(:response_headers) { { 'cache-control' => 'no-cache' } }

          it 'returns nil cache_ttl' do
            expect(verify_usage_quota_request[:cache_ttl]).to be_nil
          end
        end
      end

      describe 'url' do
        let(:expected_url) { "#{::Gitlab::Routing.url_helpers.subscription_portal_url}/#{route_path}" }
        let(:response) { Net::HTTPSuccess.new(1.0, '201', 'OK') }

        before do
          allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)
          stub_feature_flags(use_mock_dot_api_for_usage_quota: false)
        end

        it 'uses SUBSCRIPTION_PORTAL_URL' do
          verify_usage_quota_request
          expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
        end

        context 'when in development mode' do
          before do
            stub_rails_env('development')
          end

          it 'uses SUBSCRIPTION_PORTAL_URL' do
            verify_usage_quota_request
            expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
          end
        end

        context 'when feature flag is set' do
          before do
            stub_feature_flags(use_mock_dot_api_for_usage_quota: true)
          end

          it 'uses SUBSCRIPTION_PORTAL_URL' do
            verify_usage_quota_request
            expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
          end
        end

        context 'when in development mode and feature flag is set' do
          before do
            stub_feature_flags(use_mock_dot_api_for_usage_quota: true)
            stub_rails_env('development')
          end

          let(:expected_url) { "http://localhost:4567/#{route_path}" }

          it 'uses mock server url' do
            verify_usage_quota_request
            expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
          end

          context 'when env variable is set' do
            before do
              stub_env('MOCK_CUSTOMER_DOT_PORTAL_SERVER_URL', 'http://another-url.com')
            end

            let(:expected_url) { "http://another-url.com/#{route_path}" }

            it 'uses env mock server url' do
              verify_usage_quota_request
              expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
            end
          end
        end
      end
    end
  end

  describe 'request methods', :saas do
    describe '#generate_trial' do
      subject do
        client.generate_trial({})
      end

      let(:route_path) { 'trials' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'

      it "nests in the trial_user param if needed" do
        expect(client).to receive(:http_post).with('trials', anything, { trial_user: { foo: 'bar' } })

        client.generate_trial(foo: 'bar')
      end
    end

    describe '#generate_trial_lead' do
      subject do
        client.generate_trial_lead({})
      end

      let(:route_path) { 'leads/gitlab_com/ultimates' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'

      it 'passes trial_user param' do
        expect(client).to receive(:http_post).with(route_path, anything, { trial_user: { foo: 'bar' } })

        client.generate_trial_lead(trial_user: { foo: 'bar' })
      end

      it 'nests in the trial_user param if needed' do
        expect(client).to receive(:http_post).with(route_path, anything, { trial_user: { foo: 'bar' } })

        client.generate_trial_lead(foo: 'bar')
      end
    end

    describe '#generate_addon_trial' do
      subject do
        client.generate_addon_trial({})
      end

      let(:route_path) { 'trials/create_addon' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'

      it "nests in the trial_user param if needed" do
        expect(client).to receive(:http_post).with('trials/create_addon', anything, { trial_user: { foo: 'bar' } })

        client.generate_addon_trial(foo: 'bar')
      end
    end

    describe '#generate_lead' do
      subject do
        client.generate_lead({})
      end

      let(:route_path) { 'leads/gitlab_com/hand_raises' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'
    end

    describe '#generate_iterable' do
      subject do
        client.generate_iterable({})
      end

      let(:route_path) { 'trials/create_iterable' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'
    end

    describe '#opt_in_lead' do
      subject do
        client.opt_in_lead({})
      end

      let(:route_path) { 'api/marketo_leads/opt_in' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
    end

    describe '#payment_form_params' do
      subject do
        client.payment_form_params('cc', 123)
      end

      let(:http_method) { :get }
      let(:route_path) { 'payment_forms/cc' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'
    end

    describe '#validate_payment_method' do
      subject do
        client.validate_payment_method('test_payment_method_id', {})
      end

      let(:http_method) { :post }
      let(:route_path) { 'api/payment_methods/test_payment_method_id/validate' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'
    end

    describe '#create_seat_link' do
      subject do
        seat_link_data = Gitlab::SeatLinkData.new(
          timestamp: Time.current,
          key: 'license_key',
          max_users: 5,
          billable_users_count: 4)

        client.create_seat_link(seat_link_data)
      end

      let(:http_method) { :post }
      let(:route_path) { 'api/v1/seat_links' }
      let(:headers) do
        {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'User-Agent' => "GitLab/#{Gitlab::VERSION}"
        }
      end

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'
    end

    describe '#namespace_eligible_trials' do
      subject do
        client.namespace_eligible_trials(namespace_ids: ['1'])
      end

      let(:http_method) { :get }
      let(:route_path) { 'api/v1/gitlab/namespaces/trials/eligibility' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'
    end

    describe '#namespace_trial_types' do
      subject do
        client.namespace_trial_types
      end

      let(:http_method) { :get }
      let(:route_path) { 'api/v1/gitlab/namespaces/trials/trial_types' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'
    end

    describe '#verify_usage_quota' do
      subject(:verify_usage_quota_request) { client.verify_usage_quota(params) }

      let(:params) do
        {
          event_type: 'ai_request',
          feature_qualified_name: 'duo_chat',
          realm: 'saas',
          user_id: 1,
          root_namespace_id: 1
        }
      end

      let(:http_method) { :head }
      let(:route_path) { 'api/v1/consumers/resolve' }

      it_behaves_like 'when response is successful'
      it_behaves_like 'when response code is 422'
      it_behaves_like 'when response code is 500'
      it_behaves_like 'when http call raises an exception'
      it_behaves_like 'a request that sends the GITLAB_QA_USER_AGENT value in the "User-Agent" header'

      context 'when response code is 402' do
        let(:response) { Net::HTTPPaymentRequired.new(1.0, '402', 'Payment Required') }

        it 'returns the "Payment required" error' do
          allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)

          expect(verify_usage_quota_request[:success]).to eq(false)
          expect(verify_usage_quota_request[:data][:errors]).to eq("HTTP status code: 402")
        end
      end

      describe 'url' do
        let(:expected_url) { "#{::Gitlab::Routing.url_helpers.subscription_portal_url}/#{route_path}" }
        let(:response) { Net::HTTPSuccess.new(1.0, '201', 'OK') }

        before do
          allow(Gitlab::HTTP).to receive(http_method).and_return(gitlab_http_response)
          stub_feature_flags(use_mock_dot_api_for_usage_quota: false)
        end

        it 'uses SUBSCRIPTION_PORTAL_URL' do
          verify_usage_quota_request
          expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
        end

        context 'when in development mode' do
          before do
            stub_rails_env('development')
          end

          it 'uses SUBSCRIPTION_PORTAL_URL' do
            verify_usage_quota_request
            expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
          end
        end

        context 'when feature flag is set' do
          before do
            stub_feature_flags(use_mock_dot_api_for_usage_quota: true)
          end

          it 'uses SUBSCRIPTION_PORTAL_URL' do
            verify_usage_quota_request
            expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
          end
        end

        context 'when in development mode and feature flag is set' do
          before do
            stub_feature_flags(use_mock_dot_api_for_usage_quota: true)
            stub_rails_env('development')
          end

          let(:expected_url) { "http://localhost:4567/#{route_path}" }

          it 'uses mock server url' do
            verify_usage_quota_request
            expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
          end

          context 'when env variable is set' do
            before do
              stub_env('MOCK_CUSTOMER_DOT_PORTAL_SERVER_URL', 'http://another-url.com')
            end

            let(:expected_url) { "http://another-url.com/#{route_path}" }

            it 'uses env mock server url' do
              verify_usage_quota_request
              expect(Gitlab::HTTP).to have_received(http_method).with(expected_url, anything)
            end
          end
        end
      end
    end
  end
end
