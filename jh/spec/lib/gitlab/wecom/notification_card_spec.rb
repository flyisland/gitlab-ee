# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Wecom::NotificationCard, feature_category: :integrations do
  subject(:card) { described_class.new(title: 'Zhang San commented', url: 'https://example.com/x', project: 'group/app').to_h }

  it 'shows the notification title' do
    expect(card[:main_title][:title]).to eq('Zhang San commented')
  end

  it 'links back to what the email pointed at' do
    expect(card[:card_action]).to eq({ type: 1, url: 'https://example.com/x' })
  end

  it 'names the project' do
    expect(card[:horizontal_content_list]).to eq([{ keyname: 'Project', value: 'group/app' }])
  end

  # The recipient's phone fetches this, so it has to be absolute, and it has to
  # be the instance's own host rather than somebody else's.
  it 'points the icon at the instance itself' do
    expect(card[:source][:icon_url]).to eq("#{Gitlab.config.gitlab.url}/apple-touch-icon.png")
  end

  it 'truncates a long title' do
    built = described_class.new(title: 'a' * 500).to_h

    expect(built[:main_title][:title].length).to eq(described_class::TITLE_LIMIT)
  end

  # WeCom rejects a text_notice card that has no card_action url.
  it 'falls back to the instance when the email carried no link' do
    built = described_class.new(title: 'x', url: nil).to_h

    expect(built[:card_action][:url]).to eq(Gitlab.config.gitlab.url)
  end

  describe 'the quote block' do
    it 'quotes the excerpt taken from the email' do
      built = described_class.new(title: 'x', excerpt: 'Zhang San commented: looks good').to_h

      expect(built[:quote_area]).to eq({ type: 0, quote_text: 'Zhang San commented: looks good' })
    end

    it 'is omitted rather than left blank when there is nothing to quote' do
      expect(described_class.new(title: 'x').to_h).not_to have_key(:quote_area)
    end
  end

  it 'omits the content list when there is nothing to put in it' do
    expect(described_class.new(title: 'x').to_h).not_to have_key(:horizontal_content_list)
  end

  # The email subject threads a conversation, so it repeats the project and
  # carries a Re: prefix. Neither belongs on a card.
  describe 'the title' do
    it 'drops the threading prefix and the repeated project' do
      built = described_class.new(title: 'Re: group/app | Fix the thing (#12)', project: 'group/app').to_h

      expect(built[:main_title][:title]).to eq('Fix the thing (#12)')
    end

    it 'leaves a subject that carries neither alone' do
      built = described_class.new(title: 'Pipeline failed', project: 'group/app').to_h

      expect(built[:main_title][:title]).to eq('Pipeline failed')
    end
  end

  # Every notification about one issue threads under the same subject, so the
  # reason is what tells assignment apart from a passing mention.
  describe 'the reason' do
    def reason_row(reason)
      built = described_class.new(title: 'x', project: 'group/app', reason: reason).to_h
      built[:horizontal_content_list].find { |row| row[:keyname] == 'Reason' }
    end

    it 'names a reason it recognises' do
      expect(reason_row(NotificationReason::ASSIGNED)[:value]).to eq('Assigned to you')
      expect(reason_row(NotificationReason::REVIEW_REQUESTED)[:value]).to eq('Review requested')
      expect(reason_row(NotificationReason::MENTIONED)[:value]).to eq('You were mentioned')
      expect(reason_row(NotificationReason::SUBSCRIBED)[:value]).to eq('Subscribed')
    end

    # Better a card with one row than a card showing a raw slug.
    it 'drops the row for a reason it does not recognise' do
      expect(reason_row('alert_firing')).to be_nil
    end

    it 'drops the row when the email carried no reason' do
      expect(reason_row(nil)).to be_nil
    end
  end
end
