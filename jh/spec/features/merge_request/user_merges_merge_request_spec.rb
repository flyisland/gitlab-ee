# frozen_string_literal: true

require "spec_helper"

RSpec.describe "User merges a merge request with single squash merge",
  :js, :sidekiq_inline, feature_category: :code_review_workflow do
  let_it_be(:user) { create(:user, :with_namespace) }

  let(:project) { create(:project, :public, :repository) }

  let!(:merge_request) do
    create(:merge_request,
      source_project: project, source_branch: 'feature',
      target_project: project, target_branch: 'master')
  end

  let!(:merge_request_other) do
    create(:merge_request,
      source_project: project, source_branch: 'branch-1',
      target_project: project, target_branch: 'master')
  end

  before do
    project.merge_method = :single_squash_merge
    project.add_maintainer user
    project.save!

    sign_in(user)
    visit(merge_request_path(merge_request))
  end

  it 'adds a new single squash commit to target branch' do
    expect_opened_mr_count 2
    expect { click_merge_button }.to change { master_commit_count }.by(1)
    refresh
    expect_opened_mr_count 1
  end

  def click_merge_button
    page.within('.mr-state-widget') do
      click_button 'Merge'
    end

    expect(page).to have_selector('.gl-badge', text: 'Merged')
  end

  def expect_opened_mr_count(number)
    within_testid 'pinned-nav-items' do
      within(find_link(text: 'Merge requests')) do
        expect(page).to have_selector('[data-testid="pill-badge"]', text: number.to_s)
      end
    end
  end

  def master_commit_count
    project.repository.raw_repository.count_commits(revisions: 'master')
  end
end
