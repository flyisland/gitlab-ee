# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/application_settings/network.html.haml', feature_category: :groups_and_projects do
  let_it_be(:admin) { build_stubbed(:admin) }
  let_it_be(:application_setting) { build(:application_setting) }

  before do
    assign(:application_setting, application_setting)
    allow(view).to receive(:current_user) { admin }
  end

  context 'for audit events API rate limit settings' do
    context 'when licensed' do
      let(:expected_rate_limit) { 150 }
      let(:application_setting) { build(:application_setting, audit_events_api_limit: expected_rate_limit) }

      before do
        stub_licensed_features(admin_audit_log: true)
      end

      it 'renders the field with the configured value' do
        render

        expect(rendered).to have_content('Audit events API rate limits')
        expect(rendered).to have_field('application_setting_audit_events_api_limit', with: expected_rate_limit.to_s)
      end
    end

    context 'when not licensed' do
      before do
        stub_licensed_features(admin_audit_log: false)
      end

      it 'does not render the field' do
        render

        expect(rendered).not_to have_field('application_setting_audit_events_api_limit')
      end
    end
  end

  context 'for Observability backend settings' do
    context 'when licensed' do
      before do
        stub_licensed_features(observability: true)
      end

      context 'when flag enabled' do
        it 'renders the field correctly' do
          render

          expect(rendered).to have_field('application_setting_observability_backend_ssl_verification_enabled')
        end
      end

      context 'when flag disabled' do
        before do
          stub_feature_flags(observability_features: false)
        end

        it 'does not render the field' do
          render

          expect(rendered).not_to have_field('application_setting_observability_backend_ssl_verification_enabled')
        end
      end
    end

    context 'when not licensed' do
      before do
        stub_licensed_features(observability: false)
      end

      context 'when flag enabled' do
        it 'does not render the field' do
          render

          expect(rendered).not_to have_field('application_setting_observability_backend_ssl_verification_enabled')
        end
      end

      context 'when flag disabled' do
        before do
          stub_feature_flags(observability_features: false)
        end

        it 'does not render the field' do
          render

          expect(rendered).not_to have_field('application_setting_observability_backend_ssl_verification_enabled')
        end
      end
    end
  end
end
