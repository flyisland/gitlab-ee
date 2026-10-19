# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Path Locks', :js, feature_category: :source_code_management do
  include Spec::Support::Helpers::ModalHelpers

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:project) { create(:project, :repository, namespace: user.namespace) }
  let(:tree_path) { project_tree_path(project, project.repository.root_ref) }

  before do
    project.add_maintainer(user)
    project.add_developer(other_user)
    sign_in(user)

    visit tree_path

    wait_for_requests
  end

  # The file and directory lock flows with repository_lock_information enabled
  # are covered by the frontend integration specs in
  # ee/spec/frontend/integration/repository/path_locks_tree_spec.js and
  # ee/spec/frontend/integration/repository/path_locks_blob_spec.js.
  context 'when repository_lock_information feature flag is disabled' do
    before do
      stub_feature_flags(repository_lock_information: false)

      visit tree_path

      wait_for_requests
    end

    it 'locks files from the file actions dropdown' do
      within find('.tree-content-holder') do
        click_link "VERSION"
      end

      within_testid('blob-controls') do
        click_button 'File actions'
        click_button 'Lock'
      end

      within_modal do
        click_button 'Lock'
      end

      visit tree_path
      expect(page).to have_css("[aria-label='Locked by #{user.username}']")

      sign_in other_user
      visit project_blob_path(project, File.join('master', 'VERSION'))
      click_button 'File actions'
      expect(page).to have_button('Unlock', disabled: true)
    end

    it 'unlocks files from the file actions dropdown' do
      create(:path_lock, path: 'VERSION', user: user, project: project)

      visit project_blob_path(project, File.join('master', 'VERSION'))

      within_testid('blob-controls') do
        click_button 'File actions'
        click_button 'Unlock'
      end

      within_modal do
        click_button 'Unlock'
      end

      visit tree_path
      expect(page).to have_no_css("[aria-label='Locked by #{user.username}']")
    end

    it 'locking folders with the legacy lock button' do
      within '.tree-content-holder' do
        click_link "encoding"
      end

      click_button 'Lock'

      within_modal do
        click_button 'Ok'
      end

      expect(page).to have_button('Unlock')
    end
  end

  it 'managing of lock list' do
    create :path_lock, path: 'encoding', user: user, project: project

    click_link "Locked files"

    within '.js-path-locks' do
      expect(page).to have_content('encoding')
    end

    click_link "Unlock"

    accept_gl_confirm('Are you sure you want to unlock encoding?')

    expect(page).not_to have_content('encoding')
  end
end
