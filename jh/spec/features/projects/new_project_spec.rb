# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'New project', :js, feature_category: :groups_and_projects do
  let(:terms_selector) { '[data-testid="new-project-terms"]' }
  let(:jihu_term_selector) { '#project_agree_jihu_terms' }

  context 'as a user' do
    let(:user) { create(:user, :with_namespace) }

    before do
      stub_application_setting(import_sources: Gitlab::ImportSources.values)
      stub_ee_application_setting(custom_project_templates_enabled: true)
      sign_in(user)
    end

    it 'shows terms when create blank project', :js, :saas do
      visit new_project_path

      click_link 'Create blank project'
      expect(page).to have_no_selector(terms_selector)

      choose 'Public'
      expect(page).to have_selector(terms_selector)

      click_button 'Create project'
      message = page.find(jihu_term_selector).native.attribute("validationMessage")
      expect(message).not_to be_empty

      choose 'Private'
      expect(page).to have_no_selector(terms_selector)
    end

    it 'shows terms on the import project by url page', :js, :saas do
      visit new_project_path

      click_link 'Import project'
      click_link 'Repository by URL'
      wait_for_requests # rubocop:disable RSpec/AvoidWaitForRequests
      expect(page).to have_current_path(new_import_url_path, ignore_query: true)
      expect(page).to have_no_selector(terms_selector)

      fill_in 'project[import_url]', with: 'https://example.com/group/project.git'
      send_keys(:tab)
      fill_in 'Project name', with: 'Imported project'

      choose 'Public'
      expect(page).to have_selector(terms_selector)
      expect(page).to have_button('Create project', disabled: false)

      click_button 'Create project'
      message = page.find(jihu_term_selector).native.attribute("validationMessage")
      expect(message).not_to be_empty

      choose 'Private'
      expect(page).to have_no_selector(terms_selector)
    end

    it 'shows terms when create project from template', :js, :saas do
      visit new_project_path

      click_link 'Create from template'
      find('span', text: 'Use template', match: :first).click
      expect(page).to have_no_selector(terms_selector)

      choose 'Public'
      expect(page).to have_selector(terms_selector)

      click_button 'Create project'
      message = page.find(jihu_term_selector).native.attribute("validationMessage")
      expect(message).not_to be_empty

      choose 'Private'
      expect(page).to have_no_selector(terms_selector)
    end

    context 'when creating CI/CD for external repositories', :js, :saas do
      before do
        stub_licensed_features(ci_cd_projects: true)
      end

      it 'creates CI/CD project from repo URL', :sidekiq_might_not_need_inline do
        visit new_project_path
        click_link 'Run CI/CD for external repository'

        page.within '#ci-cd-project-pane' do
          find('.js-import-git-toggle-button').click

          choose 'Public'
          expect(page).to have_selector(terms_selector)

          click_button 'Create project'
          message = page.find(jihu_term_selector).native.attribute("validationMessage")
          expect(message).not_to be_empty

          choose 'Private'
          expect(page).to have_no_selector(terms_selector)
        end
      end
    end

    it 'can creat new project when terms agreed', :js, :saas do
      group = create(:group)
      group.add_owner(user)

      visit new_project_path(namespace_id: group.id)

      click_link 'Create blank project'
      fill_in(:project_name, with: 'Project with terms agreed')

      choose 'Public'
      check 'project_agree_jihu_terms'
      check 'project_agree_intellectual_property'
      click_button 'Create project'

      expect(page).to have_content('was successfully created')

      project = Project.last
      expect(project).to be_present
      expect(page).to have_current_path(project_path(project))
    end
  end
end
