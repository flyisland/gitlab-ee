# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::NoteMessage do
  subject { described_class.new(args) }

  let(:args) do
    {
      markdown: true,
      user: {
        name: 'Test User',
        username: 'test.user',
        avatar_url: 'http://fakeavatar'
      },
      project_name: 'project_name',
      project_url: 'http://somewhere.com',
      repository: {
        name: 'project_name',
        url: 'http://somewhere.com'
      },
      commit: {
        id: '5f163b2b95e6f53cbd428f5f0b103702a52b9a23',
        message: "Added a commit message\ndetails\n123\n"
      },
      object_attributes: {
        id: 10,
        note: 'comment on a commit',
        url: 'http://url.com',
        noteable_type: 'Commit'
      }
    }
  end

  context 'for commit notes' do
    context 'with markdown' do
      it 'returns a message regarding notes on commits' do
        expect(subject.pretext).to eq('Test User (test.user) [commented on commit 5f163b2b](http://url.com) in ' \
          '[project_name](http://somewhere.com): *Added a commit message*')
        expect(subject.attachments).to eq('comment on a commit')
      end

      it 'show content limitation message' do
        args[:object_attributes][:note] = 'a' * 4000
        expect(subject.pretext).to eq('Test User (test.user) [commented on commit 5f163b2b](http://url.com) in ' \
          '[project_name](http://somewhere.com): *Added a commit message*')
        expect(subject.attachments).to eq('Content length exceeds maximum allowed to display.')
      end
    end
  end

  context 'for merge request notes' do
    before do
      args[:object_attributes][:note] = 'comment on a merge request'
      args[:object_attributes][:noteable_type] = 'MergeRequest'
      args[:merge_request] = {
        id: 1,
        iid: 30,
        title: "merge request title\ndetails\n"
      }
    end

    context 'with markdown' do
      it 'returns a message regarding notes on a merge request' do
        expect(subject.pretext).to eq('Test User (test.user) [commented on merge request !30](http://url.com) in ' \
          '[project_name](http://somewhere.com): *merge request title*')
        expect(subject.attachments).to eq('comment on a merge request')
      end
    end
  end

  context 'for issue notes' do
    before do
      args[:object_attributes][:note] = 'comment on an issue'
      args[:object_attributes][:noteable_type] = 'Issue'
      args[:issue] = {
        id: 1,
        iid: 20,
        title: "issue title\ndetails\n"
      }
    end

    context 'with markdown' do
      it 'returns a message regarding notes on an issue' do
        expect(subject.pretext).to eq('Test User (test.user) [commented on issue #20](http://url.com) in ' \
          '[project_name](http://somewhere.com): *issue title*')
        expect(subject.attachments).to eq('comment on an issue')
      end
    end
  end

  context 'for project snippet notes' do
    before do
      args[:object_attributes][:note] = 'comment on a snippet'
      args[:object_attributes][:noteable_type] = 'Snippet'
      args[:snippet] = {
        id: 5,
        title: "snippet title\ndetails\n"
      }
    end

    context 'with markdown' do
      it 'returns a message regarding notes on a project snippet' do
        expect(subject.pretext).to eq('Test User (test.user) [commented on snippet $5](http://url.com) in ' \
          '[project_name](http://somewhere.com): *snippet title*')
        expect(subject.attachments).to eq('comment on a snippet')
      end
    end
  end

  describe "#template_theme" do
    it 'return success theme' do
      expect(subject.template_theme).to eq Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:success]
    end
  end
end
