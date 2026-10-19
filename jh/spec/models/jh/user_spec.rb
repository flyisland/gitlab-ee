# frozen_string_literal: true

require 'spec_helper'

RSpec.describe User do
  include RandomNumberString

  describe '#duo_entitlement', feature_category: :ai_abstraction_layer do
    let_it_be(:user) { create(:user) }
    let_it_be(:self_hosted_model) { create(:ai_self_hosted_model) }
    let_it_be(:feature_setting) do
      create(:ai_feature_setting, feature: :duo_agent_platform, self_hosted_model: self_hosted_model)
    end

    let(:license) { instance_double(License, offline_cloud_license?: true, online_cloud_license?: false) }
    let(:unit_primitive) do
      build(:cloud_connector_unit_primitive, name: :self_hosted_models, add_ons: %w[duo_enterprise])
    end

    subject(:entitlement) { user.duo_entitlement(:duo_agent_platform, feature_setting: feature_setting) }

    before do
      allow(License).to receive(:current).and_return(license)
      allow(license).to receive(:feature_available?).with(:amazon_q).and_return(false)
      allow(unit_primitive).to receive(:cut_off_date).and_return(1.month.ago)
      allow(Gitlab::CloudConnector::DataModel::UnitPrimitive).to receive(:find_by_name)
        .with(:self_hosted_models).and_return(unit_primitive)
      stub_licensed_features(ai_features: false)
    end

    it { is_expected.not_to be_allowed }

    context 'with a Duo Enterprise purchase' do
      let_it_be_with_reload(:purchase) do
        create(:gitlab_subscription_add_on_purchase, :self_managed, :duo_enterprise)
      end

      it { is_expected.not_to be_allowed }

      context 'with an assigned seat' do
        before do
          create(:gitlab_subscription_user_add_on_assignment, user: user, add_on_purchase: purchase)
        end

        it 'grants access through Duo Enterprise' do
          expect(entitlement).to eq(Ai::UserAuthorizable::Response.new(
            allowed?: true, namespace_ids: [], enablement_type: 'duo_enterprise', authorized_by_duo_core: false
          ))
        end

        context 'with an expired purchase' do
          before do
            purchase.update!(expires_on: 1.day.ago)
          end

          it { is_expected.not_to be_allowed }
        end
      end
    end

    context 'with a DAP self-hosted purchase' do
      let_it_be(:purchase) do
        create(:gitlab_subscription_add_on_purchase, :self_managed, :self_hosted_dap)
      end

      it 'grants access without a seat or unit primitive lookup', :aggregate_failures do
        expect(Gitlab::CloudConnector::DataModel::UnitPrimitive).not_to receive(:find_by_name)
        expect(entitlement).to be_allowed
        expect(entitlement.enablement_type).to eq('self_hosted_dap')
      end
    end

    context 'with an online cloud license' do
      let(:license) { instance_double(License, offline_cloud_license?: false, online_cloud_license?: true) }

      it 'grants access through usage billing', :aggregate_failures do
        expect(Gitlab::CloudConnector::DataModel::UnitPrimitive).not_to receive(:find_by_name)
        expect(entitlement).to be_allowed
        expect(entitlement.enablement_type).to eq('self_hosted_usage_billing')
      end
    end
  end

  describe 'validations' do
    it_behaves_like "content validation", :user, :name
  end

  describe 'when password is not strong enough' do
    subject { build(:user, password: '123456', password_confirmation: '123456') }

    before do
      allow(Gitlab::CurrentSettings).to receive(:password_uppercase_required).and_return(true)
      stub_licensed_features(password_complexity: true)
    end

    it { is_expected.not_to be_valid }
  end

  describe 'when password is strong enough by default' do
    subject do
      build(:user)
    end

    it { is_expected.to be_valid }
  end

  describe '.by_encrypted_phone' do
    let(:phone) { '+8615612341234' }
    let(:phone_2) { '+8615612341235' }
    let!(:user) { create :user, phone: ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }
    let!(:user_2) { create :user, phone: ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone_2) }

    it 'could find user by phone number' do
      expect(described_class.by_encrypted_phone(phone).take.id).to eq user.id
    end

    context 'when querying with empty phone' do
      it 'returns nil' do
        expect(described_class.by_encrypted_phone('').exists?).to be false
      end
    end
  end

  describe '.find_for_database_authentication' do
    let(:phone_without_area_code) { '15612341234' }
    let(:phone) { "+86#{phone_without_area_code}" }
    let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }

    context 'when user without phone' do
      let!(:user) { create(:user) }

      it 'could find user by username or email' do
        expect(described_class.find_for_database_authentication({ login: user.username })).to eq user
        expect(described_class.find_for_database_authentication({ login: " #{user.email} " })).to eq user
      end
    end

    context 'when it is not JH COM' do
      let!(:user) { create(:user, phone: encrypted_phone) }

      it 'allows user to sign in' do
        expect(described_class.find_for_database_authentication({ login: " #{user.username} " })).to eq user
        expect(described_class.find_for_database_authentication({ login: user.email })).to eq user
      end

      it 'does not allow user to sign in with phone number' do
        expect(described_class.find_for_database_authentication({ login: phone })).to be_nil
      end
    end

    context 'when it is JH COM' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
        create_list :user, 2
      end

      let!(:user) { create(:user, phone: encrypted_phone) }

      it 'allows user to sign in with phone' do
        expect(described_class.find_for_database_authentication({ login: " #{phone} " })).to eq user
      end

      context 'with other conditions' do
        it 'could find user by phone number' do
          expect(described_class.find_for_database_authentication({ username: user.username, login: phone })).to eq user
          expect(described_class.find_for_database_authentication({ username: 'not exists', login: phone })).to be_nil
        end
      end

      context 'when querying a non-existing user' do
        it 'returns nothing' do
          expect(described_class.find_for_database_authentication({ login: '' })).to be_nil
          expect(described_class.find_for_database_authentication({ login: 'something else' })).to be_nil
        end
      end

      context 'without area code' do
        context 'when it is a mainland phone number' do
          it 'returns the user instance' do
            expect(described_class).to receive(:by_encrypted_phone).and_call_original
            expect(described_class.find_for_database_authentication({ login: phone_without_area_code })).to eq user
          end
        end
      end

      context 'with area code specified' do
        it 'returns the user instance' do
          expect(described_class).to receive(:by_encrypted_phone).and_call_original

          expect(phone.start_with?('+')).to be true
          expect(described_class.find_for_database_authentication({ login: phone })).to eq user
        end
      end
    end
  end

  describe 'user login' do
    let(:phone_without_area_code) { '15612341234' }
    let(:phone) { "+86#{phone_without_area_code}" }
    let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }
    let!(:user) { create(:user, phone: encrypted_phone) }
    let!(:user_list) { create_list(:user, 2) }

    describe '.find_by_login' do
      shared_examples_for 'finding-user-by-email-or-username' do
        context 'when login with email' do
          it 'returns the user' do
            expect(described_class.find_by_login(user.email).id).to be user.id
          end
        end

        context 'when login with username' do
          it 'returns the user' do
            expect(described_class.find_by_login(user.username).id).to be user.id
          end
        end
      end

      context 'when it is not JH COM' do
        before do
          allow(::Gitlab).to receive(:com?).and_return(false)
        end

        context 'when login with phone' do
          it 'returns nothing' do
            expect(described_class.find_by_login(phone)).to be_nil
          end
        end

        it_behaves_like 'finding-user-by-email-or-username'
      end

      context 'when it is JH COM' do
        before do
          allow(::Gitlab).to receive_messages(jh?: true, com?: true)
        end

        context 'when login with phone' do
          it 'returns the user' do
            expect(described_class.find_by_login(phone).id).to be user.id
            expect(described_class.find_by_login(phone_without_area_code).id).to be user.id
          end
        end

        it_behaves_like 'finding-user-by-email-or-username'
      end

      context 'when phone_authenticatable feature is not enabled' do
        before do
          stub_feature_flags(phone_authenticatable: false)
        end

        context 'when login with phone' do
          it 'returns nothing' do
            expect(described_class.find_by_login(phone)).to be_nil
          end
        end

        it_behaves_like 'finding-user-by-email-or-username'
      end
    end
  end

  describe '#set_reset_password_token' do
    let(:user) { create(:user) }
    let(:reset_password_token) { user.set_reset_password_token }

    it 'reset_password_token is valid' do
      etc_reset_password_token = Devise.token_generator.digest(described_class, :reset_password_token,
        reset_password_token)
      user1 = described_class.where(reset_password_token: etc_reset_password_token).first_or_initialize
      expect(user.id).to eq user1.id
      expect(user).to be_reset_password_period_valid
    end
  end

  describe '#jh_password_expired?' do
    let(:user_detail) { build(:user_detail, password_last_changed_at: password_last_changed_at) }
    let(:user) { create(:user, user_detail: user_detail) }

    subject { user.jh_password_expired? }

    before do
      stub_licensed_features(password_expiration: true)
      stub_application_setting(password_expiration_enabled: true)
      stub_application_setting(password_expires_in_days: 90)
    end

    context 'when password_last_changed_at is nil' do
      let(:password_last_changed_at) { nil }

      it { is_expected.to be false }
    end

    context 'when create user by default' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end

    context 'when password expired in the past' do
      let(:password_last_changed_at) { 91.days.ago }

      it 'returns true' do
        is_expected.to be_truthy
      end
    end

    context 'when password is expiring in the future' do
      let(:password_last_changed_at) { 89.days.ago }

      it 'returns false' do
        is_expected.to be_falsey
      end
    end
  end

  describe '#skip_real_name_verification?' do
    before do
      stub_feature_flags(skip_real_name_verification: false)
    end

    context 'when user is under disable real name verification group' do
      let(:skip_real_name_verification_user) { create(:user) }
      let(:skip_real_name_verification_group) { create(:group) }
      let(:common_user) { create(:user) }
      let(:common_group) { create(:group) }

      before do
        skip_real_name_verification_group.add_guest(skip_real_name_verification_user)
        stub_feature_flags(skip_real_name_verification: skip_real_name_verification_group)
        common_group.add_guest(common_user)
      end

      it 'return true' do
        expect(Feature.enabled?(:skip_real_name_verification, skip_real_name_verification_group, type: :ops)).to be true
        expect(skip_real_name_verification_user.skip_real_name_verification?).to be true
      end

      it 'returns false' do
        expect(Feature.enabled?(:skip_real_name_verification, common_group, type: :ops)).to be false
        expect(common_user.skip_real_name_verification?).to be false
      end
    end

    context 'when user is not under disable real name verification group' do
      let(:common_user) { create(:user) }
      let(:common_group) { create(:group) }

      before do
        common_group.add_guest(common_user)
      end

      it 'returns false' do
        expect(common_user.skip_real_name_verification?).to be false
      end
    end

    context 'when user does not have group and no group skips real name verification' do
      let(:user) { create(:user) }

      it 'returns false' do
        expect(user.skip_real_name_verification?).to be false
      end
    end

    # rubocop:disable Gitlab/AvoidFeatureGet -- This is a test
    describe 'GateValues#actors' do
      let!(:group1) { create(:group) }
      let!(:group2) { create(:group) }
      let!(:group3) { create(:group) }

      before do
        Feature.enable(:skip_real_name_verification, group1)
        Feature.enable(:skip_real_name_verification, group2)
      end

      context 'when disable skip_real_name_verification for group2' do
        it 'only left group1' do
          expect(Feature.get(:skip_real_name_verification).gate_values.actors).to eq [group1,
            group2].map(&:flipper_id).to_set
          Feature.disable(:skip_real_name_verification, group2)
          expect(Feature.get(:skip_real_name_verification).gate_values.actors).to eq [group1].map(&:flipper_id).to_set
        end
      end

      context 'when enable skip_real_name_verification for group3' do
        it 'contains group3' do
          expect(Feature.get(:skip_real_name_verification).gate_values.actors).to eq [group1,
            group2].map(&:flipper_id).to_set
          Feature.enable(:skip_real_name_verification, group3)
          expect(Feature.get(:skip_real_name_verification).gate_values.actors).to eq [group1, group2,
            group3].map(&:flipper_id).to_set
        end
      end
    end
    # rubocop:enable Gitlab/AvoidFeatureGet
  end

  describe '#update_password_last_changed_at_to_now' do
    let(:password) { '123abc78' }
    let(:user) { create(:user, password: password) }

    context 'when the password is changed' do
      let(:new_password) { '123abc789' }

      it 'updates password_last_changed_at' do
        expect do
          user.password = new_password
          user.save!
        end.to change { user.user_detail.password_last_changed_at }
      end
    end

    context 'when the password is not changed' do
      it 'does not update the password_last_changed_at' do
        expect do
          user.save!(email: 'asdf@asdf.com')
        end.not_to change { user.user_detail.password_last_changed_at }
      end
    end
  end

  describe '#preferred_language' do
    let(:preferred_language) { 'zh_CN' }

    before do
      stub_application_setting(default_preferred_language: preferred_language)
    end

    subject(:user) { described_class.new }

    context 'when qa_enforce_locale_to_en is disabled' do
      before do
        stub_feature_flags(qa_enforce_locale_to_en: false)
      end

      it 'fills the preferred_language with default_preferred_language' do
        expect(user.preferred_language).to eq preferred_language
      end
    end

    context 'when qa_enforce_locale_to_en is enabled' do
      before do
        stub_feature_flags(qa_enforce_locale_to_en: true)
      end

      it 'fills the preferred_language with en' do
        expect(user.preferred_language).to eq 'en'
      end
    end
  end

  describe '#search_by_phone', :saas do
    let(:user_phone) { "+8615688888888" }
    let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(user_phone) }
    let(:scope) { described_class.search(user_phone) }

    let!(:user_with_phone) { create(:user, phone: encrypted_phone) }

    context 'with exist phone' do
      it 'shows user' do
        expect(JH::User.search_by_phone(scope, user_phone)).to eq([user_with_phone])
      end

      context 'and user with phone username' do
        let!(:user_with_phone_username) { create(:user, name: user_phone) }

        it 'shows both' do
          expect(JH::User.search_by_phone(scope, user_phone)).to eq([user_with_phone_username, user_with_phone])
        end
      end
    end

    context 'with non-exist phone' do
      it 'shows nothing' do
        expect(JH::User.search_by_phone(scope, "+8615633333333")).to eq([])
      end
    end
  end

  describe '#require_email_skippable?' do
    let(:phone) { "+86136#{random_number_string(11 - 3)}" }
    let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }
    let(:email) { "temp-email-for-phone-#{SecureRandom.uuid}@gitlab.localhost" }
    let(:user) { create(:user, phone: encrypted_phone, email: email) }

    subject { user.require_email_skippable? }

    context 'when self-managed env' do
      it { is_expected.to be_falsey }
    end

    context 'when saas env', :saas, :phone_verification_code_enabled do
      it { is_expected.to be_truthy }

      context 'for none phone registration' do
        let(:user) { create(:user, email: email) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe "#requires_usage_stats_consent?" do
    let(:user) { create(:user, :admin, created_at: 8.days.ago) }

    before do
      allow(user).to receive(:has_current_license?).and_return false
    end

    context "when feature jh_usage_statistics is disabled" do
      before do
        stub_feature_flags(jh_usage_statistics: false)
      end

      it 'does not require consent' do
        expect(user.requires_usage_stats_consent?).to be false
      end
    end

    context "when feature jh_usage_statistics is enable" do
      before do
        stub_feature_flags(jh_usage_statistics: true)
      end

      it 'requires user consent' do
        expect(user.requires_usage_stats_consent?).to be true
      end
    end
  end

  describe '#mark_free_trial_left_days' do
    let(:user) { create(:user) }

    it 'update positive days' do
      user.mark_free_trial_left_days(1)

      expect(user.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '1')
    end

    it 'update 0 days when negative days' do
      user.mark_free_trial_left_days(-1)

      expect(user.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '0')
    end
  end

  describe '#remove_free_trial_left_days' do
    let(:user) { create(:user) }

    it 'remove nothing' do
      UserCustomAttribute.upsert_custom_attributes([{ user_id: user.id, key: 'some key', value: 'some value' }])

      user.remove_free_trial_left_days

      expect(user.last_custom_attribute.key).to eq('some key')
    end

    it 'remove free trial left days' do
      user.mark_free_trial_left_days(-1)

      user.remove_free_trial_left_days

      expect(user.last_custom_attribute).to be_nil
    end
  end

  describe '#phone_required?', :saas, :phone_verification_code_enabled do
    let(:human) { build(:user) }
    let(:bot) { build(:user, :project_bot) }
    let(:service_account) { build(:user, :service_account) }

    it 'returns expected value for users' do
      expect(human.phone_required?).to be true
      expect(bot.phone_required?).to be false
      expect(service_account.phone_required?).to be false
    end
  end

  describe '#can?' do
    let(:user) { create(:user) }
    let(:blocked_user) { create(:user, :blocked) }

    context 'when SaaS', :saas do
      it 'returns expected value for users', :aggregate_failures do
        expect(user.can?(:log_in)).to be true
        expect(user.can?(:access_api)).to be true
        expect(user.can?(:receive_notifications)).to be true
        expect(user.can?(:use_slash_commands)).to be true

        expect(blocked_user.can?(:log_in)).to be true
        expect(blocked_user.can?(:access_api)).to be false
        expect(blocked_user.can?(:receive_notifications)).to be false
        expect(blocked_user.can?(:use_slash_commands)).to be false
      end
    end

    context 'when not SaaS' do
      it 'returns expected value for users', :aggregate_failures do
        expect(user.can?(:log_in)).to be true
        expect(user.can?(:access_api)).to be true
        expect(user.can?(:receive_notifications)).to be true
        expect(user.can?(:use_slash_commands)).to be true

        expect(blocked_user.can?(:log_in)).to be false
        expect(blocked_user.can?(:access_api)).to be false
        expect(blocked_user.can?(:receive_notifications)).to be false
        expect(blocked_user.can?(:use_slash_commands)).to be false
      end
    end
  end
end
