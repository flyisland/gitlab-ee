# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Findings::FindingDueDates::BulkSetDueDatesService,
  feature_category: :vulnerability_management do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:project) { create(:project) }
  let_it_be(:finding1) { create(:vulnerabilities_finding, project: project) }
  let_it_be(:finding2) { create(:vulnerabilities_finding, project: project) }
  let_it_be(:user) { create(:user, maintainer_of: project) }

  let(:due_date) { 10.days.from_now.to_date }

  before do
    stub_licensed_features(security_dashboard: true)
  end

  def execute(updates:, current_user: user)
    described_class.new(project: project, updates: updates, current_user: current_user).execute
  end

  def build_updates(uuids, date: due_date)
    uuids.map { |uuid| { finding_uuid: uuid, due_date: date } }
  end

  describe '#execute' do
    context 'for success' do
      it 'creates due date' do
        result = nil

        expect { result = execute(updates: build_updates([finding1.uuid])) }
          .to change { Vulnerabilities::FindingDueDate.count }.by(1)

        expect(result).to be_success
        expect(result.payload).to eq(assigned: 1, removed: 0, skipped: 0, errors: [])
      end

      it 'deletes due date' do
        create(:vulnerability_finding_due_date, finding: finding1, project: project, due_date: Date.current)

        result = nil

        expect { result = execute(updates: build_updates([finding1.uuid], date: nil)) }
          .to change { Vulnerabilities::FindingDueDate.count }.by(-1)

        expect(result.payload).to eq(assigned: 0, removed: 1, skipped: 0, errors: [])
      end

      it 'ignores missing findings' do
        result = nil

        expect { result = execute(updates: build_updates([finding1.uuid, 'missing'])) }
          .to change { Vulnerabilities::FindingDueDate.count }.by(1)

        expect(result.payload[:assigned]).to eq(1)
        expect(result.payload[:removed]).to eq(0)
        expect(result.payload[:skipped]).to eq(1)
        expect(result.payload[:errors]).to contain_exactly(
          hash_including(uuid: 'missing', code: :not_found)
        )
      end

      it 'returns empty when nothing matches' do
        result = execute(updates: build_updates([SecureRandom.uuid]))

        expect(result.payload[:assigned]).to eq(0)
        expect(result.payload[:removed]).to eq(0)
        expect(result.payload[:skipped]).to eq(1)
        expect(result.payload[:errors].size).to eq(1)
      end

      it 'returns empty for nil updates' do
        expect(execute(updates: nil).payload).to eq(assigned: 0, removed: 0, skipped: 0, errors: [])
      end

      context 'for empty batch branches' do
        it 'does not call delete when there are only upserts' do
          result = nil

          expect(Vulnerabilities::FindingDueDate).not_to receive(:by_finding_ids)

          expect { result = execute(updates: build_updates([finding1.uuid])) }
            .to change { Vulnerabilities::FindingDueDate.count }.by(1)

          expect(result.payload).to eq(assigned: 1, removed: 0, skipped: 0, errors: [])
        end

        it 'does not call upsert when there are only deletes' do
          create(:vulnerability_finding_due_date, finding: finding1, project: project, due_date: Date.current)

          result = nil

          expect(Vulnerabilities::FindingDueDate).not_to receive(:upsert_all)

          expect { result = execute(updates: build_updates([finding1.uuid], date: nil)) }
            .to change { Vulnerabilities::FindingDueDate.count }.by(-1)

          expect(result.payload).to eq(assigned: 0, removed: 1, skipped: 0, errors: [])
        end
      end
    end

    context 'for conflicts' do
      it 'last write wins' do
        updates = [
          { finding_uuid: finding1.uuid, due_date: 1.day.from_now.to_date },
          { finding_uuid: finding1.uuid, due_date: due_date }
        ]

        execute(updates: updates)

        expect(
          Vulnerabilities::FindingDueDate.find_by(vulnerability_occurrence_id: finding1.id).due_date
        ).to eq(due_date)
      end

      it 'handles duplicate uuids' do
        expect { execute(updates: build_updates([finding1.uuid, finding1.uuid])) }
          .not_to raise_error

        expect(Vulnerabilities::FindingDueDate.count).to eq(1)
      end
    end

    context 'for validation errors' do
      where(:invalid) { ['not-a-date', '2024-13-01', '2024-02-30', '', 123, Object.new] }

      with_them do
        it 'returns error for invalid due_date' do
          result = execute(updates: build_updates([finding1.uuid], date: invalid))

          expect(result).to be_success
          expect(result.payload[:errors]).to contain_exactly(
            hash_including(
              uuid: finding1.uuid,
              code: :invalid_due_date,
              message: include(invalid.to_s)
            )
          )
        end
      end

      it 'returns error for foreign finding' do
        foreign = create(:vulnerabilities_finding, project: create(:project))

        result = execute(updates: build_updates([foreign.uuid]))

        expect(result).to be_success
        expect(result.payload[:skipped]).to eq(1)
        expect(result.payload[:errors]).to contain_exactly(hash_including(uuid: foreign.uuid, code: :not_found))
      end

      it 'returns multiple errors' do
        foreign = create(:vulnerabilities_finding, project: create(:project))
        missing = SecureRandom.uuid
        invalid = 'not-a-date'

        updates = [
          { finding_uuid: foreign.uuid, due_date: due_date },
          { finding_uuid: missing, due_date: due_date },
          { finding_uuid: finding1.uuid, due_date: invalid }
        ]

        result = execute(updates: updates)

        expect(result).to be_success

        expect(result.payload[:errors].pluck(:uuid))
          .to contain_exactly(foreign.uuid, missing, finding1.uuid)

        expect(result.payload[:errors].pluck(:code))
          .to contain_exactly(:not_found, :not_found, :invalid_due_date)
      end
    end

    context 'for authorization' do
      let(:updates) { build_updates([finding1.uuid]) }

      it 'rejects unauthorized user' do
        expect { execute(updates: updates, current_user: create(:user)) }
          .to raise_error(Gitlab::Access::AccessDeniedError)
      end

      it 'rejects when feature disabled' do
        stub_feature_flags(vulnerability_finding_set_due_dates_api: false)

        expect { execute(updates: updates) }
          .to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
  end
end
