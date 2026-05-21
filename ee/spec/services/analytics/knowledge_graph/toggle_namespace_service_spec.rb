# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph::ToggleNamespaceService, feature_category: :knowledge_graph do
  let_it_be(:group) { create(:group) }
  let_it_be(:owner) { create(:user, owner_of: group) }

  describe '#execute' do
    subject(:result) { described_class.new(group: group, current_user: owner, enabled: enabled).execute }

    before do
      stub_saas_features(gitlab_com_subscriptions: true)
      stub_licensed_features(orbit: true)
    end

    context 'when user is not authorized' do
      let_it_be(:developer) { create(:user, developer_of: group) }
      let(:enabled) { true }

      subject(:result) { described_class.new(group: group, current_user: developer, enabled: enabled).execute }

      it 'returns a forbidden error' do
        expect(result).to be_error
        expect(result.reason).to eq(:forbidden)
      end
    end

    context 'when enabling' do
      let(:enabled) { true }

      it 'creates an enabled namespace record' do
        expect { result }.to change { Analytics::KnowledgeGraph::EnabledNamespace.count }.by(1)
        expect(result).to be_success
        expect(result[:group]).to eq(group)
      end

      context 'when already enabled' do
        before do
          create(:knowledge_graph_enabled_namespace, namespace: group)
        end

        it 'is idempotent' do
          expect { result }.not_to change { Analytics::KnowledgeGraph::EnabledNamespace.count }
          expect(result).to be_success
        end
      end

      context 'when a concurrent request creates the record first' do
        it 'handles the race condition gracefully' do
          allow_next_instance_of(Analytics::KnowledgeGraph::EnabledNamespace) do |record|
            allow(record).to receive(:save).and_wrap_original do |_method, *_args|
              raise ActiveRecord::RecordNotUnique
            end
          end

          expect(result).to be_success
        end
      end
    end

    context 'when disabling' do
      let(:enabled) { false }

      context 'when currently enabled' do
        before do
          create(:knowledge_graph_enabled_namespace, namespace: group)
        end

        it 'removes the enabled namespace record' do
          expect { result }.to change { Analytics::KnowledgeGraph::EnabledNamespace.count }.by(-1)
          expect(result).to be_success
        end
      end

      context 'when already disabled' do
        it 'is idempotent' do
          expect { result }.not_to change { Analytics::KnowledgeGraph::EnabledNamespace.count }
          expect(result).to be_success
        end
      end

      context 'when destroy fails' do
        before do
          record = create(:knowledge_graph_enabled_namespace, namespace: group)
          allow(record).to receive(:destroy).and_return(false)
          record.errors.add(:base, 'could not be removed')
          allow(group).to receive(:knowledge_graph_enabled_namespace).and_return(record)
        end

        it 'returns an error' do
          expect(result).to be_error
          expect(result.message).to eq('could not be removed')
        end
      end
    end

    context 'when group is not a root namespace' do
      let_it_be(:subgroup) { create(:group, parent: group) }
      let(:enabled) { true }

      subject(:result) do
        described_class.new(group: subgroup, current_user: owner, enabled: enabled).execute
      end

      it 'returns an authorization error' do
        expect(result).to be_error
        expect(result.reason).to eq(:forbidden)
      end
    end
  end
end
