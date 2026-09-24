# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::CreateService, '#execute', feature_category: :groups_and_projects do
  let_it_be(:user, freeze: false) { create(:user) }
  let_it_be(:organization, freeze: false) { create(:organization, users: [user]) }
  let(:current_user) { user }
  let(:group_params) do
    {
      name: 'GitLab',
      path: 'group_path',
      visibility_level: Gitlab::VisibilityLevel::PUBLIC,
      organization_id: organization.id
    }.merge(extra_params)
  end

  let(:extra_params) { {} }
  let(:created_group) { response[:group] }

  subject(:response) { described_class.new(current_user, group_params).execute }

  context 'when user has exceed the group creation limit' do
    before do
      allow(user).to receive(:requires_identity_verification_to_create_group?).and_return(true)
    end

    it 'does create the group', :aggregate_failures do
      expect { response }.to change { Group.count }
      expect(response.http_status).to eq(:ok)
    end
  end
end
