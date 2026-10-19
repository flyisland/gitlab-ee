# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Pages edits pages settings', :js, feature_category: :pages do
  include Spec::Support::Helpers::ModalHelpers

  let_it_be_with_reload(:project) { create(:project, :pages_published, pages_https_only: false) }
  let_it_be(:user) { create(:user) }

  before_all do
    project.add_maintainer(user)
  end

  before do
    allow(Gitlab.config.pages).to receive(:enabled).and_return(true)
    stub_feature_flags(show_pages_in_deployments_menu: false)

    sign_in(user)
  end

  context 'when user is the owner' do
    before do
      project.namespace.update!(owner: user)
    end

    context 'when pages deployed' do
      before do
        create(:pages_deployment, project: project)
      end

      context 'when access control is enabled in gitlab settings' do
        before do
          stub_pages_setting(access_control: true)
        end

        context 'when disable public access' do
          before do
            allow(::Gitlab::Pages).to receive(:access_control_is_forced?).and_return(true)
          end

          context 'when in saas', :saas do
            it 'does not renders access control warning' do
              visit project_pages_path(project)

              expect(page).not_to have_content('Access Control is enabled for this Pages website')
            end
          end
        end
      end
    end
  end
end
