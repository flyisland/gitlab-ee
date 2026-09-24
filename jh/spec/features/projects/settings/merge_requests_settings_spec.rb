# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects > Settings > Merge requests', feature_category: :groups_and_projects do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  before_all do
    project.add_maintainer(user)
  end

  before do
    sign_in(user)
    visit(project_settings_merge_requests_path(project))
  end

  context 'with single squash merge', :js do
    it 'shows "Single squash merge" strategy' do
      page.within '.merge-request-settings-form' do
        expect(page).to have_content s_('JH|ProjectSettings|Single squash merge commit')
      end
    end

    it 'sets squash_option to always automatically' do
      choose('project_merge_method_single_squash_merge')

      within('.merge-request-settings-form') do
        find('.rspec-save-merge-request-changes')
        click_on('Save changes')
      end

      find('.flash-notice')

      radio = find_field('project_project_setting_attributes_squash_option_always', disabled: true)

      expect(radio).to be_checked
      expect(project.reset.project_setting.squash_option).to eq('always')
    end
  end
end
