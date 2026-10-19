# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects settings' do
  before do
    stub_feature_flags(new_project_creation_form: false)
  end

  context 'as public project', :js, :saas do
    let(:project) { create(:project, :public) }
    let(:user) { project.first_owner }

    it 'does not show project terms' do
      sign_in(user)
      visit edit_project_path(project)

      expect(page).not_to have_selector('[data-testid="project-setting-terms"]')

      find(".project-visibility-setting option[value='10']").select_option
      expect(page).not_to have_selector('[data-testid="project-setting-terms"]')
    end
  end

  context 'as private project', :js, :saas do
    let(:project) { create(:project, :private) }
    let(:user) { project.first_owner }

    it 'shows project terms after changed to public' do
      sign_in(user)
      visit edit_project_path(project)

      expect(page).not_to have_selector('[data-testid="jproject-setting-terms"]')

      find(".project-visibility-setting option[value='20']").select_option
      expect(page).to have_selector('[data-testid="project-setting-terms"]')
    end
  end
end
