# frozen_string_literal: true

module QA
  RSpec.describe 'Ai-powered', feature_category: :duo_agent_platform do
    describe 'Duo Agent Platform Chat' do
      let(:user) { Runtime::User::Store.test_user }
      let(:api_client) { Runtime::User::Store.default_api_client }
      let(:token) { api_client.personal_access_token }
      let(:identity_response) { '我是 GitLab Duo Chat' }

      let(:group) do
        create(:group, name: "dap-test-group-#{SecureRandom.hex(4)}", api_client: api_client)
      end

      shared_examples 'Duo Agent Platform Chat' do |testcase|
        it 'returns a valid response when asking about identity', testcase: testcase do
          QA::EE::Page::Component::DuoChat.perform(&:open_duo_chat)

          QA::Page::Component::DuoAgentPlatform.perform do |dap_chat|
            dap_chat.select_model_on_chat_panel
            dap_chat.ensure_agentic_mode!
          end

          QA::EE::Page::Component::DuoChat.perform do |dap_chat|
            dap_chat.clear_chat_history
            dap_chat.send_duo_chat_prompt('Who are you?')

            expect { dap_chat.response }
              .to eventually_include(identity_response).within(max_duration: 120),
                "Expected DAP Chat response to contain '#{identity_response}'"

            QA::Runtime::Logger.info("DAP Chat response: #{dap_chat.response}")
          end
        end
      end

      before do
        QA::Flow::Login.sign_in(as: user)
      end

      context "when asking 'Who are you?'" do
        context 'on SaaS', :external_ai_provider,
          only: { pipeline: %i[staging staging-canary canary production] } do
          include_examples 'Duo Agent Platform Chat',
            'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/84'
        end

        context 'on Self-managed', :orchestrated, :ai_gateway do
          let(:api_client) { Runtime::User::Store.admin_api_client }
          let(:user) { Runtime::User::Store.admin_user }

          before do
            group.visit!
          end

          include_examples 'Duo Agent Platform Chat',
            'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/85'
        end
      end
    end
  end
end
