# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Organizations::ArtifactRegistryController, feature_category: :artifact_registry do
  let_it_be(:organization) { create(:organization) }

  it 'declares the artifact_registry feature category for #index' do
    expect(described_class.feature_category_for_action('index')).to eq(:artifact_registry)
  end

  describe 'GET #index' do
    subject(:gitlab_request) { get artifact_registry_organization_index_path(organization) }

    context 'when the user is not signed in' do
      it_behaves_like 'organization - redirects to sign in page'

      context 'when `ui_for_organizations` feature flag is disabled' do
        before do
          stub_feature_flags(ui_for_organizations: false)
        end

        it_behaves_like 'organization - redirects to sign in page'
      end
    end

    context 'when the user is signed in' do
      let_it_be(:user) { create(:user) }

      before do
        sign_in(user)
      end

      context 'with no association to the organization' do
        it_behaves_like 'organization - not found response'
        it_behaves_like 'organization - action disabled by ui_for_organizations_enabled?'
      end

      context 'as an admin', :enable_admin_mode do
        let_it_be(:user) { create(:admin) }

        it_behaves_like 'organization - successful response'
        it_behaves_like 'organization - action disabled by ui_for_organizations_enabled?'
      end

      context 'as a default organization user' do
        before_all do
          create(:organization_user, organization: organization, user: user)
        end

        it_behaves_like 'organization - successful response'
        it_behaves_like 'organization - action disabled by ui_for_organizations_enabled?'

        context 'when the `artifact_registry_ui` feature flag is disabled' do
          before do
            stub_feature_flags(artifact_registry_ui: false)
          end

          it_behaves_like 'organization - not found response'
        end
      end

      context 'as an owner of an organization' do
        before_all do
          create(:organization_user, :owner, organization: organization, user: user)
        end

        it_behaves_like 'organization - successful response'
        it_behaves_like 'organization - action disabled by ui_for_organizations_enabled?'
      end
    end
  end
end
