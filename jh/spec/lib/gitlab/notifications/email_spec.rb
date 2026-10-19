# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Notifications::Email, feature_category: :integrations do
  let_it_be(:user, reload: true) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:issue, reload: true) { create(:issue, project: project) }
  let_it_be(:note, reload: true) do
    create(:note_on_issue, project: project, noteable: issue, note: 'Private comment body')
  end

  let(:event) { 'note_issue_email' }
  let(:args) { [user.id, note.id, NotificationReason::MENTIONED] }
  let(:email) { described_class.render(event, ActiveJob::Arguments.serialize(args), {}) }

  shared_examples 'a confidential card source' do
    it 'keeps only the title and link #security' do
      expect(email).to be_present
      expect(email.attributes).to include(
        title: a_kind_of(String), url: a_string_starting_with('http'),
        project: nil, reason: nil, excerpt: nil
      )
    end
  end

  it 'includes context and excerpt for ordinary comments' do
    expect(email.attributes).to include(
      project: project.name, reason: NotificationReason::MENTIONED, excerpt: a_string_including(note.note)
    )
  end

  context 'with an internal comment on an ordinary issue' do
    before do
      note.update!(internal: true)
    end

    it_behaves_like 'a confidential card source'
  end

  context 'with a confidential comment on an ordinary issue' do
    let(:note) { create(:note_on_issue, :confidential, project: project, noteable: issue) }

    it_behaves_like 'a confidential card source'
  end

  context 'with a confidential issue' do
    before do
      issue.update!(confidential: true)
    end

    it_behaves_like 'a confidential card source'
  end

  describe 'reassignment notifications' do
    let_it_be(:new_assignee) { create(:user, name: 'New Assignee') }
    let_it_be(:previous_assignee) { create(:user, name: 'Old Assignee') }

    let(:current_assignees) { [new_assignee] }
    let(:previous_assignee_ids) { [previous_assignee.id] }
    let(:args) { [user.id, issuable.id, previous_assignee_ids, user.id, nil] }

    before_all do
      project.add_developer(user)
      project.add_developer(new_assignee)
      project.add_developer(previous_assignee)
    end

    before do
      issuable.update!(assignees: current_assignees)
    end

    shared_examples 'an assignee change summary' do
      it 'drops the generic heading so the localized assignee change survives' do
        expected = Gitlab::I18n.with_user_locale(user) { expected_excerpt }

        expect(email.attributes[:excerpt]).to eq(expected)
      end
    end

    shared_examples 'reassignment summaries' do
      let(:expected_excerpt) do
        [
          format(s_('Notify|%{added} was added as an assignee.'), added: new_assignee.name),
          format(s_('Notify|%{removed} was removed as an assignee.'), removed: previous_assignee.name)
        ].join(' ')
      end

      it_behaves_like 'an assignee change summary'

      context 'when assigning for the first time' do
        let(:previous_assignee_ids) { [] }
        let(:expected_excerpt) { format(s_('Notify|%{added} was added as an assignee.'), added: new_assignee.name) }

        it_behaves_like 'an assignee change summary'
      end

      context 'when removing one of multiple assignees' do
        let(:previous_assignee_ids) { [previous_assignee.id, new_assignee.id] }
        let(:expected_excerpt) do
          format(s_('Notify|%{removed} was removed as an assignee.'), removed: previous_assignee.name)
        end

        it_behaves_like 'an assignee change summary'
      end

      context 'when removing all assignees' do
        let(:current_assignees) { [] }
        let(:expected_excerpt) { s_('Notify|All assignees were removed.') }

        it_behaves_like 'an assignee change summary'
      end

      context 'when the recipient prefers Chinese' do
        before do
          user.update!(preferred_language: 'zh_CN')
        end

        it_behaves_like 'an assignee change summary'
      end
    end

    context 'for an issue' do
      let_it_be(:issuable, reload: true) { create(:issue, project: project) }
      let(:event) { 'reassigned_issue_email' }

      it_behaves_like 'reassignment summaries'
    end

    context 'for a merge request' do
      let_it_be(:issuable, reload: true) { create(:merge_request, source_project: project) }
      let(:event) { 'reassigned_merge_request_email' }

      it_behaves_like 'reassignment summaries'
    end
  end

  context 'with a confidential epic' do
    let_it_be(:epic, refind: true) { create(:epic, :confidential) }
    let(:event) { 'new_epic_email' }
    let(:args) { [user.id, epic.id] }

    before do
      stub_licensed_features(epics: true)
    end

    it_behaves_like 'a confidential card source'

    context 'with a comment notification' do
      let(:epic_note) { create(:note, noteable: epic, project: nil) }
      let(:event) { 'note_epic_email' }
      let(:args) { [user.id, epic_note.id, NotificationReason::MENTIONED] }

      it_behaves_like 'a confidential card source'
    end
  end
end
