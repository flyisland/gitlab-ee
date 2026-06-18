# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::UserNotesCountResolver, feature_category: :team_planning do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:user, freeze: false) { create(:user) }
    let_it_be(:project, freeze: false) { create(:project, :repository, :public) }
    let_it_be(:private_project, freeze: false) { create(:project, :repository, :private) }

    specify do
      expect(described_class).to have_nullable_graphql_type(GraphQL::Types::Int)
    end

    context 'when counting notes from an epic' do
      let_it_be(:epic, freeze: false) { create(:epic) }
      let_it_be(:private_epic, freeze: false) { create(:epic, group: create(:group, :private)) }
      let_it_be(:public_notes, freeze: false) { create_list(:note, 2, noteable: epic) }
      let_it_be(:system_note, freeze: false) { create(:note, system: true, noteable: epic) }
      let_it_be(:private_notes, freeze: false) { create_list(:note, 3, noteable: private_epic) }

      context 'when epics feature is available' do
        before do
          stub_licensed_features(epics: true)
        end

        context 'when counting notes from a public epic' do
          subject { batch_sync { resolve_user_notes_count(epic) } }

          it 'returns the number of non-system notes for the epic' do
            expect(subject).to eq(2)
          end

          context 'when not logged in' do
            let(:user) { nil }

            it 'returns the number of non-system notes for the issue' do
              expect(subject).to eq(2)
            end
          end
        end

        context 'when a user does not have permission to view notes' do
          subject { batch_sync { resolve_user_notes_count(private_epic) } }

          it 'generates an error' do
            expect_graphql_error_to_be_created(Gitlab::Graphql::Errors::ResourceNotAvailable) do
              subject
            end
          end
        end

        context 'when a user has permission to view notes' do
          before do
            private_epic.group.add_developer(user)
          end

          subject { batch_sync { resolve_user_notes_count(private_epic) } }

          it 'returns the number of notes for the issue' do
            expect(subject).to eq(3)
          end

          context 'when notes are also added to epic work item side' do
            let_it_be(:work_item, freeze: false) { private_epic.sync_object }
            let_it_be(:public_notes, freeze: false) { create_list(:note, 2, noteable: work_item) }
            let_it_be(:system_note, freeze: false) { create(:note, system: true, noteable: work_item) }
            let_it_be(:private_notes, freeze: false) { create_list(:note, 3, noteable: work_item) }

            it 'returns the number of notes for the issue' do
              # 3 user notes from epic, 5 user notes from epic work item
              expect(subject).to eq(3 + 5)
            end
          end
        end
      end
    end
  end

  def resolve_user_notes_count(obj)
    resolve(described_class, obj: obj, ctx: { current_user: user })
  end
end
