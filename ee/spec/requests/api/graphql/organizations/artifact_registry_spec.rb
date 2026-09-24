# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Reading the organization Artifact Registry', :use_clean_rails_memory_store_caching, feature_category: :artifact_registry do
  include GraphqlHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:current_user) { create(:organization_user, organization: organization).user }
  let_it_be(:non_member) { create(:user) }
  let_it_be(:mapping) do
    create(:artifact_registry_namespace_mapping, organization: organization)
  end

  let(:base_url) { 'https://artifact-registry.example.test' }
  let(:service_token) { 'ar-service-credential-value' }
  let(:namespace_uuid) { mapping.ar_namespace_id }
  let(:namespace_url) { "#{base_url}/api/gitlab/v1/namespaces/#{namespace_uuid}" }
  let(:json_headers) { { 'Content-Type' => 'application/json' } }
  let(:status) { 'active' }

  let(:namespace_body) do
    {
      'id' => namespace_uuid,
      'slug' => 'acme',
      'platform' => 'gitlab',
      'entity_type' => 'group',
      'entity_id' => '42',
      'status' => status,
      'created_at' => '2026-07-01T10:00:00Z'
    }
  end

  let(:fields) { 'slug status createdAt' }

  let(:query) do
    graphql_query_for(
      :organization,
      { id: organization.to_global_id.to_s },
      query_graphql_field(:artifact_registry, {}, fields)
    )
  end

  let(:registry_data) { graphql_data.dig('organization', 'artifactRegistry') }

  before do
    stub_config(artifact_registry: { api_url: base_url })
    allow_next_instance_of(ArtifactRegistry::ServiceCredential) do |credential|
      allow(credential).to receive(:token).and_return(service_token)
    end
  end

  def stub_namespace(status:, body: namespace_body.to_json)
    stub_request(:get, namespace_url)
      .with(headers: { ArtifactRegistry::Client::SERVICE_TOKEN_HEADER => service_token })
      .to_return(status: status, headers: json_headers, body: body)
  end

  context 'when the artifact_registry_ui flag is on' do
    context 'when the organization is activated' do
      it 'returns the slug, status, and creation time from a single AR call', :aggregate_failures do
        request = stub_namespace(status: 200)

        post_graphql(query, current_user: current_user)

        expect(response).to have_gitlab_http_status(:ok)
        expect(request).to have_been_requested.once
        expect(registry_data).to eq(
          'slug' => 'acme',
          'status' => 'active',
          'createdAt' => '2026-07-01T10:00:00+00:00'
        )
      end

      context 'when AR returns an unrecognized status' do
        let(:status) { 'newly_added_state' }

        it 'passes the unknown status through without raising', :aggregate_failures do
          stub_namespace(status: 200)

          post_graphql(query, current_user: current_user)

          expect(graphql_errors).to be_nil
          expect(registry_data['status']).to eq('newly_added_state')
        end
      end

      context 'when AR returns a 200 with no status field' do
        it 'resolves the unknown status rather than nulling the non-null field', :aggregate_failures do
          stub_namespace(status: 200, body: namespace_body.except('status').to_json)

          post_graphql(query, current_user: current_user)

          expect(graphql_errors).to be_nil
          expect(registry_data['status']).to eq('unknown')
        end
      end

      context 'when the mapped namespace is unknown to AR (404)' do
        it 'renders the unknown status with null slug and creation time, no error', :aggregate_failures do
          stub_namespace(status: 404, body: {}.to_json)

          post_graphql(query, current_user: current_user)

          expect(response).to have_gitlab_http_status(:ok)
          expect(graphql_errors).to be_nil
          expect(registry_data).to eq(
            'slug' => nil,
            'status' => 'unknown',
            'createdAt' => nil
          )
        end
      end

      context 'when AR denies the read (403)' do
        it 'renders the registry not-available while a sibling field still resolves', :aggregate_failures do
          stub_namespace(status: 403, body: {}.to_json)

          post_graphql(with_sibling_query, current_user: current_user)

          expect(response).to have_gitlab_http_status(:ok)
          expect(registry_data).to be_nil
          expect(graphql_errors).to be_nil
          expect(graphql_data.dig('organization', 'name')).to eq(organization.name)
        end
      end

      context 'when AR is unavailable (503)' do
        it 'answers service-unavailable while a sibling field making no AR call still resolves', :aggregate_failures do
          stub_namespace(status: 503, body: {}.to_json)

          post_graphql(with_sibling_query, current_user: current_user)

          expect(registry_data).to be_nil
          expect(graphql_errors).to be_present
          expect(graphql_data.dig('organization', 'name')).to eq(organization.name)
        end
      end
    end

    context 'when the organization has no mapping row' do
      let_it_be(:bare_organization) { create(:organization) }
      let_it_be(:bare_user) { create(:organization_user, organization: bare_organization).user }

      let(:query) do
        graphql_query_for(
          :organization,
          { id: bare_organization.to_global_id.to_s },
          query_graphql_field(:artifact_registry, {}, fields)
        )
      end

      it 'resolves null and makes no AR call', :aggregate_failures do
        request = stub_request(:get, %r{/api/gitlab/v1/namespaces/})

        post_graphql(query, current_user: bare_user)

        expect(response).to have_gitlab_http_status(:ok)
        expect(registry_data).to be_nil
        expect(request).not_to have_been_requested
      end
    end

    context 'when the viewer lacks read_artifact_registry' do
      it 'resolves null and makes no AR call', :aggregate_failures do
        request = stub_request(:get, namespace_url)

        post_graphql(query, current_user: non_member)

        expect(response).to have_gitlab_http_status(:ok)
        expect(registry_data).to be_nil
        expect(request).not_to have_been_requested
      end
    end
  end

  context 'when the artifact_registry_ui flag is off' do
    it 'keeps the field in the schema, resolves null, and makes no AR call', :aggregate_failures do
      request = stub_request(:get, namespace_url)
      stub_feature_flags(artifact_registry_ui: false)

      post_graphql(query, current_user: current_user)

      expect(response).to have_gitlab_http_status(:ok)
      expect(GitlabSchema.types['Organization'].fields).to have_key('artifactRegistry')
      expect(registry_data).to be_nil
      expect(request).not_to have_been_requested
    end
  end

  def with_sibling_query
    graphql_query_for(
      :organization,
      { id: organization.to_global_id.to_s },
      "name #{query_graphql_field(:artifact_registry, {}, fields)}"
    )
  end
end
