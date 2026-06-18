# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::Adapters::Slack, feature_category: :duo_agent_platform do
  let_it_be(:slack_installation) { create(:slack_integration) }

  let(:team_id) { slack_installation.team_id }
  let(:channel_id) { 'C0123ABC' }
  let(:thread_ts) { '1234567890.123456' }
  let(:message_ts) { '1234567890.123456' }
  let(:user_id) { 'U0123ABC' }

  let(:callback_context) do
    {
      'adapter' => 'slack',
      'team_id' => team_id,
      'channel_id' => channel_id,
      'thread_ts' => thread_ts,
      'message_ts' => message_ts,
      'user_id' => user_id
    }
  end

  let(:reactions_add_url) { "#{Slack::API::BASE_URL}/reactions.add" }
  let(:reactions_remove_url) { "#{Slack::API::BASE_URL}/reactions.remove" }
  let(:post_message_url) { "#{Slack::API::BASE_URL}/chat.postMessage" }
  let(:update_message_url) { "#{Slack::API::BASE_URL}/chat.update" }
  let(:set_status_url) { "#{Slack::API::BASE_URL}/assistant.threads.setStatus" }
  let(:post_ephemeral_url) { "#{Slack::API::BASE_URL}/chat.postEphemeral" }

  subject(:adapter) do
    described_class.new(
      team_id: team_id,
      channel_id: channel_id,
      thread_ts: thread_ts,
      message_ts: message_ts,
      user_id: user_id
    )
  end

  before do
    stub_request(:post, reactions_add_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, reactions_remove_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, post_message_url).to_return(
      status: 200, body: { ok: true, ts: '111.222' }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, update_message_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, set_status_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, post_ephemeral_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
  end

  describe '.adapter_key' do
    it { expect(described_class.adapter_key).to eq('slack') }
  end

  describe '.from_callback_context' do
    it 'reconstructs an adapter from callback context' do
      restored = described_class.from_callback_context(callback_context)

      expect(restored).to be_a(described_class)
      expect(restored.build_callback_context).to eq(
        'team_id' => team_id,
        'channel_id' => channel_id,
        'thread_ts' => thread_ts,
        'message_ts' => message_ts,
        'user_id' => user_id
      )
    end
  end

  describe '#build_callback_context' do
    it 'returns Slack delivery coordinates' do
      expect(adapter.build_callback_context).to eq(
        'team_id' => team_id,
        'channel_id' => channel_id,
        'thread_ts' => thread_ts,
        'message_ts' => message_ts,
        'user_id' => user_id
      )
    end
  end

  describe '#on_request_received' do
    it 'adds eyes reaction to the mention message' do
      adapter.on_request_received

      expect(WebMock).to have_requested(:post, reactions_add_url).with(
        body: hash_including(
          'name' => 'eyes',
          'channel' => channel_id,
          'timestamp' => message_ts
        )
      )
    end

    it 'sets a rotating thinking status' do
      adapter.on_request_received

      expect(WebMock).to have_requested(:post, set_status_url).with { |req| req.body.include?('loading_messages') }
    end
  end

  describe '#on_flow_started' do
    let(:workflow) { create(:duo_workflows_workflow) }

    it 'posts a single acknowledgement message and persists its ts', :aggregate_failures do
      adapter.on_flow_started(callback_context: callback_context, workflow: workflow)

      expect(WebMock).to have_requested(:post, post_message_url).with(
        body: hash_including('thread_ts' => thread_ts, 'text' => a_string_including('On it'))
      )
      expect(workflow.reload.messaging_callback_context).to include('status_ts' => '111.222')
    end

    it 'includes a context-block link to follow the session in GitLab' do
      allow(workflow).to receive(:web_url).and_return('https://gitlab.example.com/s/1')

      adapter.on_flow_started(callback_context: callback_context, workflow: workflow)

      expect(WebMock).to have_requested(:post, post_message_url)
        .with { |req| req.body.include?('https://gitlab.example.com/s/1') && req.body.include?('View session in GitLab') }
    end

    it 'omits the link when there is no session url' do
      allow(workflow).to receive(:web_url).and_return(nil)

      adapter.on_flow_started(callback_context: callback_context, workflow: workflow)

      expect(WebMock).to have_requested(:post, post_message_url)
        .with { |req| req.body.exclude?('View session in GitLab') }
    end

    it 'persists the session link even if the acknowledgement post fails' do
      allow(workflow).to receive(:web_url).and_return('https://gl.test/s/1')
      stub_request(:post, post_message_url).to_return(
        status: 200, body: { ok: false, error: 'channel_not_found' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      adapter.on_flow_started(callback_context: callback_context, workflow: workflow)

      expect(workflow.reload.messaging_callback_context).to include('session_url' => 'https://gl.test/s/1')
    end

    it 'is idempotent: does not re-post when a status_ts is already present' do
      adapter.on_flow_started(callback_context: callback_context.merge('status_ts' => '111.222'), workflow: workflow)

      expect(WebMock).not_to have_requested(:post, post_message_url)
    end

    it 'posts the acknowledgement when no status_ts is present yet' do
      adapter.on_flow_started(callback_context: callback_context, workflow: workflow)

      expect(WebMock).to have_requested(:post, post_message_url)
    end
  end

  describe '#on_flow_completed' do
    it 'removes eyes and adds checkmark reaction', :aggregate_failures do
      adapter.on_flow_completed(callback_context: callback_context, workflow: double)

      expect(WebMock).to have_requested(:post, reactions_remove_url).with(
        body: hash_including('name' => 'eyes')
      )
      expect(WebMock).to have_requested(:post, reactions_add_url).with(
        body: hash_including('name' => 'white_check_mark')
      )
    end
  end

  describe '#on_flow_failed' do
    shared_examples 'clears the working reaction and marks failure' do
      it 'removes the eyes reaction and adds the x reaction', :aggregate_failures do
        action

        expect(WebMock).to have_requested(:post, reactions_remove_url).with(
          body: hash_including('name' => 'eyes')
        )
        expect(WebMock).to have_requested(:post, reactions_add_url).with(
          body: hash_including('name' => 'x')
        )
      end
    end

    context 'when workflow is present but no message was posted (failure before start)' do
      let(:workflow) { instance_double(Ai::DuoWorkflows::Workflow, web_url: 'https://gl.test/s/1') }

      subject(:action) do
        adapter.on_flow_failed(
          callback_context: callback_context,
          error: :flow_failed,
          workflow: workflow
        )
      end

      include_examples 'clears the working reaction and marks failure'

      it 'clears the status indicator' do
        action

        expect(WebMock).to have_requested(:post, set_status_url).with(body: hash_including('status' => ''))
      end

      it 'posts a threaded reply with the error and a context-block session link', :aggregate_failures do
        action

        expect(WebMock).to have_requested(:post, post_message_url)
          .with { |req| req.body.include?('went wrong') && req.body.include?('View session in GitLab') }
        expect(WebMock).to have_requested(:post, post_message_url)
          .with { |req| req.body.include?('context') && req.body.include?('https://gl.test/s/1') }
        expect(WebMock).not_to have_requested(:post, post_ephemeral_url)
      end
    end

    context 'when workflow is nil (sync failure)' do
      subject(:action) do
        adapter.on_flow_failed(
          callback_context: callback_context,
          error: :service_account_error,
          workflow: nil
        )
      end

      include_examples 'clears the working reaction and marks failure'

      it 'clears the status indicator' do
        action

        expect(WebMock).to have_requested(:post, set_status_url).with(body: hash_including('status' => ''))
      end

      it 'delivers an ephemeral error message' do
        action

        expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
          body: hash_including('text' => a_string_including('service account'))
        )
      end
    end

    context 'when a status message exists' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }

      subject(:action) do
        adapter.on_flow_failed(callback_context: callback_context, error: :flow_failed, workflow: double)
      end

      include_examples 'clears the working reaction and marks failure'

      it 'edits the message with the error text instead of an ephemeral', :aggregate_failures do
        action

        expect(WebMock).to have_requested(:post, update_message_url).with(
          body: hash_including('ts' => '111.222', 'text' => a_string_including('went wrong'))
        )
        expect(WebMock).not_to have_requested(:post, post_ephemeral_url)
        # status was cleared by posting the message; do not clear it again
        expect(WebMock).not_to have_requested(:post, set_status_url)
      end

      context 'with a session_url' do
        let(:callback_context) { super().merge('session_url' => 'https://gl.test/s/1') }

        it 'keeps the session link footer in the error message' do
          action

          expect(WebMock).to have_requested(:post, update_message_url)
            .with { |req| req.body.include?('View session in GitLab') }
        end
      end
    end
  end

  describe '#deliver_result' do
    context 'when there is no status message' do
      it 'posts a threaded reply with the message' do
        adapter.deliver_result(callback_context: callback_context, message: 'Hello from Duo!')

        expect(WebMock).to have_requested(:post, post_message_url).with(
          body: hash_including('channel' => channel_id, 'thread_ts' => thread_ts, 'text' => 'Hello from Duo!')
        )
      end

      context 'with a session_url' do
        let(:callback_context) { super().merge('session_url' => 'https://gl.test/s/1') }

        it 'appends an inline session link to the reply' do
          adapter.deliver_result(callback_context: callback_context, message: 'Done!')

          expect(WebMock).to have_requested(:post, post_message_url).with(
            body: hash_including('text' => a_string_including('Done!', 'View session in GitLab'))
          )
        end
      end
    end

    context 'when a status message exists' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }

      it 'edits the message in place with a markdown block' do
        adapter.deliver_result(callback_context: callback_context, message: 'Done!')

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          body = ::Gitlab::Json.safe_parse(req.body)
          body['ts'] == '111.222' && body['blocks'].any? { |b| b['type'] == 'markdown' && b['text'] == 'Done!' }
        }
      end

      context 'with a session_url' do
        let(:callback_context) { super().merge('session_url' => 'https://gl.test/s/1') }

        it 'adds a subtle context-block footer linking the session' do
          adapter.deliver_result(callback_context: callback_context, message: 'Done!')

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            ::Gitlab::Json.safe_parse(req.body)['blocks'].any? do |b|
              b['type'] == 'context' && b.to_s.include?('View session in GitLab')
            end
          }
        end
      end

      context 'when the block render is rejected' do
        before do
          # First call (with blocks) is rejected; second call (blocks: []) succeeds.
          stub_request(:post, update_message_url).to_return(
            { status: 200, body: { ok: false, error: 'invalid_blocks' }.to_json,
              headers: { 'Content-Type' => 'application/json' } },
            { status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' } }
          )
        end

        it 'retries with a plain-text edit clearing blocks so the answer is not lost', :aggregate_failures do
          adapter.deliver_result(callback_context: callback_context, message: 'Done!')

          expect(WebMock).to have_requested(:post, update_message_url).twice
          expect(WebMock).to have_requested(:post, update_message_url)
            .with { |req| req.body.include?('"blocks":[]') }
        end
      end
    end
  end

  describe '#deliver_error' do
    it 'posts an ephemeral error message to the user' do
      adapter.deliver_error(callback_context: callback_context, error: :namespace_not_configured)

      expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
        body: hash_including(
          'channel' => channel_id,
          'user' => user_id,
          'text' => a_string_including('default Duo namespace')
        )
      )
    end

    it 'handles unknown errors with a generic message' do
      adapter.deliver_error(callback_context: callback_context, error: :something_unexpected)

      expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
        body: hash_including('text' => a_string_including('Something went wrong. Try again.'))
      )
    end
  end

  describe 'error text mapping' do
    using RSpec::Parameterized::TableSyntax

    where(:error_sym, :expected_text) do
      :namespace_not_configured | 'default Duo namespace'
      :flow_not_enabled         | 'not enabled for your namespace'
      :service_account_error    | 'service account for the Duo Developer flow'
      :workspace_project_error  | 'workspace project'
      :execute_workflow_failed  | 'Failed to start the Duo Developer workflow'
      :flow_failed              | 'went wrong while running'
      :no_response              | "didn't produce a response"
    end

    with_them do
      it 'delivers the correct error text via ephemeral message' do
        adapter.on_flow_failed(callback_context: callback_context, error: error_sym)

        expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
          body: hash_including('text' => a_string_including(expected_text))
        )
      end
    end
  end

  context 'when Slack installation is not found' do
    let(:nonexistent_adapter) do
      described_class.new(
        team_id: 'NONEXISTENT',
        channel_id: channel_id,
        thread_ts: thread_ts,
        message_ts: message_ts,
        user_id: user_id
      )
    end

    let(:nonexistent_context) { nonexistent_adapter.build_callback_context }

    it 'tracks exception on deliver_result instead of raising' do
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
        instance_of(described_class::InstallationNotFoundError),
        hash_including(slack_team_id: 'NONEXISTENT')
      )

      expect { nonexistent_adapter.deliver_result(callback_context: nonexistent_context, message: 'test') }
        .not_to raise_error
    end

    it 'tracks exception on deliver_error instead of raising' do
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
        instance_of(described_class::InstallationNotFoundError),
        hash_including(slack_team_id: 'NONEXISTENT')
      )

      expect { nonexistent_adapter.deliver_error(callback_context: nonexistent_context, error: :flow_failed) }
        .not_to raise_error
    end

    it 'tracks exception on on_request_received instead of raising' do
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
        instance_of(described_class::InstallationNotFoundError),
        hash_including(slack_team_id: 'NONEXISTENT')
      )

      nonexistent_adapter.on_request_received
    end
  end

  describe 'Slack API caching' do
    it 'reuses the Slack API client for the same team' do
      expect(SlackIntegration).to receive(:with_bot).once.and_call_original

      adapter.deliver_result(callback_context: callback_context, message: 'first')
      adapter.deliver_result(callback_context: callback_context, message: 'second')
    end
  end

  describe 'Slack API error handling' do
    using RSpec::Parameterized::TableSyntax

    where(:api_method, :slack_error, :log_message) do
      'reactions.add'      | 'already_reacted'  | 'Slack API error when adding reaction'
      'reactions.remove'   | 'no_reaction'      | 'Slack API error when removing reaction'
      'chat.postMessage'   | 'channel_not_found' | 'Slack API error when posting message'
      'chat.postEphemeral' | 'user_not_found'    | 'Slack API error when posting ephemeral message'
    end

    with_them do
      before do
        stub_request(:post, "#{Slack::API::BASE_URL}/#{api_method}").to_return(
          status: 200, body: { ok: false, error: slack_error }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      it 'logs the error and does not raise' do
        expect(Gitlab::IntegrationsLogger).to receive(:error).with(
          hash_including(message: log_message)
        )

        # Trigger the code path that exercises the stubbed API method
        case api_method
        when 'reactions.add'
          expect { adapter.on_request_received }.not_to raise_error
        when 'reactions.remove'
          expect { adapter.on_flow_completed(callback_context: callback_context, workflow: double) }
            .not_to raise_error
        when 'chat.postMessage'
          expect { adapter.deliver_result(callback_context: callback_context, message: 'test') }
            .not_to raise_error
        when 'chat.postEphemeral'
          expect { adapter.deliver_error(callback_context: callback_context, error: :flow_failed) }
            .not_to raise_error
        end
      end
    end
  end
end
