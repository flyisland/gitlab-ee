# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::ApplicationSettingsController do
  let(:admin) { create(:admin) }

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
  end

  describe 'PUT #update' do
    before do
      sign_in(admin)
    end

    context 'when updating password expiration settings' do
      using RSpec::Parameterized::TableSyntax
      let(:settings) do
        {
          password_expiration_enabled: true,
          password_expires_in_days: 100,
          password_expires_notice_before_days: 17
        }
      end

      where(:licensed_feature, :changed) do
        true        |   true
        false       |   false
      end

      with_them do
        it 'works as expected' do
          stub_licensed_features(password_expiration: licensed_feature)
          attribute_names = settings.keys.map(&:to_s)
          if changed
            expect { put :update, params: { application_setting: settings } }
              .to change { ApplicationSetting.current.reset.attributes.slice(*attribute_names) }
          else
            expect { put :update, params: { application_setting: settings } }
              .not_to change { ApplicationSetting.current.reset.attributes.slice(*attribute_names) }
          end
        end
      end
    end
  end
end
