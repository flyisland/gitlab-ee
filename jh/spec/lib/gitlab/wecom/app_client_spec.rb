# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Wecom::AppClient, feature_category: :integrations do
  using RSpec::Parameterized::TableSyntax

  let(:app) { class_double(Gitlab::Wecom::App) }
  let(:client) { described_class.new(app: app) }
  let(:site) { 'https://qyapi.test' }
  let(:message_url) { "#{site}#{described_class::MESSAGE_PATH}" }
  let(:card) { { card_type: 'text_notice' } }

  before do
    allow(app).to receive_messages(
      api_site: site, agent_id: '1000002', access_token: ['app-token', 7200]
    )
    allow(app).to receive(:invalidate_access_token)
  end

  def stub_send(body, status: 200)
    stub_request(:post, message_url)
      .with(query: { access_token: 'app-token' })
      .to_return(status: status, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe '#send_card' do
    it 'posts the card to the configured recipients' do
      request = stub_send({ errcode: 0, msgid: 'MSG-1' })

      result = client.send_card(%w[alice bob], card)

      expect(result.message_id).to eq('MSG-1')
      expect(result).not_to be_partial
      expect(request).to have_been_requested
    end

    it 'joins recipients the way WeCom expects and asks it to drop duplicates' do
      stub_send({ errcode: 0 })

      client.send_card(%w[alice bob], card)

      expect(
        a_request(:post, message_url).with(query: hash_including({})) do |req|
          body = Gitlab::Json.parse(req.body)
          body['touser'] == 'alice|bob' && body['enable_duplicate_check'] == 1
        end
      ).to have_been_made
    end

    # A 200 with errcode 0 does not mean everyone received it.
    it 'reports recipients WeCom could not deliver to' do
      stub_send({ errcode: 0, msgid: 'MSG-1', invaliduser: 'bob' })

      result = client.send_card(%w[alice bob], card)

      expect(result).to be_partial
      expect(result.invalid_user_ids).to eq(['bob'])
    end

    it 'rejects an empty or oversized recipient list' do
      expect { client.send_card([], card) }.to raise_error(ArgumentError, /no recipients/)
      expect { client.send_card(Array.new(described_class::MAX_RECIPIENTS + 1) { |i| "u#{i}" }, card) }
        .to raise_error(ArgumentError, /too many recipients/)
    end
  end

  describe 'failure classification' do
    it 'retries once with a fresh token when WeCom rejects the current one' do
      stub_request(:post, message_url)
        .with(query: { access_token: 'app-token' })
        .to_return(
          { status: 200, body: { errcode: 42001, errmsg: 'access_token expired' }.to_json },
          { status: 200, body: { errcode: 0, msgid: 'MSG-2' }.to_json }
        )

      expect(app).to receive(:invalidate_access_token)

      expect(client.send_card(['alice'], card).message_id).to eq('MSG-2')
    end

    it 'gives up as transient when the token keeps being rejected' do
      stub_send({ errcode: 42001, errmsg: 'access_token expired' })

      expect { client.send_card(['alice'], card) }
        .to raise_error(described_class::TransientError, /kept rejecting/)
    end

    # WeCom says "system busy, try again later" with this one.
    it 'treats errcode -1 as transient' do
      stub_send({ errcode: -1, errmsg: 'system is busy' })

      expect { client.send_card(['alice'], card) }
        .to raise_error(described_class::TransientError, /busy/)
    end

    # 41001 means the token was never sent, which refetching does not fix.
    it 'does not refetch the token for a missing-token error' do
      stub_send({ errcode: 41001, errmsg: 'missing access_token' })

      expect(app).not_to receive(:invalidate_access_token)
      expect { client.send_card(['alice'], card) }.to raise_error(described_class::PermanentError)
    end

    # The ban window can last hours, so an immediate retry deepens it.
    it 'does not retry when the app has been rate limited' do
      stub_send({ errcode: 45009, errmsg: 'api freq out of limit' })

      expect { client.send_card(['alice'], card) }
        .to raise_error(described_class::PermanentError, /rate limited/)
    end

    # Retrying a refused request just sends the same refused request again.
    where(:case_name, :body) do
      [
        ['the agent id is wrong',        { errcode: 40056, errmsg: 'invalid agentid' }],
        ['the app lost permission',      { errcode: 60011, errmsg: 'no privilege' }],
        ['there is no errcode at all',   { msgid: 'MSG' }],
        ['the code is one we do not know', { errcode: 99999, errmsg: 'brand new failure' }]
      ]
    end

    with_them do
      it 'is permanent' do
        stub_send(body)

        expect { client.send_card(['alice'], card) }.to raise_error(described_class::PermanentError)
      end
    end

    where(:status, :expected) do
      [
        [503, Gitlab::Wecom::AppClient::TransientError],
        [500, Gitlab::Wecom::AppClient::TransientError],
        [408, Gitlab::Wecom::AppClient::TransientError],
        [429, Gitlab::Wecom::AppClient::PermanentError],
        [404, Gitlab::Wecom::AppClient::PermanentError]
      ]
    end

    with_them do
      it 'classifies HTTP status correctly' do
        stub_send({ errcode: 0 }, status: status)

        expect { client.send_card(['alice'], card) }.to raise_error(expected, /HTTP #{status}/)
      end
    end

    it 'treats a malformed body as transient' do
      stub_request(:post, message_url)
        .with(query: { access_token: 'app-token' })
        .to_return(status: 200, body: '<html>gateway</html>')

      expect { client.send_card(['alice'], card) }
        .to raise_error(described_class::TransientError, /malformed/)
    end

    it 'treats a blocked endpoint as permanent, since retrying cannot unblock it' do
      allow(Gitlab::HTTP).to receive(:post).and_raise(Gitlab::HTTP::BlockedUrlError)

      expect { client.send_card(['alice'], card) }
        .to raise_error(described_class::PermanentError, /not reachable/)
    end
  end
end
