# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::PushMessage do
  subject(:push_message) { described_class.new(args) }

  let(:args) do
    {
      markdown: true,
      after: 'after',
      before: 'before',
      project_name: 'project_name',
      ref: 'refs/heads/master',
      user_name: 'test.user',
      user_avatar: 'http://someavatar.com',
      project_url: 'http://url.com'
    }
  end

  let(:color) { '#345' }

  context 'for push' do
    before do
      args[:commits] = [
        { message: 'message1', title: 'message1', url: 'http://url1.com', id: 'abc', author: { name: 'author1' } },
        {
          message: "message2#{' w' * 100}\nsecondline",
          title: 'message2 w w w w w w w w w w w w w w w w w w w w w w w w w w w w w w w w w w ...',
          url: 'http://url2.com',
          id: '123456789012',
          author: { name: 'author2' }
        },
        { message: 'message3', title: 'message3', url: 'http://url3.com', id: 'abc3', author: { name: 'author1' } },
        { message: 'message4', title: 'message4', url: 'http://url4.com', id: 'abc4', author: { name: 'author1' } },
        { message: 'message5', title: 'message5', url: 'http://url5.com', id: 'abc5', author: { name: 'author1' } },
        { message: 'message6', title: 'message6', url: 'http://url6.com', id: 'abc6', author: { name: 'author1' } }
      ]
    end

    context 'with markdown' do
      it 'returns a message regarding pushes' do
        expect(push_message.pretext).to eq('test.user pushed to branch [master](http://url.com/-/commits/master) of ' \
          '[project_name](http://url.com) ' \
          '([Compare changes](http://url.com/-/compare/before...after))')
        expect(push_message.attachments).to eq("[abc](http://url1.com): message1 - author1\n" \
          "[12345678](http://url2.com): message2 w w w w w w w w w w w w w w w " \
          "w w w w w w w w w w w w w w w w w w w ... - author2\n" \
          "[abc3](http://url3.com): message3 - author1\n" \
          "[abc4](http://url4.com): message4 - author1\n" \
          "[abc5](http://url5.com): message5 - author1\n" \
          "At most 5 commits of the merge request are listed for your reference.")
      end
    end
  end

  context 'for tag push' do
    let(:args) do
      {
        markdown: true,
        after: 'after',
        before: Gitlab::Git::SHA1_BLANK_SHA,
        project_name: 'project_name',
        ref: 'refs/tags/new_tag',
        user_name: 'test.user',
        user_avatar: 'http://someavatar.com',
        project_url: 'http://url.com'
      }
    end

    context 'with markdown' do
      it 'returns a message regarding pushes' do
        expect(push_message.pretext).to eq('test.user pushed new Tag [new_tag](http://url.com/-/tags/new_tag) ' \
          'to [project_name](http://url.com)')
        expect(push_message.attachments).to be_empty
      end
    end
  end

  context 'for removed tag' do
    let(:args) do
      {
        markdown: true,
        after: Gitlab::Git::SHA1_BLANK_SHA,
        before: 'before',
        project_name: 'project_name',
        ref: 'refs/tags/new_tag',
        user_name: 'test.user',
        user_avatar: 'http://someavatar.com',
        project_url: 'http://url.com'
      }
    end

    context 'with markdown' do
      it 'returns a message regarding removal of tags' do
        expect(push_message.pretext).to eq('test.user removed Tag new_tag from [project_name](http://url.com)')
        expect(push_message.attachments).to be_empty
      end
    end
  end

  context 'for new branch' do
    before do
      args[:before] = Gitlab::Git::SHA1_BLANK_SHA
    end

    context 'with markdown' do
      it 'returns a message regarding a new branch' do
        expect(push_message.pretext).to eq('test.user pushed new branch [master](http://url.com/-/commits/master) ' \
          'to [project_name](http://url.com)')
        expect(push_message.attachments).to be_empty
      end
    end
  end

  context 'for removed branch' do
    before do
      args[:after] = Gitlab::Git::SHA1_BLANK_SHA
    end

    context 'with markdown' do
      it 'returns a message regarding a removed branch' do
        expect(push_message.pretext).to eq('test.user removed branch master from [project_name](http://url.com)')
        expect(push_message.attachments).to be_empty
      end
    end
  end

  describe "#template_theme" do
    it 'return success theme' do
      expect(push_message.template_theme).to eq Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:success]
    end
  end
end
