# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'JH Merge request Duo actions', :js, feature_category: :code_review_workflow do
  let_it_be(:user) { create(:user, :with_namespace) }
  let_it_be(:duo_user) { ::Users::Internal.duo_code_review_bot } # rubocop:disable Gitlab/UsersInternalOrganization -- Just for testing
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:merge_request) do
    create(:merge_request, source_project: project, target_project: project)
  end

  before_all do
    project.add_maintainer(user)
    project.add_developer(duo_user)
  end

  before do
    sign_in(user)

    allow(Ability).to receive(:allowed?).and_wrap_original do |m, *args|
      _user_arg, ability, _subject, *_rest = args
      if ability == :access_summarize_new_merge_request
        true
      else
        m.call(*args)
      end
    end

    allow(Gitlab::Duo::CodeReview).to receive(:enabled?).and_return(true)

    allow(Llm::SummarizeNewMergeRequestService).to receive(:new).and_return(
      instance_double(
        Llm::SummarizeNewMergeRequestService,
        execute: ServiceResponse.error(message: Llm::BaseService::INVALID_MESSAGE)
      )
    )
  end

  it 'shows two action buttons on MR page' do
    visit(merge_request_path(merge_request))

    expect(page).to have_selector('.js-noteable-awards')
    expect(page).to have_selector('.js-assign-to-gitlabduo')
    expect(page).to have_selector('.js-summarize-code-changes')
  end

  context 'when duo review is disabled' do
    before do
      allow(Gitlab::Duo::CodeReview).to receive(:enabled?).and_return(false)
    end

    it 'does not show Assign to @GitLabDuo button' do
      visit(merge_request_path(merge_request))
      expect(page).to have_selector('.js-noteable-awards')
      expect(page).not_to have_selector('.js-assign-to-gitlabduo')
    end
  end

  context 'when summarize code changes is disabled' do
    before do
      allow(Ability).to receive(:allowed?).and_wrap_original do |m, *args|
        _user_arg, ability, _subject, *_rest = args
        if ability == :access_summarize_new_merge_request
          false
        else
          m.call(*args)
        end
      end
    end

    it 'does not show Summarize code changes button' do
      visit(merge_request_path(merge_request))
      expect(page).to have_selector('.js-noteable-awards')
      expect(page).not_to have_selector('.js-summarize-code-changes')
    end
  end

  context 'when feature flag is disabled' do
    before do
      stub_feature_flags(jh_ai_quick_buttons_on_mr: false)
    end

    it 'does not show any Duo action buttons' do
      visit(merge_request_path(merge_request))
      expect(page).to have_selector('.js-noteable-awards')
      expect(page).not_to have_selector('.js-summarize-code-changes')
      expect(page).not_to have_selector('.js-assign-to-gitlabduo')
    end
  end

  it 'assigns reviewer to @GitLabDuo on click' do
    visit(merge_request_path(merge_request))

    find('.js-assign-to-gitlabduo').click

    expect(page).to have_content('Requested review')

    expect(merge_request.reload.reviewers.map(&:id)).to include(duo_user.id)
  end

  it 'navigates to edit and auto-triggers summarize' do
    visit(merge_request_path(merge_request))

    find('.js-summarize-code-changes').click

    expected_path = edit_project_merge_request_path(project, merge_request)

    expect(page).to have_current_path(/#{Regexp.escape(expected_path)}/)

    expect(page).to have_selector('[data-testid="summarize-button"]')

    client_subscription_id = page.evaluate_script(<<~JS)
      (() => {
        const span = document
          .querySelector('[data-testid="summarize-button"]')
          .closest('span');
        const vm = span && span.__vue__;
        if (!vm) return null;
        const vars = vm.$options.apollo.$subscribe.aiCompletionResponse.variables.call(vm);
        return vars.clientSubscriptionId;
      })()
    JS
    expect(client_subscription_id).to be_present

    content = 'Mock AI summary content'
    GitlabSchema.subscriptions.trigger(
      :ai_completion_response,
      { user_id: user.to_gid, resource_id: project.to_gid, client_subscription_id: client_subscription_id },
      { request_id: 'test', content: content, role: 'ASSISTANT', errors: [] }
    )

    page.evaluate_script(<<~JS)
      (() => {
        const span = document
          .querySelector('[data-testid="summarize-button"]')
          .closest('span');
        const vm = span && span.__vue__;
        if (!vm) return;
        vm.$options.apollo.$subscribe.aiCompletionResponse.result.call(vm, {
          data: { aiCompletionResponse: { content: "#{content}" } },
        });
      })()
    JS

    using_wait_time 10 do
      expect(find('textarea.js-gfm-input').value).to include(content)
    end
  end
end
