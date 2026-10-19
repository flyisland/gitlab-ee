# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::CodeSuggestions, :saas, :use_clean_rails_memory_store_caching,
  feature_category: :code_suggestions do
  include WorkhorseHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, developers: user) }
  let_it_be(:subscription) { create(:gitlab_subscription, :premium, namespace: group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:credits_purchase) { create(:gitlab_subscription_add_on_purchase, :gitlab_credits, namespace: group) }
  let_it_be(:access_token) { create(:personal_access_token, user: user, scopes: %w[ai_features]) }

  let(:quota_errors) { [] }
  let(:project_path) { project.full_path }

  before do
    stub_feature_flags(jh_saas_enable_billing_code_suggestions: true)
    user.user_preference.update!(duo_default_namespace_id: group.id)
    allow(Gitlab::SubscriptionPortal::Client).to receive(:verify_usage_quota)
      .and_return({ 'data' => { 'errors' => quota_errors } })
    allow(CloudConnector::Tokens).to receive(:get).and_return('gateway-token')
  end

  shared_examples 'checks the Credits usage quota' do
    it 'checks the project root group before allowing the request' do
      expect(Gitlab::SubscriptionPortal::Client).to receive(:verify_usage_quota)
        .with(hash_including(user_id: user.id, root_namespace_id: group.id))

      request

      expect(response).to have_gitlab_http_status(success_status)
    end

    %w[402 403].each do |error|
      context "when the quota service returns #{error}" do
        let(:quota_errors) { [error] }

        it 'rejects the request when the quota check returns an error' do
          request

          expect(response).to have_gitlab_http_status(:unauthorized)
        end
      end
    end

    context 'without a project path' do
      let(:project_path) { nil }

      it 'checks the default Duo namespace' do
        expect(Gitlab::SubscriptionPortal::Client).to receive(:verify_usage_quota)
          .with(hash_including(root_namespace_id: group.id))

        request

        expect(response).to have_gitlab_http_status(success_status)
      end
    end

    context 'when the project belongs to a different group' do
      let_it_be(:other_group) { create(:group, developers: user) }
      let_it_be(:other_project) { create(:project, group: other_group) }
      let(:project_path) { other_project.full_path }
      let(:quota_errors) { ['402'] }

      it 'checks the project group instead of the default Duo namespace' do
        expect(Gitlab::SubscriptionPortal::Client).to receive(:verify_usage_quota)
          .with(hash_including(root_namespace_id: other_group.id))

        request

        expect(response).to have_gitlab_http_status(:unauthorized)
      end
    end

    context 'when the feature flag is disabled' do
      let(:quota_errors) { ['402'] }

      before do
        stub_feature_flags(jh_saas_enable_billing_code_suggestions: false)
      end

      it 'does not add a quota check' do
        expect(Gitlab::SubscriptionPortal::Client).not_to receive(:verify_usage_quota)

        request

        expect(response).to have_gitlab_http_status(success_status)
      end
    end

    context 'when the project policy denies code suggestions' do
      before do
        allow(Ability).to receive(:allowed?).and_call_original
        allow(Ability).to receive(:allowed?).with(user, :access_code_suggestions, project).and_return(false)
      end

      it 'rejects the request after the quota check succeeds' do
        expect(Gitlab::SubscriptionPortal::Client).to receive(:verify_usage_quota)

        request

        expect(response).to have_gitlab_http_status(:unauthorized)
      end

      context 'when the feature flag is disabled' do
        before do
          stub_feature_flags(jh_saas_enable_billing_code_suggestions: false)
        end

        it 'rejects the request without checking the quota' do
          expect(Gitlab::SubscriptionPortal::Client).not_to receive(:verify_usage_quota)

          request

          expect(response).to have_gitlab_http_status(:unauthorized)
        end
      end
    end

    %i[duo_pro duo_enterprise].each do |add_on|
      context "with an assigned #{add_on} seat" do
        let_it_be(:purchase) { create(:gitlab_subscription_add_on_purchase, add_on, namespace: group) }
        let_it_be(:assignment) do
          create(:gitlab_subscription_user_add_on_assignment, user: user, add_on_purchase: purchase)
        end

        it 'checks the quota for assigned seats too' do
          expect(Gitlab::SubscriptionPortal::Client).to receive(:verify_usage_quota)

          request

          expect(response).to have_gitlab_http_status(success_status)
        end
      end
    end
  end

  describe 'POST /code_suggestions/completions' do
    include_context 'workhorse headers'

    let(:success_status) { :ok }
    let(:intent) { 'completion' }
    let(:body) do
      {
        project_path: project_path,
        intent: intent,
        current_file: {
          file_name: 'test.rb',
          content_above_cursor: "def hello\n  ",
          content_below_cursor: ''
        }
      }
    end

    subject(:request) do
      post api('/code_suggestions/completions', personal_access_token: access_token),
        params: body.to_json, headers: workhorse_headers.merge('Content-Type' => 'application/json')
    end

    it_behaves_like 'checks the Credits usage quota'

    context 'with code generation' do
      let(:intent) { 'generation' }

      it_behaves_like 'checks the Credits usage quota'
    end
  end

  describe 'POST /code_suggestions/direct_access' do
    let(:success_status) { :created }

    subject(:request) do
      post api('/code_suggestions/direct_access', personal_access_token: access_token),
        params: { project_path: project_path }.compact
    end

    before do
      stub_feature_flags(incident_fail_over_completion_provider: false)
      allow_next_instance_of(Gitlab::Llm::AiGateway::CodeSuggestionsClient) do |client|
        allow(client).to receive(:direct_access_token)
          .and_return({ status: :success, token: 'direct-token', expires_at: 1.hour.from_now.to_i })
      end
    end

    it_behaves_like 'checks the Credits usage quota'
  end

  %w[enabled connection_details].each do |endpoint|
    describe "POST /code_suggestions/#{endpoint}" do
      let(:quota_errors) { ['402'] }

      it 'does not add a quota check to status and telemetry requests' do
        expect(Gitlab::SubscriptionPortal::Client).not_to receive(:verify_usage_quota)

        post api("/code_suggestions/#{endpoint}", personal_access_token: access_token),
          params: { project_path: project_path }

        expect(response).to have_gitlab_http_status(endpoint == 'enabled' ? :ok : :created)
      end
    end
  end
end
