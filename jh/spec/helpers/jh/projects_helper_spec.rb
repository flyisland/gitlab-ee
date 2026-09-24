# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectsHelper, feature_category: :source_code_management do
  include ProjectForksHelper
  include AfterNextHelpers

  let_it_be_with_reload(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  before do
    helper.instance_variable_set(:@project, project)
  end

  describe '#project_permissions_panel_data', :saas do
    subject(:data) { helper.project_permissions_panel_data(project) }

    before do
      allow(helper).to receive_messages(can?: true, current_user: user)
      stub_config(pages: { access_control: true, enabled: true })
      allow(::Gitlab::Pages).to receive(:access_control_is_forced?).and_return(true)
    end

    it 'force set disable pages access control' do
      expect(data).to include(pagesAccessControlEnabled: false)
    end

    it 'do not force set pages access control when jh_hide_pages_access_level is false' do
      stub_feature_flags(jh_hide_pages_access_level: false)
      expect(data).to include(pagesAccessControlEnabled: true)
    end

    it 'disable saas pages available if jh_pages is off' do
      stub_feature_flags(jh_pages: false)
      expect(data).to include(pagesAvailable: false)
    end

    it 'disable pages available if jh_pages is off and jh_hide_pages_access_level is false' do
      stub_feature_flags(jh_hide_pages_access_level: false)
      stub_feature_flags(jh_pages: false)
      expect(data).to include(pagesAvailable: false)
    end
  end
end
