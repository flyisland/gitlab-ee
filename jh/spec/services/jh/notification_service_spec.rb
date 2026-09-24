# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NotificationService, feature_category: :integrations do
  let_it_be(:project) { create(:project, :private) }
  let_it_be(:author) { create(:user) }
  let_it_be(:participant) { create(:user) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project, author: participant) }
  let_it_be(:note) { create(:note_on_merge_request, project: project, noteable: merge_request, author: author) }

  before_all do
    project.add_developer(author)
    project.add_developer(participant)
  end

  before do
    allow(::Gitlab::Wecom::App).to receive(:notifications_available?).and_return(true)
  end

  describe '#mailer' do
    it 'stands in for the mailer so every notification reaches WeCom' do
      expect(described_class.new.mailer).to be_a(::Gitlab::Wecom::MailerFanout)
    end

    it 'leaves the mailer alone while WeCom delivery is unavailable' do
      allow(::Gitlab::Wecom::App).to receive(:notifications_available?).and_return(false)

      expect(described_class.new.mailer).to be(Notify)
    end
  end

  # The seam is on the mailer, so this holds for every notification rather than
  # only the one exercised here.
  describe 'dispatching a notification' do
    it 'queues a WeCom notification alongside the email' do
      expect(Wecom::SendNotificationWorker).to receive(:perform_async)
        .with('note_merge_request_email', anything, anything).at_least(:once)

      described_class.new.new_note(note)
    end

    it 'still sends the email' do
      expect(Notify).to receive(:note_merge_request_email).at_least(:once).and_call_original

      described_class.new.new_note(note)
    end

    it 'sends no WeCom notification while delivery is unavailable' do
      allow(::Gitlab::Wecom::App).to receive(:notifications_available?).and_return(false)

      expect(Wecom::SendNotificationWorker).not_to receive(:perform_async)

      described_class.new.new_note(note)
    end
  end
end
