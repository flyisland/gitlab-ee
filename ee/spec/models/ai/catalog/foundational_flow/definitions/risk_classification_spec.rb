# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::FoundationalFlow::Definitions::RiskClassification, feature_category: :duo_code_review do
  subject(:flow) { Ai::Catalog::FoundationalFlow.risk_classification_v1 }

  describe '#triggers' do
    it 'runs when a merge request opens and when one becomes ready' do
      expect(flow.triggers).to contain_exactly(
        ::Ai::FlowTrigger::EVENT_TYPES[:merge_request],
        ::Ai::FlowTrigger::EVENT_TYPES[:merge_request_ready]
      )
    end
  end

  describe '#supported_resource_types' do
    it 'accepts merge requests only' do
      expect(flow.supported_resource_types).to eq([::MergeRequest])
    end
  end

  describe '#run_before_start' do
    let_it_be(:project) { create(:project, :repository) }
    let_it_be_with_reload(:merge_request) { create(:merge_request, source_project: project) }

    it 'records a pending assessment, so the widget can tell running from never run' do
      flow.run_before_start(resource: merge_request)

      assessment = merge_request.reload.risk_assessment
      expect(assessment).to be_pending
      expect(assessment.diff_sha).to eq(merge_request.diff_head_sha)
    end

    context 'when an assessment already exists' do
      let(:previous_sha) { Digest::SHA1.hexdigest('older') } # rubocop:disable Fips/SHA1 -- test data

      before do
        create(:merge_requests_risk_assessment, :complete, merge_request: merge_request, diff_sha: previous_sha)
      end

      it 'leaves it alone, so the previous score stays readable until a new one lands' do
        expect { flow.run_before_start(resource: merge_request) }
          .not_to change { MergeRequests::RiskAssessment.count }

        assessment = merge_request.reload.risk_assessment
        expect(assessment.diff_sha).to eq(previous_sha)
        expect(assessment).to be_complete
      end
    end

    it 'ignores a resource that is not a merge request' do
      expect { flow.run_before_start(resource: create(:issue, project: project)) }
        .not_to change { MergeRequests::RiskAssessment.count }
    end
  end
end
