# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project creation via Registrations::GroupsController',
  :with_current_organization, feature_category: :onboarding do
  let_it_be(:user, reload: true) { create(:user, onboarding_in_progress: true, organizations: [current_organization]) }
  let_it_be(:group) { create(:group, organization: current_organization) }

  describe 'POST #create' do
    let(:params) { { group: group_params, project: project_params } }
    let(:group_params) do
      {
        name: 'Group name',
        path: 'group-path',
        visibility_level: Gitlab::VisibilityLevel::PRIVATE.to_s,
        setup_for_company: nil
      }
    end

    let(:project_params) do
      {
        name: 'New project',
        path: 'project-path',
        visibility_level: Gitlab::VisibilityLevel::PRIVATE,
        initialize_with_readme: 'true'
      }
    end

    subject(:post_create) { post users_sign_up_groups_path, params: params }

    context 'with an authenticated user', :saas do
      before do
        # Stubbed not to break query budget. Should be safe as the query only happens on SaaS and the result is cached
        allow(Gitlab::Com).to receive(:gitlab_com_group_member?).and_return(nil)

        sign_in(user)
      end

      context 'when group and project can be created' do
        it 'creates a group' do
          # 204 before creating learn gitlab in worker
          allow(Gitlab::QueryLimiting::Transaction).to receive(:threshold).and_return(160)

          expect { post_create }.to change { Group.count }.by(1)
        end
      end

      context 'when group already exists and project can be created' do
        before_all do
          group.add_owner(user)
        end

        let_it_be(:group) { create(:group, organization: current_organization, owners: user) }
        let(:group_params) { { id: group.id } }

        it 'creates a project' do
          allow(Gitlab::QueryLimiting::Transaction).to receive(:threshold).and_return(160)

          # queries: core project is 78 and learn gitlab is 76, which is now in background
          expect { post_create }.to change { Project.count }.by(1)
        end
      end
    end
  end
end
