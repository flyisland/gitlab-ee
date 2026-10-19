# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::NotificationCard, feature_category: :integrations do
  it 'uses the supplied mail title, project, reason, summary and URL', :aggregate_failures do
    card = described_class.new(
      title: 'Review requested', project: 'team/project', reason: NotificationReason::REVIEW_REQUESTED,
      excerpt: 'Please review this change', url: 'https://example.com/merge_requests/1'
    ).to_h

    expect(card[:title]).to eq('Review requested')
    expect(card[:markdown]).to eq(
      "Review requested\n\nPlease review this change\n\nProject: team/project\n\nReason: Review requested"
    )
    expect(card[:single_url]).to eq('https://example.com/merge_requests/1')
  end

  it 'drops the threading prefix and the repeated project from the title', :aggregate_failures do
    card = described_class.new(title: 'Re: test | Fix the thing (#18)', project: 'test').to_h

    expect(card[:title]).to eq('Fix the thing (#18)')
    expect(card[:markdown]).to start_with('Fix the thing \\(\\#18\\)')
  end

  it 'does not embed links or images from untrusted markdown' do
    card = described_class.new(title: 'Title', excerpt: '![image](https://evil.example) <img src=x>').to_h

    expect(card[:markdown]).to include('\\!\\[image\\]\\(https://evil\\.example\\)', '&lt;img src=x&gt;')
  end

  it 'falls back to the instance URL and omits absent content', :aggregate_failures do
    card = described_class.new(title: 'Confidential').to_h

    expect(card[:markdown]).to eq('Confidential')
    expect(card[:single_url]).to eq(Gitlab.config.gitlab.url)
  end

  it 'keeps a multibyte action card within the API message limit' do
    card = described_class.new(title: '通知' * 100, project: '项目' * 100, excerpt: '*' * 500).to_h
    payload = Gitlab::Json.generate(msgtype: 'action_card', action_card: card)

    expect(payload.bytesize).to be <= described_class::MESSAGE_BYTES_LIMIT
    expect(card[:markdown]).to be_valid_encoding
  end
end
