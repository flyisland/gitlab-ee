# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::MilestonesController, feature_category: :team_planning do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:milestone) { create(:milestone, group: group, title: 'group milestone') }
  let!(:project_milestone) { create(:milestone, project: project, title: 'project milestone') }

  before_all do
    group.add_owner(user)
  end

  before do
    sign_in(user)
  end

  describe '#index' do
    context 'when request format JSON' do
      it 'lists only group milestones' do
        get :index, params: { group_id: group.to_param, only_group: true }, format: :json

        milestones = json_response
        milestone_titles = milestones.map { |m| m['title'] }

        expect(response).to have_gitlab_http_status(:ok)
        expect(response.media_type).to eq 'application/json'
        expect(milestones.count).to eq(1)
        expect(milestone_titles).to match_array(['group milestone'])
      end

      context 'with subgroup milestones' do
        before do
          subgroup = create(:group, :public, parent: group)
          create(:milestone, group: subgroup, title: 'subgroup milestone')
        end

        it 'lists descendants group milestones' do
          get :index, params: { group_id: group.to_param, only_group: true }, format: :json

          milestones = json_response
          milestone_titles = milestones.map { |m| m['title'] }

          expect(milestones.count).to eq(2)
          expect(milestone_titles).to match_array(['group milestone', 'subgroup milestone'])
        end
      end

      context 'when request for a subgroup' do
        let(:subgroup) { create(:group, parent: group) }

        it 'includes ancestor group milestones' do
          get :index, params: { group_id: subgroup.to_param, only_group: true }, format: :json

          milestones = json_response

          expect(milestones.count).to eq(1)
          expect(milestones.first['title']).to eq('group milestone')
        end
      end
    end
  end
end
