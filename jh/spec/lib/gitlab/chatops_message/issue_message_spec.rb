# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::IssueMessage do
  subject { described_class.new(args) }

  let(:args) do
    {
      markdown: true,
      user: {
        name: 'Test User',
        username: 'test.user',
        avatar_url: 'http://someavatar.com'
      },
      project_name: 'project_name',
      project_url: 'http://somewhere.com',

      object_attributes: {
        title: 'Issue title',
        id: 10,
        iid: 100,
        assignee_id: 1,
        url: 'http://url.com',
        action: 'open',
        state: 'opened',
        description: 'issue description'
      }
    }
  end

  context 'for open' do
    it 'returns a message regarding opening of issues' do
      expect(subject.pretext).to eq('[[project_name](http://somewhere.com)] ' \
        'Issue [#100 Issue title](http://url.com) **Opened** by Test User (test.user)')
      expect(subject.attachments).to eq('issue description')
    end

    it 'returns limit content message' do
      args[:object_attributes][:description] = 'a' * 4000
      expect(subject.pretext).to eq('[[project_name](http://somewhere.com)] ' \
        'Issue [#100 Issue title](http://url.com) **Opened** by Test User (test.user)')
      expect(subject.attachments).to eq('Content length exceeds maximum allowed to display.')
    end
  end

  context 'for close' do
    before do
      args[:object_attributes][:action] = 'close'
      args[:object_attributes][:state] = 'closed'
    end

    it 'returns a message regarding closing of issues' do
      expect(subject.pretext).to eq('[[project_name](http://somewhere.com)] ' \
        'Issue [#100 Issue title](http://url.com) **Closed** by Test User (test.user)')
      expect(subject.attachments).to be_nil
    end
  end

  describe "#template_theme" do
    it 'return success theme' do
      expect(subject.template_theme).to eq Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:success]
    end
  end
end
