# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Settings, 'JH Settings', :do_not_mock_admin_mode_setting, feature_category: :shared do
  let(:admin) { create(:admin) }
  let_it_be(:default_organization) { create(:organization) }

  before do
    stub_application_setting(admin_mode: false)
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    allow(::Organizations::Organization).to receive(:default_organization).and_return(default_organization)
  end

  describe 'password expiration settings' do
    using RSpec::Parameterized::TableSyntax
    let(:settings) do
      {
        password_expiration_enabled: true,
        password_expires_in_days: 100,
        password_expires_notice_before_days: 17
      }
    end

    let(:attribute_names) { settings.keys.map(&:to_s) }

    where(:licensed_feature, :visible) do
      true    |   true
      false   |   false
    end

    with_them do
      before do
        stub_licensed_features(password_expiration: licensed_feature)
        # Make sure the settings exist before the specs
        get api("/application/settings", admin)
      end

      it 'works as expected' do
        get api("/application/settings", admin)
        expect(response).to have_gitlab_http_status(:ok)

        if visible
          expect(json_response.keys).to include(*attribute_names)
        else
          expect(json_response.keys).not_to include(*attribute_names)
        end
      end

      it 'works as expected' do
        if visible
          expect { put api("/application/settings", admin), params: settings }
            .to change { ApplicationSetting.current.reset.attributes.slice(*attribute_names) }
        else
          expect { put api("/application/settings", admin), params: settings }
            .not_to change { ApplicationSetting.current.reset.attributes.slice(*attribute_names) }
        end
      end
    end
  end
end
