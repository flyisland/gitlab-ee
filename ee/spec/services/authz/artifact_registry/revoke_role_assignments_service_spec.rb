# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Authz::ArtifactRegistry::RevokeRoleAssignmentsService, feature_category: :system_access do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:current_user) { create(:user, organization: organization) }
  let_it_be(:assignee_a) { create(:user, organization: organization) }
  let_it_be(:assignee_b) { create(:user, organization: organization) }

  let(:resource_id) { Gitlab::Utils.uuid_v7 }
  let(:other_resource_id) { Gitlab::Utils.uuid_v7 }
  let(:token) { 'ar-token' }
  let(:client) { instance_double(Authn::IamService::UpdateRelationshipsClient) }
  let(:revocations) do
    [
      { assignee: assignee_a, resource_id: resource_id },
      { assignee: assignee_b, resource_id: other_resource_id }
    ]
  end

  subject(:execute) do
    described_class.new(current_user: current_user, organization: organization, revocations: revocations).execute
  end

  before do
    issuer = instance_double(Authn::TokenExchange::TokenIssuer, token: token)
    allow(Authn::TokenExchange::TokenIssuer).to receive(:new).and_return(issuer)

    allow(Authn::IamService::UpdateRelationshipsClient).to receive(:new).and_return(client)
    allow(client).to receive(:revoke_roles).and_return(::Gitlab::Iam::Update::V1::DeleteRelationshipsResponse.new)
  end

  context 'when all revocations are valid' do
    it 'deletes every assignment in a single call and returns success', :aggregate_failures do
      expect(client).to receive(:revoke_roles) do |keys, organization_uuid:, token:|
        expect(token).to eq('ar-token')
        expect(organization_uuid).to eq(organization.uuid)
        expect(keys).to match_array([
          { assignee_id: assignee_a.id, resource_id: resource_id },
          { assignee_id: assignee_b.id, resource_id: other_resource_id }
        ])

        ::Gitlab::Iam::Update::V1::DeleteRelationshipsResponse.new
      end

      result = execute
      expect(result).to be_success
      expect(result.payload[:revoked_role_count]).to eq(2)
    end
  end

  # IAM only accepts canonical lowercase ids, so the service normalizes case
  # instead of rejecting an uppercase id.
  context 'when a resource_id is an uppercase UUIDv7' do
    let(:revocations) do
      [{ assignee: assignee_a, resource_id: resource_id.upcase }]
    end

    it 'downcases the id before deleting' do
      expect(client).to receive(:revoke_roles) do |keys, **_kwargs|
        expect(keys).to match_array([{ assignee_id: assignee_a.id, resource_id: resource_id }])

        ::Gitlab::Iam::Update::V1::DeleteRelationshipsResponse.new
      end

      expect(execute).to be_success
    end
  end

  # Deleting the same key twice is harmless, so duplicates collapse instead of
  # erroring the way the grant path must, and the count reports distinct
  # assignments.
  context 'when the same revocation is listed twice' do
    let(:revocations) do
      [
        { assignee: assignee_a, resource_id: resource_id },
        { assignee: assignee_a, resource_id: resource_id }
      ]
    end

    it 'sends one key and counts one revocation', :aggregate_failures do
      expect(client).to receive(:revoke_roles) do |keys, **_kwargs|
        expect(keys).to eq([{ assignee_id: assignee_a.id, resource_id: resource_id }])

        ::Gitlab::Iam::Update::V1::DeleteRelationshipsResponse.new
      end

      result = execute
      expect(result).to be_success
      expect(result.payload[:revoked_role_count]).to eq(1)
    end
  end

  context 'when there is no current user' do
    let(:current_user) { nil }

    it 'returns an error and does not call IAM', :aggregate_failures do
      expect(client).not_to receive(:revoke_roles)

      result = execute
      expect(result).to be_error
      expect(result.message).to include('signed in')
    end
  end

  context 'when the organization could not be determined' do
    let(:organization) { nil }

    it 'returns an error and does not call IAM', :aggregate_failures do
      expect(client).not_to receive(:revoke_roles)

      result = execute
      expect(result).to be_error
      expect(result.message).to include('Organization')
    end
  end

  context 'when the caller is not a member of the organization' do
    let_it_be(:organization) { create(:organization) }

    it 'returns an error and does not call IAM', :aggregate_failures do
      expect(client).not_to receive(:revoke_roles)

      result = execute
      expect(result).to be_error
      expect(result.message).to include('another organization')
    end
  end

  # Revoke applies no organization rule to the assignee, unlike grant.
  # Requiring membership would make a role unrevokable the moment someone is
  # removed from the organization, which is exactly when it has to go
  # (gitlab-org/gitlab#610042).
  context 'when the caller is a member of the organization but not owned by it' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:current_user) { create(:user) }
    let_it_be(:assignee_a) { create(:user, organization: current_user.organization) }

    let(:revocations) do
      [{ assignee: assignee_a, resource_id: resource_id }]
    end

    before do
      create(:organization_user, organization: organization, user: current_user)
    end

    it 'revokes even though the assignee is not a member of that organization', :aggregate_failures do
      expect(current_user.organization_id).not_to eq(organization.id)
      expect(Organizations::OrganizationUser.member_ids_among(organization, [assignee_a.id])).to be_empty
      expect(client).to receive(:revoke_roles)

      expect(execute).to be_success
    end
  end

  context 'when no revocations are given' do
    let(:revocations) { [] }

    it 'returns an error and does not call IAM', :aggregate_failures do
      expect(client).not_to receive(:revoke_roles)

      result = execute
      expect(result).to be_error
      expect(result.message).to include('At least one')
    end
  end

  context 'when one assignee is owned by a different organization' do
    let_it_be(:other_org_user) { create(:user, organization: create(:organization)) }

    let(:revocations) do
      [
        { assignee: assignee_a, resource_id: resource_id },
        { assignee: other_org_user, resource_id: resource_id }
      ]
    end

    # Which organization owns the account says nothing about who may be
    # revoked. IAM keys the subject by organization plus user, so a key naming
    # someone with no identity in this one matches no tuple.
    it 'sends both keys and lets IAM answer for a subject it does not know' do
      expect(client).to receive(:revoke_roles) do |keys, **_kwargs|
        expect(keys).to contain_exactly(
          { assignee_id: assignee_a.id, resource_id: resource_id },
          { assignee_id: other_org_user.id, resource_id: resource_id }
        )
      end

      expect(execute).to be_success
    end
  end

  context 'when one assignee is nil (user not found)' do
    let(:revocations) do
      [{ assignee: nil, resource_id: resource_id }]
    end

    it 'deletes nothing and returns the generic not-found error', :aggregate_failures do
      expect(client).not_to receive(:revoke_roles)

      result = execute
      expect(result).to be_error
      expect(result.message).to include('could not be found')
    end
  end

  context 'when one resource_id is not a valid UUID' do
    let(:revocations) do
      [{ assignee: assignee_a, resource_id: 'not-a-uuid' }]
    end

    it 'deletes nothing and returns the bare message without a position prefix', :aggregate_failures do
      expect(client).not_to receive(:revoke_roles)

      result = execute
      expect(result).to be_error
      expect(result.message).to include('UUIDv7')
      expect(result.message).not_to include('Revocation ')
    end
  end

  context 'when one resource_id is a UUIDv4' do
    let(:revocations) do
      [{ assignee: assignee_a, resource_id: 'c7a3b3f4-9d3a-4e46-9c3e-3a1f0b2d4e5f' }]
    end

    it 'deletes nothing and returns an error', :aggregate_failures do
      expect(client).not_to receive(:revoke_roles)

      result = execute
      expect(result).to be_error
      expect(result.message).to include('UUIDv7')
    end
  end

  context 'when several revocations are invalid for different reasons' do
    let(:revocations) do
      [
        { assignee: assignee_a, resource_id: 'not-a-uuid' },
        { assignee: nil, resource_id: resource_id }
      ]
    end

    it 'reports every validation error, identified by position', :aggregate_failures do
      expect(client).not_to receive(:revoke_roles)

      result = execute
      expect(result).to be_error
      expect(result.message).to include('Revocation 1 on resource not-a-uuid', 'UUIDv7')
      expect(result.message).to include("Revocation 2 on resource #{resource_id}", 'could not be found')
    end
  end

  context 'when the IAM delete fails' do
    {
      not_found: 'could not be found',
      permission_denied: 'not authorized to revoke',
      unauthenticated: 'Could not authenticate',
      invalid_request: 'revocation request was invalid',
      unavailable: 'service is unavailable',
      timeout: 'did not respond in time',
      unknown: 'could not be completed'
    }.each do |reason, message_fragment|
      it "translates the #{reason} reason into a user-facing message and exposes it as reason", :aggregate_failures do
        allow(client).to receive(:revoke_roles).and_raise(
          Authn::IamService::UpdateRelationshipsClient::RequestError.new('diagnostic', reason: reason)
        )

        result = execute
        expect(result).to be_error
        expect(result.message).to include(message_fragment)
        expect(result.reason).to eq(reason)
      end
    end
  end
end
