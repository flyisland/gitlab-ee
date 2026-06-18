# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'API::WorkItems (group work items)', feature_category: :portfolio_management do
  let_it_be(:user, freeze: false) { create(:user) }
  let_it_be(:editor, freeze: false) { create(:user) }

  let_it_be(:group, freeze: false) { create(:group, :private, reporters: user) }
  let_it_be(:group_label, freeze: false) { create(:group_label, group: group, title: 'group-label') }
  let_it_be(:group_milestone, freeze: false) { create(:milestone, group: group, title: 'group-milestone') }
  let_it_be(:group_work_item, freeze: false) do
    create(
      :work_item,
      :group_level,
      namespace: group,
      labels: [group_label],
      milestone: group_milestone,
      description: 'Group work item description'
    )
  end

  let_it_be(:group_work_item2, freeze: false) { create(:work_item, :group_level, namespace: group) }

  let_it_be(:project, freeze: false) do
    create(:project, :private, group: group, reporters: user)
  end

  before do
    stub_feature_flags(work_item_rest_api: user)
    stub_licensed_features(epics: true)
  end

  include_context 'with API work items shared helpers'

  describe 'GET /namespaces/:id/-/work_items' do
    context 'when listing group work items' do
      let_it_be(:namespace_record, freeze: false) { group }
      let(:primary_work_item) { group_work_item }
      let(:secondary_work_item) { group_work_item2 }
      let(:label) { group_label }
      let(:milestone) { group_milestone }
      let(:api_request_path) { "/namespaces/#{namespace_record.full_path}/-/work_items" }

      it_behaves_like 'work item listing endpoint'
      it_behaves_like 'work item listing filters'
      it_behaves_like 'work item listing EE iteration filters'
      it_behaves_like 'work item listing EE filters'

      context 'with linked_items feature' do
        let_it_be(:list_subject_wi, freeze: false) { create(:work_item, :group_level, namespace: group) }
        let_it_be(:list_blocked_wi, freeze: false) { create(:work_item, :group_level, namespace: group) }
        let_it_be(:list_blocker_wi, freeze: false) { create(:work_item, :group_level, namespace: group) }

        before_all do
          create(:work_item_link, source: list_subject_wi, target: list_blocked_wi, link_type: 'blocks')
          create(:work_item_link, source: list_blocker_wi, target: list_subject_wi, link_type: 'blocks')
          list_subject_wi.update_blocking_issues_count!
        end

        it 'returns correct blocking/blocked_by counts per work item without N+1 queries' do
          request_params = { features: 'linked_items' }

          # Warmup
          get api(api_request_path, user), params: request_params

          baseline = ActiveRecord::QueryRecorder.new(skip_cached: false) do
            get api(api_request_path, user), params: request_params
          end

          extra_work_item = create(:work_item, :group_level, namespace: namespace_record)
          create(:work_item_link, source: list_blocker_wi, target: extra_work_item, link_type: 'blocks')

          expect do
            get api(api_request_path, user), params: request_params
          end.to issue_same_number_of_queries_as(baseline).with_threshold(1)

          expect(response).to have_gitlab_http_status(:ok)
          # Value assertions guard against a missing preload: blocked_by_count falls back to 0
          # without the preload, so query-count parity alone wouldn't catch a regression.
          expect(work_item_json_for(list_subject_wi).fetch('features').fetch('linked_items')).to include(
            'blocking_count' => 1,
            'blocked_by_count' => 1
          )
          expect(work_item_json_for(extra_work_item).fetch('features').fetch('linked_items')).to include(
            'blocking_count' => 0,
            'blocked_by_count' => 1
          )
        end
      end
    end
  end

  describe 'GET /namespaces/:id/-/work_items/:work_item_iid' do
    context 'when fetching a group work item' do
      let(:namespace_record) { group }
      let(:api_request_path) { "/namespaces/#{namespace_record.full_path}/-/work_items" }
      let(:primary_work_item) { group_work_item }
      let(:label) { group_label }

      it_behaves_like 'work item show endpoint'

      it_behaves_like 'authorizing granular token permissions', :read_work_item do
        let(:boundary_object) { group }
        let(:request) do
          get api("#{api_request_path}/#{primary_work_item.iid}", personal_access_token: pat)
        end
      end

      context 'with linked_items feature' do
        let_it_be(:blocked_item, freeze: false) { create(:work_item, :group_level, namespace: group) }
        let_it_be(:blocking_item, freeze: false) { create(:work_item, :group_level, namespace: group) }

        before_all do
          create(:work_item_link, source: group_work_item, target: blocked_item, link_type: 'blocks')
          create(:work_item_link, source: blocking_item, target: group_work_item, link_type: 'blocks')
          group_work_item.update_blocking_issues_count!
        end

        it 'returns blocking_count and blocked_by_count' do
          get api("#{api_request_path}/#{group_work_item.iid}", user), params: { features: 'linked_items' }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.dig('features', 'linked_items')).to include(
            'blocking_count' => 1,
            'blocked_by_count' => 1
          )
        end
      end
    end
  end

  describe 'GET /groups/:id/-/work_items' do
    let_it_be(:namespace_record, freeze: false) { group }
    let(:primary_work_item) { group_work_item }
    let(:secondary_work_item) { group_work_item2 }
    let(:label) { group_label }
    let(:milestone) { group_milestone }
    let(:api_request_path) { "/groups/#{group.id}/-/work_items" }

    it_behaves_like 'work item listing endpoint'
    it_behaves_like 'work item listing filters'
    it_behaves_like 'work item listing EE iteration filters'

    it_behaves_like 'authorizing granular token permissions', :read_work_item do
      let(:boundary_object) { group }
      let(:request) do
        get api("/groups/#{group.id}/-/work_items", personal_access_token: pat)
      end
    end

    it_behaves_like 'work item N+1 query prevention'

    context 'with include_descendants filter' do
      let_it_be(:subgroup, freeze: false) do
        create(:group, :private, parent: group).tap { |sub| sub.add_reporter(user) }
      end

      let_it_be(:subgroup_project, freeze: false) do
        create(:project, :private, group: subgroup, reporters: user)
      end

      let_it_be(:subgroup_project_work_item, freeze: false) { create(:work_item, project: subgroup_project) }

      it 'includes work items from descendant groups' do
        get api("/groups/#{group.id}/-/work_items", user), params: { include_descendants: true }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.pluck('id')).to include(subgroup_project_work_item.id)
      end

      it 'excludes work items from descendant groups by default' do
        get api("/groups/#{group.id}/-/work_items", user)

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.pluck('id')).not_to include(subgroup_project_work_item.id)
      end
    end

    context 'with include_ancestors filter' do
      let_it_be(:subgroup, freeze: false) do
        create(:group, :private, parent: group).tap { |sub| sub.add_reporter(user) }
      end

      it 'includes work items from ancestor groups' do
        get api("/groups/#{subgroup.id}/-/work_items", user), params: { include_ancestors: true }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.pluck('id')).to include(group_work_item.id, group_work_item2.id)
      end

      it 'excludes work items from ancestor groups by default' do
        get api("/groups/#{subgroup.id}/-/work_items", user)

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.pluck('id')).not_to include(group_work_item.id, group_work_item2.id)
      end
    end

    context 'with include_archived filter' do
      let_it_be(:archived_project, freeze: false) do
        create(:project, :archived, group: group, reporters: user)
      end

      let_it_be(:archived_project_work_item, freeze: false) { create(:work_item, project: archived_project) }

      it 'excludes archived project work items by default' do
        get api("/groups/#{group.id}/-/work_items", user), params: { include_descendants: true }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.pluck('id')).not_to include(archived_project_work_item.id)
      end

      it 'includes archived project work items when set to true' do
        get api("/groups/#{group.id}/-/work_items", user),
          params: { include_descendants: true, include_archived: true }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.pluck('id')).to include(archived_project_work_item.id)
      end
    end

    context 'with N+1 query prevention for EE fields' do
      let(:all_fields_param) { ::API::WorkItems::ALL_FIELDS.join(',') }
      let(:all_features_param) { ::API::WorkItems::FEATURE_SUPPORTED_VALUES.join(',') }
      let(:ee_request_params) { { features: all_features_param, fields: all_fields_param } }

      before do
        stub_licensed_features(iterations: true, issuable_health_status: true, epics: true, okrs: true)

        # Ensure one-time lazy writes are settled so they don't skew the N+1 count.
        # These records are normally created on first API request and vary by test ordering.
        user.create_user_preference! unless user.user_preference
        user.update_column(:last_activity_on, Time.zone.today) unless user.last_activity_on == Time.zone.today

        create_ee_work_items(namespace_record)

        2.times { get api(api_request_path, user), params: ee_request_params }
      end

      it 'does not cause N+1 queries for EE features' do
        baseline = ActiveRecord::QueryRecorder.new(skip_cached: false) do
          get api(api_request_path, user), params: ee_request_params
        end

        initial_count = json_response.size

        create_ee_work_items(namespace_record)

        # Settle first-request queries for any users created by the factories above before comparing.
        get api(api_request_path, user), params: ee_request_params

        expect do
          get api(api_request_path, user), params: ee_request_params
        end.to issue_same_number_of_queries_as(baseline).with_threshold(1)

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.size).to be > initial_count

        wi_sourced_by_work_item = json_response.find do |wi|
          wi.dig('features', 'start_and_due_date', 'start_date_sourcing_work_item')
        end
        expect(wi_sourced_by_work_item.dig('features', 'start_and_due_date', 'start_date_sourcing_work_item',
          'id')).to be_present
        expect(wi_sourced_by_work_item.dig('features', 'start_and_due_date', 'due_date_sourcing_work_item',
          'id')).to be_present

        wi_sourced_by_milestone = json_response.find do |wi|
          wi.dig('features', 'start_and_due_date', 'start_date_sourcing_milestone')
        end
        expect(wi_sourced_by_milestone.dig('features', 'start_and_due_date', 'start_date_sourcing_milestone',
          'id')).to be_present
        expect(wi_sourced_by_milestone.dig('features', 'start_and_due_date', 'due_date_sourcing_milestone',
          'id')).to be_present
      end

      def create_ee_work_items(namespace)
        iteration = create(:iteration, group: namespace)

        2.times do
          create_namespace_work_item(
            namespace,
            author: user,
            iteration: iteration,
            health_status: :on_track,
            start_date: Date.current,
            due_date: 1.week.from_now.to_date
          )
        end

        2.times do
          epic = create(:work_item, :epic, :group_level, namespace: namespace, author: user)
          create(:color, work_item: epic)
        end

        2.times do
          objective = create(:work_item, :objective, :group_level, namespace: namespace, author: user)
          create(:progress, work_item: objective)
        end

        sourcing_work_item = create(:work_item, :epic, :group_level, namespace: namespace, author: user)
        sourcing_milestone = create(:milestone, group: namespace)

        epic_sourced_by_work_item = create(:work_item, :epic, :group_level, namespace: namespace, author: user)
        create(:work_items_dates_source,
          work_item: epic_sourced_by_work_item,
          start_date_sourcing_work_item: sourcing_work_item,
          due_date_sourcing_work_item: sourcing_work_item)

        epic_sourced_by_milestone = create(:work_item, :epic, :group_level, namespace: namespace, author: user)
        create(:work_items_dates_source,
          work_item: epic_sourced_by_milestone,
          start_date_sourcing_milestone: sourcing_milestone,
          due_date_sourcing_milestone: sourcing_milestone)
      end
    end

    context 'when using an unescaped subgroup path' do
      let_it_be(:subgroup, freeze: false) do
        create(:group, :private, parent: group).tap { |sub| sub.add_reporter(user) }
      end

      let_it_be(:subgroup_work_item, freeze: false) do
        create(:work_item, :group_level, namespace: subgroup)
      end

      it 'returns subgroup work items' do
        get api("/groups/#{subgroup.full_path}/-/work_items", user)

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.pluck('id')).to contain_exactly(subgroup_work_item.id)
      end
    end
  end

  describe 'GET /groups/:id/-/work_items/:work_item_iid' do
    let(:api_request_path) { "/groups/#{group.id}/-/work_items" }
    let(:primary_work_item) { group_work_item }
    let(:label) { group_label }

    it_behaves_like 'work item show endpoint'
  end
end
