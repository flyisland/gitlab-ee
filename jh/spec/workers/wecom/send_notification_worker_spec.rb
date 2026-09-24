# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wecom::SendNotificationWorker, feature_category: :integrations do
  let_it_be(:project, reload: true) { create(:project, :private) }
  let_it_be(:recipient, reload: true) { create(:user) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:note, reload: true) { create(:note_on_issue, project: project, noteable: issue) }

  let(:client) { instance_double(Gitlab::Wecom::AppClient) }
  let(:result) { Gitlab::Wecom::AppClient::Result.new(message_id: 'MSG-1', invalid_user_ids: []) }
  let(:event) { 'note_issue_email' }
  let(:args) { ActiveJob::Arguments.serialize([recipient.id, note.id, nil]) }
  let(:kwargs) { ActiveJob::Arguments.serialize([{}]).first }

  before_all do
    project.add_developer(recipient)
  end

  before do
    create(:identity, user: recipient, provider: 'wecom', extern_uid: 'ww_corp:zhangsan')
    ::JH::Users::WecomNotification.set(recipient, true)

    allow(Gitlab::Wecom::App).to receive_messages(notifications_available?: true, corp_id: 'ww_corp')
    allow(Gitlab::Wecom::AppClient).to receive(:new).and_return(client)
    allow(client).to receive(:send_card).and_return(result)
  end

  def run
    described_class.new.perform(event, args, kwargs)
  end

  it 'sends the card to the bound WeCom account' do
    expect(client).to receive(:send_card).with(['zhangsan'], a_kind_of(Hash)).and_return(result)

    run
  end

  # The card is taken from the email itself, so it says whatever the recipient's
  # own notification said, less the threading prefix that only email needs.
  it 'titles the card with the email subject' do
    subject_line = Notify.note_issue_email(recipient.id, note.id).subject

    expect(client).to receive(:send_card) do |_ids, card|
      expect(subject_line).to end_with(card[:main_title][:title])
      expect(card[:main_title][:title]).to include(issue.title).and(exclude('Re: '))
      result
    end

    run
  end

  # The link comes from the email's own "View it on GitLab" target, so it is as
  # precise as the email is: it lands on the comment, not just the project.
  it 'links the card back to the note' do
    expect(client).to receive(:send_card) do |_ids, card|
      expect(card[:card_action][:url]).to include(project.full_path).and include("#note_#{note.id}")
      result
    end

    run
  end

  # The subject is the same for every notification on this issue, so the card
  # leans on the reason the email carried to tell them apart.
  it 'carries the notification reason from the email' do
    expect(client).to receive(:send_card) do |_ids, card|
      expect(card[:horizontal_content_list]).to include(hash_including(keyname: 'Reason'))
      result
    end

    described_class.new.perform(
      event, ActiveJob::Arguments.serialize([recipient.id, note.id, NotificationReason::MENTIONED]), kwargs
    )
  end

  # Same wording as the email, for every event at once.
  it 'quotes the notification body' do
    note.update!(note: 'Looks good to me')

    expect(client).to receive(:send_card) do |_ids, card|
      expect(card[:quote_area][:quote_text]).to include('Looks good to me')
      expect(card[:quote_area][:quote_text]).not_to include('http')
      result
    end

    run
  end

  describe 'reassignment notifications' do
    let_it_be(:new_assignee) { create(:user, name: 'New Assignee') }
    let_it_be(:previous_assignee) { create(:user, name: 'Old Assignee') }

    let(:current_assignees) { [new_assignee] }
    let(:previous_assignee_ids) { [previous_assignee.id] }
    let(:args) do
      ActiveJob::Arguments.serialize([recipient.id, issuable.id, previous_assignee_ids, recipient.id, nil])
    end

    before do
      issuable.update!(assignees: current_assignees)
    end

    shared_examples 'an assignee change summary' do
      it 'quotes the assignee changes without the reassignment heading' do
        expect(client).to receive(:send_card) do |_ids, card|
          expected = Gitlab::I18n.with_user_locale(recipient) { expected_excerpt }
          expect(card[:quote_area][:quote_text]).to eq(expected)
          result
        end

        run
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
          recipient.update!(preferred_language: 'zh_CN')
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

  # The card leaves the instance for a third party, so a confidential
  # discussion travels as a title and a link only.
  it 'quotes nothing from a confidential discussion' do
    confidential = create(:issue, :confidential, project: project)
    hidden = create(:note_on_issue, project: project, noteable: confidential, note: 'internal only')

    expect(client).to receive(:send_card) do |_ids, card|
      expect(card).not_to have_key(:quote_area)
      expect(card.to_s).not_to include('internal only')
      result
    end

    described_class.new.perform(event, ActiveJob::Arguments.serialize([recipient.id, hidden.id, nil]), kwargs)
  end

  it 'does nothing while WeCom delivery is unavailable' do
    allow(Gitlab::Wecom::App).to receive(:notifications_available?).and_return(false)

    expect(client).not_to receive(:send_card)

    run
  end

  it 'does nothing for a member who has not opted in' do
    ::JH::Users::WecomNotification.set(recipient, false)

    expect(client).not_to receive(:send_card)

    run
  end

  it 'does nothing for a member with no bound WeCom account' do
    recipient.identities.with_provider('wecom').delete_all

    expect(client).not_to receive(:send_card)

    run
  end

  # A notification whose subject was deleted between queueing and delivery
  # renders nothing. Retrying would not bring it back.
  it 'drops a notification it can no longer render' do
    deleted = create(:note_on_issue, project: project, noteable: issue)
    deleted_args = ActiveJob::Arguments.serialize([recipient.id, deleted.id, nil])
    deleted.destroy!

    expect(client).not_to receive(:send_card)
    expect { described_class.new.perform(event, deleted_args, kwargs) }.not_to raise_error
  end

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { [event, args, kwargs] }
  end
end
