# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::RequestParams do
  let_it_be(:user) { create(:user) }
  let_it_be(:root_group) { create(:group) }
  let_it_be(:sub_group) { create(:group, parent: root_group) }
  let_it_be(:sub_group_project) { create(:project, group: sub_group) }
  let_it_be(:root_group_projects) { FactoryBot.create_list(:project, 2, group: root_group) }
  let_it_be(:project_1_id) { sub_group_project.id }
  let_it_be(:project_2_id) { root_group_projects[0].id }
  let_it_be(:project_3_id) { root_group_projects[1].id }

  let(:project_ids) { root_group_projects.collect(&:id) }
  let(:params) do
    {
      start_date: '2020-01-01',
      end_date: '2020-03-01',
      project_ids: [project_2_id, project_3_id],
      current_user: user
    }
  end

  subject(:request_params) { described_class.new(params) }

  before_all do
    root_group.add_owner(user)
  end

  describe 'validations' do
    it 'is valid' do
      expect(request_params).to be_valid
    end

    context 'when `start_date` is missing' do
      before do
        params[:start_date] = nil
      end

      it 'is valid', time_travel_to: '2019-03-01' do
        expect(request_params).to be_valid
      end
    end

    context 'when `start_date` is earlier than `end_date`' do
      before do
        params[:start_date] = '2021-01-01'
        params[:end_date] = '2020-01-01'
      end

      it 'is invalid' do
        expect(request_params).not_to be_valid
        expect(request_params.errors.messages[:end_date]).not_to be_empty
      end
    end

    context 'when the date range exceeds 180 days' do
      before do
        params[:start_date] = '2021-01-01'
        params[:end_date] = '2022-01-01'
      end

      it 'is invalid' do
        expect(request_params).not_to be_valid
        expect(request_params.errors.messages[:end_date]).to include(
          s_('JH|PerformanceAnalytics|The given date range is larger than 180 days')
        )
      end
    end
  end

  it 'casts `end_date` to `Time`' do
    expect(request_params.end_date).to be_a_kind_of(Time)
  end

  it 'casts `start_date` to `Time`' do
    expect(request_params.start_date).to be_a_kind_of(Time)
  end

  describe 'optional `project_ids`' do
    context 'when `project_ids` is not an array' do
      before do
        params[:project_ids] = project_1_id
      end

      it { expect(request_params.project_ids).to eq([project_1_id]) }
    end

    context 'when `project_ids` is nil' do
      before do
        params[:project_ids] = nil
      end

      it { expect(request_params.project_ids).to eq([]) }
    end

    context 'when `project_ids` is empty' do
      before do
        params[:project_ids] = []
      end

      it { expect(request_params.project_ids).to eq([]) }
    end
  end

  describe 'sorting params' do
    before do
      params.merge!(sort: "username", direction: "asc")
    end

    it 'adds sorting params to options' do
      options = request_params.to_options

      expect(options[:sort]).to eq("username")
      expect(options[:direction]).to eq("asc")
    end
  end
end
