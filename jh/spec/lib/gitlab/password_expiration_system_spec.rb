# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::PasswordExpirationSystem do
  describe '.enabled?' do
    using RSpec::Parameterized::TableSyntax

    where(:licensed_feature, :application_setting, :enable) do
      true  | true  | true
      false | true  | false
      true  | false | false
    end

    with_them do
      before do
        stub_licensed_features(password_expiration: licensed_feature)
        stub_application_setting(password_expiration_enabled: application_setting)
      end

      it { expect(described_class.enabled?).to be enable }
    end
  end
end
