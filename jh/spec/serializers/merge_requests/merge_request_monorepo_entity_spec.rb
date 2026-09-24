# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::MergeRequestMonorepoEntity, feature_category: :code_review_workflow do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:label_monorepo) { create(:group_label, group: group, name: 'topic::test1') }

  let_it_be(:merge_request, freeze: false) do
    create(:merge_request, :merged, source_project: project,
      merge_user: user, labels: [label_monorepo])
  end

  let_it_be(:pipeline) do
    create(:ci_pipeline, project: project, name: 'Build pipeline',
      head_pipeline_of: merge_request)
  end

  let(:request) { EntityRequest.new(current_user: user) }

  let(:entity) do
    described_class.new(merge_request, request: request)
  end

  before_all do
    group.add_owner(user)
  end

  describe '#as_json' do
    it 'contains required fields', :aggregate_failures do
      result = entity.as_json

      expect(result).to include(
        :merge_requests_list_status,
        :has_permission_to_merge,
        :other_merging_topic_label_name,
        :merge_requests,
        :merge_user,
        :merged_at,
        :central_pipeline
      )

      expect(result[:merge_requests].count).to eq(1)
      expect(result[:merge_requests].first).to include(
        :title,
        :path,
        :merge_error,
        :mergeable,
        :state,
        :head_pipeline,
        :breadcrumbs,
        :approvals_given,
        :approvals_left
      )

      expect(result[:merge_requests].first[:head_pipeline]).to include(
        :icon,
        :text,
        :label,
        :group,
        :tooltip,
        :has_details,
        :details_path,
        :illustration,
        :favicon
      )

      expect(result[:merge_requests].first[:breadcrumbs].first).to include(:text, :href)

      expect(result[:merge_user]).to eq(
        API::Entities::UserPath.represent(user, request: request).as_json
      )
    end
  end
end
