# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Page do
  let(:response) { {} }
  let(:headers) { { 'total_page' => 2 } }
  let(:body) { Gitlab::Json.generate([{ 'username' => 'Tom' }]) }

  before do
    # Autoloading hack
    Gitee::Representation::User.new({})
    allow(response).to receive_messages(body: body, headers: headers)
  end

  describe '#initialize' do
    it 'initializes the page' do
      page = described_class.new(response, :user, 1)
      expect(page.response).to eq(response)
      expect(page.type).to eq(:user)
      expect(page.items.count).to eq(1)
      expect(page.items.first).to be_a(Gitee::Representation::User)
      expect(page.current_page).to eq(1)
    end
  end

  describe '#items' do
    it 'returns collection of needed objects' do
      page = described_class.new(response, :user, 1)

      expect(page.items.first).to be_a(Gitee::Representation::User)
      expect(page.items.count).to eq(1)
    end
  end

  describe '#has_next_page?' do
    it 'returns false' do
      page = described_class.new(response, :user, 2)

      expect(page.has_next_page?).to be(false)
    end

    it 'returns true' do
      page = described_class.new(response, :user, 1)

      expect(page.has_next_page?).to be(true)
    end
  end

  describe '#total_page' do
    it 'returns the total page' do
      page = described_class.new(response, :user, 1)
      expect(page.send(:total_page)).to eq(2)
    end
  end

  describe '#parse_values' do
    context 'when the body of response is empty' do
      before do
        allow(response).to receive(:body).and_return("{}")
      end

      it 'returns empty array' do
        page = described_class.new(response, :user, 1)
        expect(page.send(:parse_values, response)).to eq([])
      end
    end

    context 'when the body of response is not empty' do
      it 'returns the user data' do
        page = described_class.new(response, :user, 1)
        expect(page.send(:parse_values, response).count).to eq(1)
      end
    end
  end

  describe '#representation_class' do
    [
      [:issue_comment, Gitee::Representation::IssueComment],
      [:issue, Gitee::Representation::Issue],
      [:label, Gitee::Representation::Label],
      [:milestone, Gitee::Representation::Milestone],
      [:pull_request_comment, Gitee::Representation::PullRequestComment],
      [:pull_request, Gitee::Representation::PullRequest],
      [:repo, Gitee::Representation::Repo],
      [:user, Gitee::Representation::User]
    ].each do |type, klass|
      it 'returns the right class' do
        page = described_class.new(response, :user, 1)
        expect(page.send(:representation_class, type)).to eq(klass)
      end
    end
  end
end
