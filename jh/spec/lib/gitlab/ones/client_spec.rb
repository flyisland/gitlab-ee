# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ones::Client do
  include OnesClientHelper

  let_it_be(:integration) { create(:ones_integration) }

  let(:client) { described_class.new(integration) }

  describe '#graphql_query' do
    let(:graphql_url) { ones_url "team/#{integration.namespace}/items/graphql" }
    let(:success) { nil }

    before do
      mock_fetch_project(url: graphql_url, project_uuid: integration.project_key, success: success)
    end

    context 'with valid ones project' do
      let(:success) { true }

      it 'returns success' do
        expect(client.ping).to include(success: success)
      end
    end

    context 'without valid ones project' do
      let(:success) { false }

      it 'does not return success' do
        expect(client.ping).to include(success: success)
      end
    end

    context 'with invalid response' do
      before do
        WebMock.stub_request(:post, graphql_url).to_return(body: '[[[invalid json data')
      end

      it 'raises error' do
        expect(client.ping).to include(success: false)
      end
    end
  end

  describe '#message_query' do
    let(:task_uuid) { SecureRandom.hex(8) }
    let(:message_url) { ones_url "team/#{integration.namespace}/task/#{task_uuid}/messages" }

    before do
      mock_fetch_message(
        url: message_url,
        team_uuid: integration.namespace,
        project_uuid: integration.project_key,
        task_uuid: task_uuid
      )
    end

    subject(:messages) do
      client.message_query(task_uuid)
            .fetch("messages")
            .filter { |message| message['type'] == 'discussion' && message['ref_type'] == 'task' }
    end

    it 'fetches task message' do
      expect(messages).to all(include('ref_id' => task_uuid))
    end
  end
end
