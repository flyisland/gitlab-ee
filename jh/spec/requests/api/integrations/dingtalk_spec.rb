# frozen_string_literal: true

require "spec_helper"

RSpec.describe 'API::Integrations', feature_category: :system_access do
  include ApiHelpers

  let_it_be(:user, freeze: false) { create(:user, :with_namespace) }
  let_it_be(:path) { '/integrations/dingtalk/robot' }
  let_it_be(:headers) do
    { Sign: "vKVVGQrlOIoj8eWZXte3kfwWWo7Gi08hdeJNwqdemhk=",
      Timestamp: "1649993849126" }
  end

  describe 'DingTalk Integration' do
    it 'disable for free plan' do
      stub_licensed_features(dingtalk_integration: false)

      post api(path)

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to include({
                                    "msgtype" => "text",
                                    "text" => { "content" => "Dingtalk bot is deactivated. " \
                                                  "Please upgrade your JiHu GitLab to Premium Plan" }
                                  })
    end

    it 'disable for saas' do
      stub_licensed_features(dingtalk_integration: true)
      allow(::Gitlab).to receive(:com?).and_return(true)

      post api(path)

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to include({
                                    "msgtype" => "text",
                                    "text" => { "content" => "Dingtalk Integration for Saas is coming soon." }
                                  })
    end

    context 'when disable application setting' do
      it 'return ok and dingtalk message' do
        stub_licensed_features(dingtalk_integration: true)
        stub_application_setting(dingtalk_integration_enabled: false)

        post api(path)

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to include({
                                           "msgtype" => "text",
                                           "text" => {
                                             "content" => "Message verification failed. Please check your " \
                                               "settings of Dingtalk Integration in JiHu GitLab."
                                           }
                                         })
      end
    end

    context 'when enable application setting' do
      before do
        stub_licensed_features(dingtalk_integration: true, project_aliases: true)
        stub_application_setting(
          dingtalk_integration_enabled: true,
          dingtalk_app_key: "dingtalk_app_key",
          dingtalk_corpid: "dingtalk_corpid",
          dingtalk_app_secret: "dingtalk_app_secret"
        )
      end

      context 'for not handle message' do
        it 'returns ok if message is invalid' do
          post api(path), params: {}, headers: headers.merge(Timestamp: "wrong timestamp")

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to include({
                                             "msgtype" => "text",
                                             "text" => {
                                               "content" => "Message verification failed. Please check your " \
                                                 "settings of Dingtalk Integration in JiHu GitLab."
                                             }
                                           })
        end

        it 'returns ok if no instance dingtalk integration found' do
          post api(path), params: {}, headers: headers

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to include({
                                             "msgtype" => "text",
                                             "text" => {
                                               "content" => "Please contact your administrator to enable " \
                                                 "Dingtalk Integration in Admin - Settings - Integration"
                                             }
                                           })
        end

        it 'response bind message when no bind user' do
          data = {
            senderStaffId: 'senderStaffId',
            chatbotCorpId: 'chatbotCorpId',
            conversationType: '2'
          }
          stub_request(:post, ::Gitlab::Dingtalk::Client::ACCESS_TOKEN_ENDPOINT)
            .with(
              body: "{\"appKey\":\"dingtalk_app_key\",\"appSecret\":\"dingtalk_app_secret\"}",
              headers: { 'Content-Type' => 'application/json' })
            .to_return(status: 200, body: Gitlab::Json.generate({ 'accessToken' => 'accessToken',
                                                                  'expireIn' => 7200 }), headers: {})

          stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
            .to_return(status: 200, body: "", headers: {})

          create(:dingtalk_integration, :instance, corpid: data[:chatbotCorpId])

          post api(path), params: data, headers: headers

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to eq({
                                        "msgtype" => "text",
                                        "text" => {
                                          "content" => "You need to connect your JiHu GitLab account " \
                                            "before performing bot commands."
                                        },
                                        "at" => { "atUserIds" => ["senderStaffId"], "isAtAll" => false }
                                      })
        end
      end

      context 'for handle message' do
        let(:sender_staff_id) { 'senderStaffId' }
        let(:chatbot_corp_id) { 'dingtalk_corpid' }
        let(:data) do
          {
            senderStaffId: sender_staff_id,
            chatbotCorpId: chatbot_corp_id,
            conversationType: '1',
            text: { content: "project-path issue new title \ndes1\ndes2\ndes3" }
          }
        end

        before do
          stub_application_setting(
            dingtalk_integration_enabled: true,
            dingtalk_app_key: "dingtalk_app_key",
            dingtalk_corpid: "dingtalk_corpid",
            dingtalk_app_secret: "dingtalk_app_secret"
          )
          create(:dingtalk_integration, :instance, corpid: data[:chatbotCorpId])
          create(:chat_name, user: user, team_id: chatbot_corp_id, chat_id: sender_staff_id)
        end

        context 'in failure' do
          it 'no found project' do
            post api(path), params: data, headers: headers

            expect(response).to have_gitlab_http_status(:ok)
            expect(json_response).to include({
                                               "msgtype" => "text",
                                               "text" => { "content" => "I cannot find the project project-path" }
                                             })
          end

          it 'not active user' do
            user.deactivate

            post api(path), params: data, headers: headers

            expect(response).to have_gitlab_http_status(:ok)
            expect(json_response).to include({
                                               "msgtype" => "text",
                                               "text" => {
                                                 "content" => "Your JiHu GitLab user account is locked. " \
                                                   "Please unlock it before performing bot commands."
                                               }
                                             })
          end

          it 'no permission on project' do
            another_user = create(:user, :with_namespace)
            project = create(:project, creator_id: another_user.id, namespace: another_user.namespace)

            post api(path),
              params: data.merge({ text: { content: "#{project.full_path} issue new title" } }),
              headers: headers

            expect(response).to have_gitlab_http_status(:ok)
            expect(json_response).to include({
                                               "msgtype" => "text",
                                               "text" => {
                                                 "content" => "You are not allowed to perform bot commands."
                                               }
                                             })
          end

          it 'wrong command' do
            project = create(:project, creator_id: user.id, namespace: user.namespace)

            post api(path),
              params: data.merge({ text: { content: "#{project.full_path} wrong command" } }),
              headers: headers

            expect(response).to have_gitlab_http_status(:ok)
            expect(json_response).to include({
                                               "msgtype" => "text",
                                               "text" => {
                                                 "content" => "I cannot understand your command. Type \"help\" to " \
                                                   "view all commands."
                                               }
                                             })
          end

          it 'disable project alias' do
            params = data.merge(text: { content: "project-alias issue new issue-title" })
            post api(path), params: params, headers: headers

            expect(response).to have_gitlab_http_status(:ok)
            expect(json_response).to include({
                                               "msgtype" => "text",
                                               "text" => { "content" => "I cannot find the project project-alias" }
                                             })
          end
        end

        context 'in success' do
          let(:project) { create(:project, creator_id: user.id, namespace: user.namespace) }

          context 'for help' do
            it 'help' do
              post api(path), params: data.merge(text: { content: 'help' }), headers: headers

              expect(response).to have_gitlab_http_status(:ok)
              expect(json_response).to include({
                                                 "msgtype" => "markdown",
                                                 "markdown" => {
                                                   "title" => "Bot commands help",
                                                   "text" => a_string_matching(/The following commands are available/)
                                                 }
                                               })
              Gitlab::ChatopsCommands::Command.commands.each do |command|
                expect(json_response['markdown']['text']).to include(command.help_message)
              end
            end
          end

          context 'for issue command' do
            context 'for new command' do
              it 'create issue by project alias' do
                project_alias = create(:project_alias, project: project, name: 'project-alias')
                params = data.merge(text: { content: "#{project_alias.name} issue new issue-title" })
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "at" => { "atUserIds" => ["senderStaffId"], "isAtAll" => false },
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => a_string_matching(/issue #\d+ created/),
                                                     "text" => a_string_matching(/I created an issue/)
                                                   }
                                                 })
                finder = IssuesFinder.new(user, project_id: project.id).execute
                expect(finder.find_by(title: 'issue-title')).not_to be_nil
              end

              it 'create issue by project id' do
                params = data.merge(text: { content: "#{project.id} issue new issue-title" })
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "at" => { "atUserIds" => ["senderStaffId"], "isAtAll" => false },
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => a_string_matching(/issue #\d+ created/),
                                                     "text" => a_string_matching(/I created an issue/)
                                                   }
                                                 })
                finder = IssuesFinder.new(user, project_id: project.id).execute
                expect(finder.find_by(title: 'issue-title')).not_to be_nil
              end

              it 'return error message' do
                allow_next_instance_of(::Issues::CreateService) do |service|
                  wrong_issue = build(:issue, title: '')
                  result = ServiceResponse.error(message: '', payload: { issue: wrong_issue })
                  wrong_issue.valid?
                  allow(service).to receive(:execute).and_return(result)
                end

                params = data.merge(text: { content: "#{project.id} issue new issue-title" })
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => 'error',
                                                     "text" => "Failed to create the issue:\n- Title can't be blank"
                                                   }
                                                 })
              end
            end

            context 'for show command' do
              it 'not hide issue by project path in personal chat' do
                issue = create(:issue, :confidential, project: project, title: 'confidential-issue')
                params = data.merge(text: { content: "#{project.full_path} issue show #{issue.iid}" })
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "Issue #{issue.to_reference}(Open)",
                                                     "text" => a_string_matching(<<~CONTENT)
                                                       - Title: #{issue.title}\n
                                                       - Author: #{user.name}\n
                                                       - Assignee: None\n
                                                       - Milestone: None\n
                                                       - Labels: None
                                                     CONTENT
                                                   }
                                                 })
              end

              it 'hide issue in group chat' do
                issue = create(:issue, :confidential, project: project, title: 'confidential-issue')
                params = data.merge(
                  text: { content: "#{project.full_path} issue show #{issue.iid}" },
                  conversationType: '2'
                )
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "Confidential issue #{issue.to_reference}",
                                                     "text" => a_string_matching(
                                                       "[Confidential issue #{issue.to_reference}]"
                                                     )
                                                   }
                                                 })
              end

              it 'no found issue' do
                params = data.merge(text: { content: "#{project.full_path} issue show 123" })
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "text",
                                                   "text" => { "content" => "I cannot not find the issue 123" }
                                                 })
              end
            end

            context 'for search command' do
              let(:project_alias_name) { 'jh-project-alias' }
              let(:project) do
                create(:project, creator_id: user.id, namespace: user.namespace).tap do |project|
                  create(:project_alias, project: project, name: project_alias_name)
                end
              end

              before do
                6.times do |i|
                  create(:issue, :confidential, project: project, title: "confidential-issue-#{i}")
                end
              end

              it 'not show confidential title in group channel' do
                params = data.merge(
                  text: { content: "#{project_alias_name} issue search issue" },
                  conversationType: '2'
                )
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "Issue search result",
                                                     "text" => a_string_matching("Here are the first 5 issues I found:")
                                                   }
                                                 })
                expect(json_response['markdown']['text']).not_to include('confidential-issue')
              end

              it 'show confidential title in personal channel' do
                params = data.merge(text: { content: "#{project.full_path} issue search issue" })
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "Issue search result",
                                                     "text" => a_string_matching("Here are the first 5 issues I found:")
                                                   }
                                                 })
                expect(json_response['markdown']['text']).to include('confidential-issue')
              end

              it 'empty search result' do
                params = data.merge(text: { content: "#{project.full_path} issue search wrong query" })
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "text",
                                                   "text" => {
                                                     "content" => "I cannot find any issue related to wrong query"
                                                   }
                                                 })
              end
            end

            context 'for move command' do
              let(:issue) { create(:issue, :confidential, project: project, title: 'confidential-issue') }
              let(:target_project) { create(:project, creator_id: user.id, namespace: user.namespace) }

              it 'success move' do
                params = data.merge(
                  text: { content: "#{project.full_path} issue move #{issue.iid} #{target_project.full_path}" }
                )

                allow_next_instance_of(::WorkItems::DataSync::MoveService, work_item: issue,
                  target_namespace: target_project.project_namespace,
                  current_user: user) do |service|
                  new_issue = create(:issue, project: target_project, title: issue.title)

                  allow(service).to receive(:execute).and_return(
                    OpenStruct.new( # rubocop:disable Style/OpenStructUse
                      error?: false,
                      message: nil,
                      work_item: new_issue
                    )
                  )
                end

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => /Issue #\d+\(Open\)/,
                                                     "text" => a_string_matching(<<~CONTENT)
                                                       - Title: #{issue.title}\n
                                                       - Author: #{user.name}\n
                                                       - Assignee: None\n
                                                       - Milestone: None\n
                                                       - Labels: None
                                                     CONTENT
                                                   }
                                                 })
              end

              it 'success move with project id' do
                params = data.merge(
                  text: { content: "#{project.full_path} issue move #{issue.iid} #{target_project.id}" }
                )

                allow_next_instance_of(::WorkItems::DataSync::MoveService, work_item: issue,
                  target_namespace: target_project.project_namespace,
                  current_user: user) do |service|
                  new_issue = create(:issue, project: target_project, title: issue.title)
                  allow(service).to receive(:execute).and_return(
                    OpenStruct.new( # rubocop:disable Style/OpenStructUse
                      error?: false,
                      message: nil,
                      work_item: new_issue
                    )
                  )
                end

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => /Issue #\d+\(Open\)/,
                                                     "text" => a_string_matching(<<~CONTENT)
                                                       - Title: #{issue.title}\n
                                                       - Author: #{user.name}\n
                                                       - Assignee: None\n
                                                       - Milestone: None\n
                                                       - Labels: None
                                                     CONTENT
                                                   }
                                                 })
              end

              it 'cannot move closed issue' do
                params = data.merge(
                  text: { content: "#{project.full_path} issue move #{issue.iid} #{target_project.full_path}" }
                )
                issue.close(user)

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "text",
                                                   "text" => { "content" => "I cannot move closed issue #{issue.iid}" }
                                                 })
              end

              it 'cannot move wrong target project' do
                params = data.merge(
                  text: { content: "#{project.full_path} issue move #{issue.iid} wrong-project-path" }
                )

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "text",
                                                   "text" => {
                                                     "content" => "I cannot found target project wrong-project-path"
                                                   }
                                                 })
              end
            end

            context 'for close command' do
              let(:issue) { create(:issue, :confidential, project: project, title: 'confidential-issue') }

              it 'return close confidential issue in personal channel' do
                params = data.merge(text: { content: "#{project.full_path} issue close #{issue.iid}" })

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "Issue #{issue.to_reference}(Closed)",
                                                     "text" => a_string_matching(<<~CONTENT)
                                                       - Title: #{issue.title}\n
                                                       - Author: #{user.name}\n
                                                       - Assignee: None\n
                                                       - Milestone: None\n
                                                       - Labels: None
                                                     CONTENT
                                                   }
                                                 })
                expect(issue.reset.closed?).to be(true)
              end

              it 'return close confidential issue in group channel' do
                params = data.merge(
                  text: { content: "#{project.full_path} issue close #{issue.iid}" },
                  conversationType: '2'
                )

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "Confidential issue #{issue.to_reference}",
                                                     "text" => a_string_matching("I closed an issue")
                                                   }
                                                 })
                expect(issue.reset.closed?).to be(true)
              end

              it 'cannot close already closed issue' do
                params = data.merge(text: { content: "#{project.full_path} issue close #{issue.iid}" })
                issue.close(user)

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "text",
                                                   "text" => {
                                                     "content" => "Issue #{issue.to_reference} is already closed."
                                                   }
                                                 })
              end
            end

            context 'for comment command' do
              let(:issue) { create(:issue, :confidential, project: project, title: 'confidential-issue') }

              it 'return note message when success' do
                params = data.merge(text: { content: "#{project.full_path} issue comment #{issue.iid}\nnew-comment" })

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "New comment on #{issue.to_reference}",
                                                     "text" => a_string_matching("new-comment")
                                                   }
                                                 })
                expect(issue.reset.notes.length).to eq 1
              end

              it 'return access denied when no create note permission' do
                params = data.merge(text: { content: "#{project.full_path} issue comment #{issue.iid}\nnew-comment" })

                allow(Ability).to receive(:allowed?) do |_, ability, _|
                  ability != :create_note
                end
                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "text",
                                                   "text" => {
                                                     "content" => "You are not allowed to perform bot commands."
                                                   }
                                                 })
              end

              it 'return error message' do
                allow_next_instance_of(::Notes::CreateService) do |service|
                  wrong_note = build(:note, note: '', noteable: issue, project: project)
                  wrong_note.valid?
                  allow(service).to receive(:execute).and_return(wrong_note)
                end

                params = data.merge(text: { content: "#{project.full_path} issue comment #{issue.iid}\nnew-comment" })

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "error",
                                                     "text" => "Failed to create the comment:\n- Note can't be blank"
                                                   }
                                                 })
              end

              it 'return correct quick action result' do
                allow_next_instance_of(::Notes::CreateService) do |service|
                  wrong_note = build(:note, note: '', noteable: issue, project: project)
                  wrong_note.errors.add(:commands_only, "Set time estimate to 1d. Added 1h spent time")
                  wrong_note.errors.add(:command_names, [:estimate, :spend])
                  allow(service).to receive(:execute).and_return(wrong_note)
                end

                params = data.merge(text: {
                  content: "#{project.full_path} issue comment #{issue.iid}\n/estimate 1d\n/spent 1h"
                })

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "Quick actions on ##{issue.iid}",
                                                     "text" => a_string_matching(<<~CONTENT)
                                                       - Set time estimate to 1d
                                                       - Added 1h spent time
                                                     CONTENT
                                                   }
                                                 })
              end

              it 'return error for quick action result' do
                allow_next_instance_of(::Notes::CreateService) do |service|
                  wrong_note = build(:note, note: '', noteable: issue, project: project)
                  wrong_note.errors.add(:commands_only, "wrong commands")
                  wrong_note.errors.add(:commands, "wrong commands")
                  allow(service).to receive(:execute).and_return(wrong_note)
                end

                params = data.merge(text: {
                  content: "#{project.full_path} issue comment #{issue.iid}\n/estimate wrong-argument"
                })

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "error",
                                                     "text" => "Failed to create the comment:\n" \
                                                       "- Failed to apply quick commands."
                                                   }
                                                 })
              end
            end
          end

          context 'for deploy' do
            let(:project) { create(:project, :repository, creator_id: user.id, namespace: user.namespace) }

            it 'action not found' do
              params = data.merge(text: { content: "#{project.full_path} deploy qa to production" })

              post api(path), params: params, headers: headers

              expect(response).to have_gitlab_http_status(:ok)
              expect(json_response).to include({
                                                 "msgtype" => "text",
                                                 "text" => { "content" => "Couldn't find a deployment manual action." }
                                               })
            end

            it 'return deployment start' do
              project.add_developer(user)
              create(:protected_branch, :developers_can_merge, name: 'master', project: project)

              staging = create(:environment, name: 'staging', project: project)
              pipeline = create(:ci_pipeline, project: project)
              build = create(:ci_build, pipeline: pipeline)
              create(:deployment, :success, environment: staging, deployable: build)

              create(:ci_build, :manual, pipeline: pipeline, name: 'first', environment: 'production')

              params = data.merge(text: { content: "#{project.full_path} deploy staging to production" })

              post api(path), params: params, headers: headers

              expect(response).to have_gitlab_http_status(:ok)
              expect(json_response).to include({
                                                 "msgtype" => "markdown",
                                                 "markdown" => {
                                                   "title" => "deployment started",
                                                   "text" => /Deployment started from staging to production/
                                                 }
                                               })
            end

            it 'return error' do
              project = create(:project, :repository, :builds_disabled, creator_id: user.id, namespace: user.namespace)
              params = data.merge(text: { content: "#{project.full_path} deploy staging to production" })

              post api(path), params: params, headers: headers
              expect(response).to have_gitlab_http_status(:ok)
              expect(json_response).to include({
                                                 "msgtype" => "text",
                                                 "text" => {
                                                   "content" => "I cannot understand your command. " \
                                                     "Type \"help\" to view all commands."
                                                 }
                                               })
            end
          end

          context 'for run' do
            let(:project) { create(:project, :repository, creator_id: user.id, namespace: user.namespace) }
            let(:pipeline) { create(:ci_pipeline, project: project) }
            let(:build) { create(:ci_build, pipeline: pipeline) }

            before do
              project.add_developer(user)
              create(:protected_branch, :developers_can_merge, name: 'master', project: project)
            end

            context 'when a pipeline could not be scheduled' do
              it 'returns an error' do
                expect_next_instance_of(::Gitlab::Chat::Command) do |instance|
                  expect(instance).to receive(:try_create_pipeline).and_return(nil)
                end

                params = data.merge(text: { content: "#{project.full_path} run wrong-job" })

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "text",
                                                   "text" => {
                                                     "content" => 'The command could not be scheduled. ' \
                                                       'Please confirm the ".gitlab-ci.yml" file ' \
                                                       'defines a job with the name wrong-job.'
                                                   }
                                                 })
              end
            end

            context 'when a pipeline could be created but the chat service was not supported' do
              it 'returns an error' do
                expect_next_instance_of(Gitlab::Chat::Command) do |instance|
                  expect(instance).to receive(:try_create_pipeline).and_return(pipeline)
                end
                expect(Gitlab::Chat::Responder).to receive(:responder_for).with(build).and_return(nil)

                params = data.merge(text: { content: "#{project.full_path} run unit-test" })

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "text",
                                                   "text" => {
                                                     "content" => 'Sorry, this chat service is currently not ' \
                                                       'supported by JiHu GitLab ChatOps.'
                                                   }
                                                 })
              end
            end

            context 'when using a valid pipeline' do
              it 'schedules the pipeline' do
                responder = Gitlab::Chat::Responder::Dingtalk.new(build)

                expect_next_instance_of(Gitlab::Chat::Command) do |instance|
                  expect(instance).to receive(:try_create_pipeline).and_return(pipeline)
                end

                expect(Gitlab::Chat::Responder)
                  .to receive(:responder_for)
                        .with(build)
                        .and_return(responder)

                params = data.merge(text: { content: "#{project.full_path} run unit-test" })

                post api(path), params: params, headers: headers

                expect(response).to have_gitlab_http_status(:ok)
                expect(json_response).to include({
                                                   "msgtype" => "markdown",
                                                   "markdown" => {
                                                     "title" => "Job created",
                                                     "text" => /Your ChatOps job \[#\d+\]\(.+\) has been created!/
                                                   }
                                                 })
              end
            end
          end
        end
      end
    end
  end
end
