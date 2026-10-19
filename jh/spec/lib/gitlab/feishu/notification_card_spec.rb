# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Feishu::NotificationCard, feature_category: :integrations do
  let(:attributes) do
    { title: 'Review requested', url: 'https://gitlab.example.com/project/-/merge_requests/1',
      project: 'group/project', reason: NotificationReason::REVIEW_REQUESTED, excerpt: '<at id="all">hello</at>',
      icon_key: 'img_v2_icon' }
  end

  subject(:card) { described_class.new(**attributes).to_h }

  it 'shows the instance icon and product name next to the title', :aggregate_failures do
    expect(card[:header][:icon]).to eq(img_key: 'img_v2_icon')
    expect(card[:header][:subtitle]).to eq(tag: 'plain_text', content: 'JiHu GitLab')
    expect(card[:header][:title]).to eq(tag: 'plain_text', content: 'Review requested')
  end

  it 'omits the icon when it could not be uploaded' do
    expect(described_class.new(**attributes, icon_key: nil).to_h[:header]).not_to have_key(:icon)
  end

  it 'lists the excerpt, project and reason as plain text in the WeCom card order' do
    rows = card[:elements].first(3).map { |row| row.dig(:text, :content) }

    expect(rows).to eq([attributes[:excerpt], 'Project: group/project', 'Reason: Review requested'])
    expect(card[:elements].first(3).map { |row| row.dig(:text, :tag) }).to all(eq('plain_text'))
  end

  it 'opens the notification from the whole card and from the button', :aggregate_failures do
    expect(card[:card_link]).to eq(url: attributes[:url])
    expect(card[:elements].last[:actions].first[:url]).to eq(attributes[:url])
    expect(card[:config][:enable_forward]).to be(false)
  end

  it 'falls back to the instance when the email carried no link' do
    built = described_class.new(title: 'x').to_h

    expect(built[:card_link][:url]).to eq(Gitlab.config.gitlab.url)
  end

  it 'drops the threading prefix and the repeated project from the title' do
    built = described_class.new(title: 'Re: group/project | Fix the thing (#12)', project: 'group/project').to_h

    expect(built[:header][:title][:content]).to eq('Fix the thing (#12)')
  end

  it 'truncates a long title' do
    built = described_class.new(title: 'a' * 500).to_h

    expect(built[:header][:title][:content].length).to eq(described_class::TITLE_LIMIT)
  end

  it 'drops an unrecognised reason' do
    built = described_class.new(title: 'x', reason: 'unknown').to_h

    expect(built[:elements].size).to eq(1)
  end

  context 'when only a title and link are supplied for a confidential notification' do
    let(:attributes) { { title: 'Confidential issue', url: 'https://gitlab.example.com/issue' } }

    it 'contains no body fields' do
      expect(card[:elements].size).to eq(1)
      expect(card[:elements].first[:tag]).to eq('action')
    end
  end
end
