# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GlobalPolicy do
  let(:current_user) { create(:user) }
  let(:user) { create(:user) }

  subject { described_class.new(current_user, [user]) }

  describe 'DAP self-hosted model permissions', feature_category: :ai_abstraction_layer do
    using RSpec::Parameterized::TableSyntax

    let(:current_user) { build(:admin) }
    let(:license) { build(:license) }

    subject(:policy) { described_class.new(current_user, :global) }

    where(:offline_license, :add_on, :expired, :allowed) do
      false | nil              | false | true
      true  | nil              | false | false
      true  | :self_hosted_dap | false | true
      true  | :duo_enterprise  | false | true
      true  | :duo_enterprise  | true  | false
      true  | :duo_pro         | false | false
    end

    with_them do
      before do
        allow(license).to receive(:offline_cloud_license?).and_return(offline_license)
        allow(License).to receive(:current).and_return(license)

        if add_on
          create(:gitlab_subscription_add_on_purchase, :self_managed, add_on,
            expires_on: expired ? 1.day.ago : 1.year.from_now)
        end
      end

      context 'with admin mode enabled', :enable_admin_mode do
        it 'checks read and update access', :aggregate_failures do
          expect(policy.allowed?(:read_dap_self_hosted_model)).to eq(allowed)
          expect(policy.allowed?(:update_dap_self_hosted_model)).to eq(allowed)
        end

        context 'with a regular user' do
          let(:current_user) { build(:user) }

          it { is_expected.to be_disallowed(:read_dap_self_hosted_model, :update_dap_self_hosted_model) }
        end

        context 'with an anonymous user' do
          let(:current_user) { nil }

          it { is_expected.to be_disallowed(:read_dap_self_hosted_model, :update_dap_self_hosted_model) }
        end
      end
    end
  end

  describe 'phone verification' do
    shared_examples 'checking access for phone verification' do |ability|
      it { is_expected.to be_allowed(ability) }

      context 'when it is JH SaaS', :saas, :phone_verification_code_enabled do
        it { is_expected.not_to be_allowed(ability) }

        context 'when phone verified' do
          before do
            current_user.update!(phone: 'phone')
          end

          it { is_expected.to be_allowed(ability) }
        end

        context 'when phone is skip_real_name_verification' do
          before do
            allow(current_user).to receive(:skip_real_name_verification?).and_return(true)
          end

          it { is_expected.to be_allowed(ability) }
        end
      end
    end

    shared_examples 'checking access with different roles and abilities for phone verification' do |ability|
      context 'with regular user' do
        it_behaves_like 'checking access for phone verification', ability
      end

      context 'with admin' do
        let(:current_user) { create(:admin) }

        it_behaves_like 'checking access for phone verification', ability
      end

      context 'with anonymous' do
        let(:current_user) { nil }

        it { is_expected.to be_allowed(ability) }

        context 'when it is JH SaaS', :saas, :phone_verification_code_enabled do
          it { is_expected.to be_allowed(ability) }
        end
      end
    end

    describe 'api access' do
      it_behaves_like 'checking access with different roles and abilities for phone verification', :access_api
    end

    describe 'git access' do
      it_behaves_like 'checking access with different roles and abilities for phone verification', :access_git
    end
  end
end
