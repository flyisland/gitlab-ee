# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::SyncFindingEnrichmentWorker, feature_category: :security_policy_management do
  let_it_be(:project) { create(:project) }

  let(:worker) { described_class.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    shared_examples_for 'returns early without loading security policies' do
      it 'returns early without loading security policies' do
        expect(Security::Policy).not_to receive(:type_approval_policy)

        perform
      end
    end

    context 'when security_orchestration_policies feature is not available' do
      before do
        stub_licensed_features(security_orchestration_policies: false)
      end

      it_behaves_like 'returns early without loading security policies'
    end

    context 'when security_orchestration_policies feature is available' do
      before do
        stub_licensed_features(security_orchestration_policies: true)
      end

      context 'when in development environment without PM_SYNC_IN_DEV' do
        before do
          allow(Rails.env).to receive(:development?).and_return(true)
          allow(ENV).to receive(:fetch).with('PM_SYNC_IN_DEV', 'false').and_return('false')
        end

        it_behaves_like 'returns early without loading security policies'
      end

      shared_examples_for 'returns early without upserting Security::FindingEnrichment' do
        it 'returns early without upserting Security::FindingEnrichment' do
          expect(Security::FindingEnrichment).not_to receive(:upsert_all)

          perform
        end
      end

      context 'when there is no security finding enrichment records' do
        it_behaves_like 'returns early without upserting Security::FindingEnrichment'
      end

      context 'when there are security finding enrichment records' do
        let_it_be(:cve_enrichment) { create(:pm_cve_enrichment) }
        let_it_be(:finding) { create(:security_finding, project_id: project.id) }
        let_it_be(:finding_with_enrichment) do
          create(:security_finding_enrichment,
            project: project,
            updated_at: 2.hours.ago,
            finding_uuid: finding.uuid,
            cve_enrichment: cve_enrichment)
        end

        let(:finding_attributes) do
          {
            project_id: project.id,
            finding_uuid: finding.uuid,
            cve_enrichment_id: cve_enrichment.id,
            cve: cve_enrichment.cve,
            epss_score: cve_enrichment.epss_score,
            is_known_exploit: cve_enrichment.is_known_exploit
          }
        end

        shared_examples_for 'upserts finding enrichments' do
          it 'upserts finding enrichments' do
            expect(Security::FindingEnrichment)
              .to receive(:upsert_all)
              .with([finding_attributes],
                unique_by: %i[finding_uuid cve],
                returning: [:project_id])
              .and_call_original

            perform
          end
        end

        shared_examples_for 'it does not update merge request approvals' do
          it 'does not enqueues SyncMergeRequestsWorker' do
            expect(Security::SyncMergeRequestsWorker).not_to receive(:perform_async)

            perform
          end
        end

        shared_examples_for 'it updates merge request approvals' do
          it 'enqueues SyncMergeRequestsWorker with the correct arguments' do
            expect(Security::SyncMergeRequestsWorker).to receive(:perform_async).with(project.id, policy.id)

            perform
          end
        end

        context 'when there are no policies with enrichment filters' do
          it_behaves_like 'upserts finding enrichments'
          it_behaves_like 'it does not update merge request approvals'
        end

        context 'when there are policies with enrichment filters' do
          let_it_be(:policy) { create(:security_policy, :approval_policy, enabled: true, linked_projects: [project]) }
          let_it_be(:approval_policy_rule) do
            create(:approval_policy_rule, :scan_finding_with_enrichment_filters, security_policy: policy)
          end

          it_behaves_like 'upserts finding enrichments'
          it_behaves_like 'it updates merge request approvals'

          context 'when the policy is disabled' do
            before do
              Security::Policy.update_all(enabled: false)
            end

            it_behaves_like 'upserts finding enrichments'
            it_behaves_like 'it does not update merge request approvals'
          end

          context 'when the FindingEnrichment upserts does not update any record' do
            before do
              allow(Security::FindingEnrichment).to receive(:upsert_all)
                .and_return(ActiveRecord::Result.new(['project_id'], []))
            end

            it_behaves_like 'it does not update merge request approvals'
          end

          context 'when project has multiple policies with enrichment filters' do
            let_it_be(:other_policy) do
              create(:security_policy, :approval_policy, enabled: true, linked_projects: [project])
            end

            let_it_be(:other_approval_policy_rule) do
              create(:approval_policy_rule, :scan_finding_with_enrichment_filters, security_policy: other_policy)
            end

            it_behaves_like 'upserts finding enrichments'

            it 'updates MR Approvals for all policies' do
              [policy, other_policy].each do |security_policy|
                expect(Security::SyncMergeRequestsWorker).to receive(:perform_async).with(project.id,
                  security_policy.id)
              end

              perform
            end
          end
        end
      end
    end
  end
end
