# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::MonorepoService, feature_category: :code_review_workflow do
  let_it_be(:group) { create(:group) }
  let_it_be(:group_owner) { create(:user) }
  let_it_be(:topic_label_name) { 'topic::test1' }
  let_it_be(:topic_label) { create(:group_label, group: group, name: topic_label_name) }

  let(:service) { described_class.new(group, topic_label_name) }

  let_it_be(:project1) { create(:project, :private, group: group) }
  let_it_be(:project2) { create(:project, :private, group: group) }
  let_it_be(:project3) { create(:project, :private, group: group) }
  let_it_be(:project4) { create(:project, :private, group: group) }

  before_all do
    group.add_owner(group_owner)
  end

  before do
    allow_any_instance_of(MergeRequest).to receive(:has_no_commits?).and_return(false)
    allow_any_instance_of(MergeRequest).to receive(:branch_missing?).and_return(false)
  end

  describe '#visible_merge_requests' do
    let(:project_owner) { create(:user) }
    let(:merged_mr) { create_merged_mr(project1) }
    let(:unmerged_mr) { create_unmerged_mr(project2) }
    let(:mr_without_label) { create_mr_without_label(project3) }
    let(:mr_with_another_topic) { create_mr_with_another_topic(project4) }

    let!(:subgroup) { create(:group, parent: group) }
    let!(:sub_project) { create(:project, :private, group: subgroup) }
    let!(:sub_mr) { create_unmerged_mr(sub_project) }

    before do
      merged_mr.project.add_owner(project_owner)
    end

    it 'returns merge requests' do
      expect(service.visible_merge_requests(group_owner)).to contain_exactly(merged_mr, unmerged_mr, sub_mr)
      expect(service.visible_merge_requests(project_owner)).to contain_exactly(merged_mr)
    end
  end

  describe '#merge_requests_list_status' do
    context 'when has merge request is merging' do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let(:lease_key) { "jh:bulk_merge:rootgroup-#{group.id}" }

      context 'when has another topic is merging' do
        let(:lease_value) { 'topic::another-topic' }

        before do
          allow(Gitlab::ExclusiveLease).to receive(:get_uuid).with(lease_key).and_return(lease_value)
        end

        it 'returns :cannot_be_merged' do
          expect(service.merge_requests_list_status).to eq(described_class::CANNOT_BE_MERGED)
        end
      end

      context 'when current topic is merging' do
        let(:lease_value) { topic_label_name }

        before do
          allow(Gitlab::ExclusiveLease).to receive(:get_uuid).with(lease_key).and_return(lease_value)
        end

        it 'returns :merging' do
          expect(service.merge_requests_list_status).to eq(described_class::MERGING)
        end
      end
    end

    context 'when all merge requests are merged' do
      let!(:merged_mr1) { create_merged_mr(project1) }
      let!(:merged_mr2) { create_merged_mr(project2) }

      it 'returns :merged' do
        expect(service.merge_requests_list_status).to eq(described_class::MERGED)
      end
    end

    context 'when all merge requests are closed' do
      let!(:merged_mr1) { create_closed_mr(project1) }

      it 'returns :merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CLOSED)
      end
    end

    context 'when all merge requests can be merged' do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }

      it 'returns :can_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CAN_BE_MERGED)
      end
    end

    context 'when has merge request cannot be merged' do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:cannot_be_merge_mr) { create_cannot_be_merge_mr(project2) }

      it 'returns :cannot_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CANNOT_BE_MERGED)
      end
    end

    context "when central pipeline must be successful but it's failed" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :failed,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      before do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::CENTRAL_CI_PIPELINE_MUST_SUCCESS_VARIABLE_KEY,
          value: 'true'
        )
      end

      it 'returns :cannot_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CANNOT_BE_MERGED)
      end
    end

    context "when central pipeline must be successful (value='1') but it's failed" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :failed,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      before do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::CENTRAL_CI_PIPELINE_MUST_SUCCESS_VARIABLE_KEY,
          value: '1'
        )
      end

      it 'returns :cannot_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CANNOT_BE_MERGED)
      end
    end

    context "when central pipeline is failed but does not require success" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :failed,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      let!(:pipeline_variable) do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
      end

      it 'returns :can_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CAN_BE_MERGED)
      end
    end

    context "when central pipeline is pending and must be successful" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :pending,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      before do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::CENTRAL_CI_PIPELINE_MUST_SUCCESS_VARIABLE_KEY,
          value: 'true'
        )
      end

      it 'returns :cannot_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CANNOT_BE_MERGED)
      end
    end

    context "when central pipeline is pending and must be successful (value='1')" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :pending,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      before do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::CENTRAL_CI_PIPELINE_MUST_SUCCESS_VARIABLE_KEY,
          value: '1'
        )
      end

      it 'returns :cannot_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CANNOT_BE_MERGED)
      end
    end

    context "when central pipeline is running and must be successful" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :running,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      before do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::CENTRAL_CI_PIPELINE_MUST_SUCCESS_VARIABLE_KEY,
          value: 'true'
        )
      end

      it 'returns :cannot_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CANNOT_BE_MERGED)
      end
    end

    context "when central pipeline is running and must be successful (value='1')" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :running,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      before do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::CENTRAL_CI_PIPELINE_MUST_SUCCESS_VARIABLE_KEY,
          value: '1'
        )
      end

      it 'returns :cannot_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CANNOT_BE_MERGED)
      end
    end

    context "when central pipeline is pending and does not require success" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :pending,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      before do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
      end

      it 'returns :can_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CAN_BE_MERGED)
      end
    end

    context "when central pipeline is running and does not require success" do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      let!(:pipeline) do
        create(
          :ci_pipeline,
          :running,
          project: ci_central_project,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH
        )
      end

      before do
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
      end

      it 'returns :can_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CAN_BE_MERGED)
      end
    end

    context 'when there is no central pipeline for the topic' do
      let!(:unmerged_mr) { create_unmerged_mr(project1) }
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      it 'returns :can_be_merged' do
        expect(service.merge_requests_list_status).to eq(described_class::CAN_BE_MERGED)
      end
    end
  end

  describe '#has_permission_to_merge?' do
    let(:project1_owner) { create(:user) }
    let(:project2_owner) { create(:user) }
    let(:merged_mr) { create_merged_mr(project1) }
    let(:unmerged_mr) { create_unmerged_mr(project2) }

    before do
      merged_mr.project.add_owner(project1_owner)
      unmerged_mr.project.add_owner(project2_owner)
    end

    it 'returns correct boolean' do
      expect(service.has_permission_to_merge?(group_owner)).to be_truthy
      expect(service.has_permission_to_merge?(project1_owner)).to be_falsey
      expect(service.has_permission_to_merge?(project2_owner)).to be_truthy
    end
  end

  describe '#other_merging_topic_label_name' do
    let(:lease_key) { "jh:bulk_merge:rootgroup-#{group.id}" }

    before do
      allow(Gitlab::ExclusiveLease).to receive(:get_uuid).with(lease_key).and_return(lease_value)
    end

    context 'when has another merging topic' do
      let(:lease_value) { 'topic::another-topic' }

      it 'returns topic name' do
        expect(service.other_merging_topic_label_name).to eq(lease_value)
      end
    end

    context 'when has no another merging topic' do
      let(:lease_value) { nil }

      it 'returns nil' do
        expect(service.other_merging_topic_label_name).to be_nil
      end
    end

    context 'when has same merging topic' do
      let(:lease_value) { topic_label_name }

      it 'returns nil' do
        expect(service.other_merging_topic_label_name).to be_nil
      end
    end
  end

  describe '#head_pipeline' do
    subject(:pipeline) { service.head_pipeline(mr) }

    context 'when merge request has pipeline' do
      let(:mr) { create_mr_with_pipeline(project1) }

      it 'returns head pipeline' do
        expect(pipeline).to eq(mr.head_pipeline)
      end
    end

    context 'when merge request has no pipeline' do
      let(:mr) { create_unmerged_mr(project1) }

      it 'returns nil' do
        expect(pipeline).to be_nil
      end
    end

    context 'when merge request has multiple pipelines' do
      let(:mr1) { create_mr_with_pipeline(project1) }
      let(:mr2) { create_mr_with_pipeline(project2) }

      before do
        mr1.reset
        mr2.reset
      end

      it 'avoids N+1 queries' do
        service.head_pipeline(mr1)

        expect { service.head_pipeline(mr2) }.not_to exceed_query_limit(0)
      end
    end
  end

  describe '#merge_user and #merged_at' do
    context 'when merge requests list has been merged' do
      let!(:merged_mr1) { create_merged_mr(project1) }
      let!(:merged_mr2) { create_merged_mr(project2) }

      it 'returns merged user and time of the last merged mr' do
        last_merge_mr = [merged_mr1, merged_mr2].max_by(&:merged_at)

        expect(service.merge_user).to eq(last_merge_mr.merge_user)
        expect(service.merged_at).to eq(last_merge_mr.merged_at)
      end
    end

    context "when merge requests list has not been merged" do
      let!(:merged_mr) { create_merged_mr(project1) }
      let!(:unmerged_mr) { create_unmerged_mr(project2) }

      it 'returns nil' do
        expect(service.merge_user).to be_nil
        expect(service.merged_at).to be_nil
      end
    end

    context "when all merge requests are closed" do
      let(:topic_label_name) { 'topic::test-closed-mr' }
      let(:topic_label) { create(:group_label, group: group, name: topic_label_name) }
      let(:closed_mr) { create_closed_mr(project1) }
      let(:service) { described_class.new(group, topic_label_name) }

      before do
        closed_mr.metrics.update!(latest_closed_by: group_owner)
        closed_mr.metrics.update!(latest_closed_at: Time.current)
      end

      it 'returns closed user and time of the last closed mr' do
        expect(service.merge_user).to eq(closed_mr.metrics.reset.latest_closed_by)
        expect(service.merged_at).to eq(closed_mr.metrics.reset.latest_closed_at)
      end
    end
  end

  describe '#monorepo_enabled?' do
    using RSpec::Parameterized::TableSyntax

    let_it_be(:topic_label_name) { 'topic::feature-topic' }
    let_it_be(:mr_about_monorepo) { create_unmerged_mr(project1) }
    let_it_be(:mr_without_lable) { create(:merge_request, source_project: project2) }
    let_it_be(:mr_in_personal_namespace) { create_unmerged_mr(create(:project, :private)) }

    where(:self_managed?, :feature_flag_enabled?, :license_flag_enabled?, :mr, :expected_result) do
      true  | true  | true  | ref(:mr_about_monorepo)        | true
      false | true  | true  | ref(:mr_about_monorepo)        | false
      true  | false | true  | ref(:mr_about_monorepo)        | false
      true  | true  | false | ref(:mr_about_monorepo)        | false

      true  | true  | true  | ref(:mr_without_lable)         | false
      true  | true  | true  | ref(:mr_in_personal_namespace) | false
    end

    with_them do
      before do
        stub_feature_flags(ff_monorepo: feature_flag_enabled?)
        stub_licensed_features(monorepo: license_flag_enabled?)
        allow(Gitlab).to receive(:com?).and_return(!self_managed?)
      end

      it 'returns correct boolean' do
        expect(described_class.monorepo_enabled?(mr)).to eq(expected_result)
      end
    end
  end

  describe '#bulk_merge!' do
    let(:lease_key) { service.send(:lease_key) }
    let_it_be(:topic_label_name) { 'topic::feature-topic' }
    let_it_be(:topic_label) { create(:group_label, group: group, name: topic_label_name) }
    let_it_be(:mr1) { create_unmerged_mr(project1) }
    let_it_be(:mr2) { create_unmerged_mr(project2) }

    subject(:bulk_merge) { service.bulk_merge!(group_owner) }

    after do
      Gitlab::ExclusiveLease.cancel(lease_key, topic_label_name)
    end

    context 'when has another topic is merging' do
      before do
        Gitlab::ExclusiveLease.new(lease_key, uuid: 'topic::another-topic', timeout: 60).try_obtain
      end

      after do
        Gitlab::ExclusiveLease.cancel(lease_key, 'topic::another-topic')
      end

      it 'raises error' do
        expect { bulk_merge }.to raise_error(::Gitlab::Access::AccessDeniedError)
      end
    end

    context 'when at least one merge request successfully starts the merge' do
      before do
        merge_requests = service.send(:opened_merge_requests)
        allow(merge_requests[0]).to receive(:merge_async).and_return(true)
        allow(merge_requests[1]).to receive(:merge_async).and_raise(StandardError)
      end

      it 'does not raise error' do
        expect { bulk_merge }.not_to raise_error
      end
    end

    context 'when all merge requests fail to start the merge' do
      before do
        service.send(:opened_merge_requests).each do |mr|
          allow(mr).to receive(:merge_async).and_raise(StandardError)
        end
      end

      it 'raises error and execute "cancel_lease!"' do
        expect_any_instance_of(described_class) do |service|
          expect(service).to receive(:cancel_lease!).and_call_original
        end

        expect { bulk_merge }.to raise_error(described_class::BulkMergeError)
      end
    end
  end

  describe '#ongoing_merge_requests' do
    let!(:mr1) { create_merging_mr(project1) }
    let!(:mr2) { create_unmerged_mr(project2) }

    it 'returns merge requests that are merging' do
      expect(service.ongoing_merge_requests).to contain_exactly(mr1)
    end
  end

  describe '#merge_is_done?' do
    context 'when has no merge request is merging' do
      it 'returns true' do
        allow(service).to receive(:ongoing_merge_requests).and_return([])
        expect(service.merge_is_done?).to be_truthy
      end
    end

    context 'when has merge request is merging' do
      it 'returns false' do
        allow(service).to receive(:ongoing_merge_requests).and_return([double])
        expect(service.merge_is_done?).to be_falsey
      end
    end
  end

  describe '.try_cancel_lease_if_possible!' do
    let!(:merge_request) { create_merged_mr(project1) }
    let(:lease_key) { "jh:bulk_merge:rootgroup-#{group.id}" }
    let(:lease_value) { topic_label_name }

    before do
      Gitlab::ExclusiveLease.new(lease_key, uuid: lease_value, timeout: 60).try_obtain
      stub_licensed_features(monorepo: true)
      allow(Gitlab).to receive(:com?).and_return(false)
    end

    after do
      Gitlab::ExclusiveLease.cancel(lease_key, lease_value)
    end

    it 'cancels lease' do
      expect do
        described_class.try_cancel_lease_if_possible!(merge_request.id)
      end.to change { Gitlab::ExclusiveLease.get_uuid(lease_key) }.from(lease_value).to(false)
    end
  end

  describe '#central_pipeline' do
    context "when there is no 'monorepo-ci-project'" do
      it 'returns nil' do
        expect(service.central_pipeline).to be_nil
      end
    end

    context "when there is 'monorepo-ci-project'" do
      let!(:ci_central_project) do
        create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
      end

      it 'returns pipeline' do
        pipeline_before_mr_created = create(:ci_pipeline, project: ci_central_project, ref: 'main')
        mr = create_merged_mr(project1)
        pipeline = create(:ci_pipeline, project: ci_central_project, ref: 'main')
        mr.metrics.update!(merged_at: Time.now)
        pipeline_on_different_topic = create(:ci_pipeline, project: ci_central_project, ref: 'main')
        pipeline_after_merged = create(:ci_pipeline, project: ci_central_project, ref: 'main')

        create(
          :ci_pipeline_variable,
          pipeline: pipeline_before_mr_created,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline_on_different_topic,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: 'topic::another-topic'
        )
        create(
          :ci_pipeline_variable,
          pipeline: pipeline_after_merged,
          key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: topic_label_name
        )

        expect(service.central_pipeline).to eq(pipeline)
      end
    end
  end

  describe '#trigger_central_pipeline' do
    let!(:ci_central_project) do
      create(:project, :private, group: group, path: described_class::CI_CENTRAL_PROJECT_NAME)
    end

    let(:user) { group_owner }

    subject(:trigger_pipeline) { service.send(:trigger_central_pipeline, user) }

    context 'when ci_central_project exists and user is provided' do
      it 'calls pipeline service with correct parameters and returns result' do
        pipeline_result = instance_double(ServiceResponse, success?: true, payload: instance_double(Ci::Pipeline))
        pipeline_service_double = instance_double(Ci::CreatePipelineService)

        expect(Ci::CreatePipelineService).to receive(:new).with(
          ci_central_project,
          user,
          ref: described_class::CI_CENTRAL_PROJECT_DEFAULT_BRANCH,
          variables_attributes: [
            {
              key: described_class::PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
              value: topic_label_name
            }
          ]
        ).and_return(pipeline_service_double)

        expect(pipeline_service_double).to receive(:execute).with(:api,
          ignore_skip_ci: true).and_return(pipeline_result)

        result = trigger_pipeline
        expect(result).to eq(pipeline_result)
      end
    end

    context 'when ci_central_project is nil' do
      before do
        allow(service).to receive(:ci_central_project).and_return(nil)
      end

      it 'returns early without creating pipeline' do
        expect(Ci::CreatePipelineService).not_to receive(:new)
        expect(trigger_pipeline).to be_nil
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'returns early without creating pipeline' do
        expect(Ci::CreatePipelineService).not_to receive(:new)
        expect(trigger_pipeline).to be_nil
      end
    end

    context 'when pipeline creation service returns an error' do
      it 'does not raise an error' do
        pipeline_service_double = instance_double(Ci::CreatePipelineService)
        allow(Ci::CreatePipelineService).to receive(:new).and_return(pipeline_service_double)
        allow(pipeline_service_double).to receive(:execute).and_return(
          instance_double(ServiceResponse, error?: true, errors: ['Pipeline creation failed'])
        )

        expect { trigger_pipeline }.not_to raise_error
      end
    end
  end

  def create_merged_mr(project)
    create(:merge_request, :merged, source_project: project, merge_user: group_owner, labels: [topic_label])
  end

  def create_closed_mr(project)
    create(:merge_request, :closed, source_project: project, labels: [topic_label])
  end

  def create_unmerged_mr(project)
    create(:merge_request, source_project: project, labels: [topic_label])
  end

  def create_cannot_be_merge_mr(project)
    create(:merge_request, source_project: project, labels: [topic_label], merge_status: :cannot_be_merged)
  end

  def create_mr_without_label(project)
    create(:merge_request, source_project: project, merge_user: group_owner)
  end

  def create_mr_with_another_topic(project)
    create(:merge_request, source_project: project, merge_user: group_owner, labels: ['topic::another-topic'])
  end

  def create_mr_with_pipeline(project)
    mr = create_unmerged_mr(project)
    create(:ci_pipeline, project: project, merge_requests_as_head_pipeline: [mr])
    mr
  end

  def create_merging_mr(project)
    create(:merge_request, source_project: project, labels: [topic_label], state: :locked)
  end
end
