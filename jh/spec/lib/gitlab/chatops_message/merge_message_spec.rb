# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::MergeMessage do
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
        title: "Merge request title\nSecond line",
        id: 10,
        iid: 100,
        assignee_id: 1,
        url: 'http://url.com',
        state: 'opened',
        action: 'open',
        description: 'merge request description',
        source_branch: 'source_branch',
        target_branch: 'target_branch'
      }
    }
  end

  context 'with markdown' do
    context 'for open' do
      it 'returns a message regarding opening of merge requests' do
        expect(subject.pretext).to eq('Test User (test.user) Opened merge request [!100 *Merge request title*](http:' \
          '//somewhere.com/-/merge_requests/100) in [project_name](http://somewhere.com)')
        expect(subject.attachments).to be_empty
      end
    end

    context 'for close' do
      before do
        args[:object_attributes][:state] = 'closed'
        args[:object_attributes][:action] = 'close'
      end

      it 'returns a message regarding closing of merge requests' do
        expect(subject.pretext).to eq('Test User (test.user) Closed merge request [!100 *Merge request title*](http:' \
          '//somewhere.com/-/merge_requests/100) in [project_name](http://somewhere.com)')
        expect(subject.attachments).to be_empty
      end
    end
  end

  context 'for approved' do
    before do
      args[:object_attributes][:action] = 'approved'
    end

    it 'returns a message regarding completed approval of merge requests' do
      expect(subject.pretext).to eq('Test User (test.user) Approved merge request [!100 *Merge request title*](' \
        'http://somewhere.com/-/merge_requests/100) in [project_name](http://somewhere' \
        '.com)')
      expect(subject.attachments).to be_empty
    end
  end

  context 'for unapproved' do
    before do
      args[:object_attributes][:action] = 'unapproved'
    end

    it 'returns a message regarding revocation of completed approval of merge requests' do
      expect(subject.pretext).to eq('Test User (test.user) unapproved merge request [!100 *Merge request title*](' \
        'http://somewhere.com/-/merge_requests/100) in [project_name](http://somewhere' \
        '.com)')
      expect(subject.attachments).to be_empty
    end
  end

  context 'for approval' do
    before do
      args[:object_attributes][:action] = 'approval'
    end

    it 'returns a message regarding added approval of merge requests' do
      expect(subject.pretext).to eq('Test User (test.user) added their approval to merge request [!100 *Merge ' \
        'request title*](http://somewhere.com/-/merge_requests/100) in ' \
        '[project_name](http://somewhere.com)')
      expect(subject.attachments).to be_empty
    end
  end

  context 'for unapproval' do
    before do
      args[:object_attributes][:action] = 'unapproval'
    end

    it 'returns a message regarding revoking approval of merge requests' do
      expect(subject.pretext).to eq('Test User (test.user) removed their approval from merge request [!100 *Merge ' \
        'request title*](http://somewhere.com/-/merge_requests/100) in ' \
        '[project_name](http://somewhere.com)')
      expect(subject.attachments).to be_empty
    end
  end

  describe "#template_theme" do
    using RSpec::Parameterized::TableSyntax

    where(:status, :theme) do
      'unapproval' | :error
      'unapproved' | :error
      'close' | :cancel
      'lock' | :warning
      'approved' | :success
    end

    with_them do
      it "return corresponding theme" do
        args[:object_attributes][:action] = status

        expect(subject.template_theme).to eq(Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[theme])
      end
    end
  end
end
