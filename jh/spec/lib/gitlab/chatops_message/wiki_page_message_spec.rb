# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::WikiPageMessage do
  subject { described_class.new(args) }

  let(:name) { 'Test User' }
  let(:username) { 'test.user' }
  let(:avatar_url) { 'http://someavatar.com' }
  let(:project_name) { 'project_name' }
  let(:project_url) { 'http://somewhere.com' }
  let(:url) { 'http://url.com' }
  let(:diff_url) { 'http://url.com/diff?version_id=1234' }
  let(:wiki_page_title) { 'Wiki page title' }
  let(:commit_message) { 'Wiki page commit message' }
  let(:args) do
    {
      markdown: true,
      user: {
        name: name,
        username: username,
        avatar_url: avatar_url
      },
      project_name: project_name,
      project_url: project_url,
      object_attributes: {
        title: wiki_page_title,
        url: url,
        content: 'Wiki page content',
        message: commit_message,
        diff_url: diff_url
      }
    }
  end

  context 'with markdown' do
    describe '#pretext' do
      context 'when :action == "create"' do
        before do
          args[:object_attributes][:action] = 'create'
        end

        it 'returns a message that a new wiki page was created' do
          expect(subject.pretext).to eq("#{name} (#{username}) Created [wiki page](#{url}) ([Compare changes]" \
            "(#{diff_url})) in [#{project_name}](#{project_url}): *#{wiki_page_title}*")
        end
      end

      context 'when :action == "update"' do
        before do
          args[:object_attributes][:action] = 'update'
        end

        it 'returns a message that a wiki page was updated' do
          expect(subject.pretext).to eq("#{name} (#{username}) Edited [wiki page](#{url}) ([Compare changes]" \
            "(#{diff_url})) in [#{project_name}](#{project_url}): *#{wiki_page_title}*")
        end
      end
    end

    describe '#attachments' do
      context 'when :action == "create"' do
        before do
          args[:object_attributes][:action] = 'create'
        end

        it 'returns the commit message for a new wiki page' do
          expect(subject.attachments).to eq(commit_message)
        end

        it 'return content limitation message' do
          args[:object_attributes][:message] = 'a' * 4000

          expect(subject.attachments).to eq('Content length exceeds maximum allowed to display.')
        end
      end

      context 'when :action == "update"' do
        before do
          args[:object_attributes][:action] = 'update'
        end

        it 'returns the commit message for an updated wiki page' do
          expect(subject.attachments).to eq(commit_message)
        end
      end
    end
  end

  describe "#template_theme" do
    it 'return success theme' do
      expect(subject.template_theme).to eq Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:success]
    end
  end
end
