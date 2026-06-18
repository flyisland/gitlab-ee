# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Groups::Menus::SecurityComplianceMenu, feature_category: :navigation do
  let_it_be(:owner) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be_with_refind(:group) do
    create(:group, :private).tap do |g|
      g.add_owner(owner)
      g.add_guest(guest)
    end
  end

  let(:user) { owner }
  let(:show_group_discover_security) { false }
  let(:context) { Sidebars::Groups::Context.new(current_user: user, container: group, show_discover_group_security: show_group_discover_security) }
  let(:menu) { described_class.new(context) }
  let(:menu_items) { menu.renderable_items.map(&:title) }

  describe '#link' do
    subject(:link) { menu.link }

    context 'when menu has menu items' do
      it 'returns first visible menu item link' do
        expect(link).to eq menu.renderable_items.first.link
      end
    end

    context 'when menu does no have any menu item' do
      let(:user) { nil }

      it 'returns show group security page' do
        expect(link).to eq "/groups/#{group.full_path}/-/security/discover"
      end
    end
  end

  describe '#title' do
    subject(:title) { menu.title }

    specify do
      is_expected.to eq 'Security and compliance'
    end

    context 'when menu does not have any menu items' do
      let(:user) { nil }

      specify do
        is_expected.to eq 'Security'
      end
    end
  end

  describe '#render?' do
    subject(:render) { menu.render? }

    it 'returns true if there are menu items' do
      is_expected.to be true
    end

    context 'when there are no menu items' do
      let(:user) { nil }

      it 'returns false if there are no menu items' do
        is_expected.to be false
      end

      context 'when show group discover security option is enabled' do
        let(:show_group_discover_security) { true }

        it { is_expected.to be true }
      end
    end
  end

  describe 'Menu Items' do
    subject(:items) { described_class.new(context).renderable_items.index { |e| e.item_id == item_id } }

    shared_examples 'menu access rights' do
      it { is_expected.not_to be_nil }

      describe 'when the user does not have access' do
        let(:user) { nil }

        it { is_expected.to be_nil }
      end
    end

    describe 'Security Dashboard' do
      let(:item_id) { :security_dashboard }

      context 'when security_dashboard feature is enabled' do
        before do
          stub_licensed_features(security_dashboard: true)
        end

        it { is_expected.not_to be_nil }

        context 'when the user is authorized to read_vulnerability' do
          it 'lists Security dashboard in the menu list' do
            expect(menu_items).to include("Security dashboard")
          end
        end

        context 'when the user is not authorized to read_vulnerability' do
          let(:user) { guest }

          it 'does not list Security dashboard in the menu list' do
            expect(menu_items).not_to include("Security dashboard")
          end
        end
      end

      context 'when security_dashboard feature is not enabled' do
        it { is_expected.to be_nil }
      end
    end

    describe 'Vulnerability Report' do
      let(:item_id) { :vulnerability_report }

      context 'when security_dashboard feature is enabled' do
        before do
          stub_licensed_features(security_dashboard: true)
        end

        it { is_expected.not_to be_nil }

        context 'when the user is authorized to read_vulnerability' do
          it 'lists Vulnerability report in the menu list' do
            expect(menu_items).to include("Vulnerability report")
          end
        end

        context 'when the user is not authorized to read_vulnerability' do
          let(:user) { guest }

          it 'does not list Vulnerability report in the menu list' do
            expect(menu_items).not_to include("Vulnerability report")
          end
        end
      end

      context 'when security_dashboard feature is not enabled' do
        it { is_expected.to be_nil }
      end
    end

    describe 'Compliance center' do
      let(:item_id) { :compliance }

      context 'when group_level_compliance_dashboard feature is enabled' do
        before do
          stub_licensed_features(group_level_compliance_dashboard: true)
        end

        it_behaves_like 'menu access rights'

        context 'when user is assigned a custom role with `read_compliance_dashboard` ability' do
          let_it_be(:user, freeze: false) { create(:user) }

          let_it_be(:member_role, freeze: false) do
            create(:member_role, :guest, :read_compliance_dashboard, namespace: group)
          end

          let_it_be(:member, freeze: false) do
            create(:group_member, :guest, user: user, source: group, member_role: member_role)
          end

          before do
            stub_licensed_features(group_level_compliance_dashboard: true, custom_roles: true)
          end

          it_behaves_like 'menu access rights'

          context 'when custom roles feature is disabled' do
            before do
              stub_licensed_features(group_level_compliance_dashboard: true, custom_roles: false)
            end

            it { is_expected.to be_nil }
          end
        end

        context 'when user is assigned a custom role with `admin_compliance_framework` ability' do
          let_it_be(:user, freeze: false) { create(:user) }

          let_it_be(:member_role, freeze: false) do
            create(:member_role, :guest, :admin_compliance_framework, namespace: group)
          end

          let_it_be(:member, freeze: false) do
            create(:group_member, :guest, user: user, source: group, member_role: member_role)
          end

          before do
            stub_licensed_features(group_level_compliance_dashboard: true, custom_roles: true)
          end

          it_behaves_like 'menu access rights'

          context 'when custom roles feature is disabled' do
            before do
              stub_licensed_features(group_level_compliance_dashboard: true, custom_roles: false)
            end

            it { is_expected.to be_nil }
          end
        end
      end

      context 'when group_level_compliance_dashboard feature is not enabled' do
        it { is_expected.to be_nil }
      end
    end

    describe 'Credentials', :saas do
      let(:item_id) { :credentials }

      context 'when credentials_inventory feature is not licensed' do
        it { is_expected.to be_nil }
      end

      context 'when credentials_inventory feature is licensed' do
        before do
          stub_licensed_features(credentials_inventory: true)
        end

        it_behaves_like 'menu access rights'
      end
    end

    describe 'Security Policies' do
      let(:item_id) { :scan_policies }

      context 'when scan_policies feature is enabled' do
        before do
          stub_licensed_features(security_orchestration_policies: true)
        end

        context 'when group security policies feature is disabled' do
          it_behaves_like 'menu access rights'
        end

        context 'when scan_policies feature is not enabled' do
          before do
            stub_licensed_features(security_orchestration_policies: false)
          end

          it { is_expected.to be_nil }
        end
      end
    end

    describe 'Audit events' do
      let(:item_id) { :audit_events }

      context 'when audit_events feature is enabled' do
        before do
          stub_licensed_features(audit_events: true)
        end

        it_behaves_like 'menu access rights'
      end

      context 'when audit_events feature is not enabled' do
        before do
          stub_licensed_features(audit_events: false)
        end

        it { is_expected.to be_nil }
      end
    end

    describe 'Security configuration' do
      let(:item_id) { :configuration }

      context 'when security_attributes feature is available' do
        before do
          stub_licensed_features(security_attributes: true)
        end

        it { is_expected.not_to be_nil }

        context 'when user is authorized to admin_security_attributes' do
          it 'lists Security configuration in the menu list' do
            expect(menu_items).to include("Security configuration")
          end
        end

        context 'when user is not authorized to admin_security_attributes' do
          let(:user) { guest }

          it 'does not list Security configuration in the menu list' do
            expect(menu_items).not_to include("Security configuration")
          end
        end
      end

      context 'when security_attributes feature is not available' do
        before do
          stub_licensed_features(security_attributes: false)
        end

        it { is_expected.to be_nil }
      end

      context 'when security_scan_profiles feature is available and the feature flag is enabled' do
        before do
          stub_licensed_features(security_scan_profiles: true)
          stub_feature_flags(group_security_configuration_scanners_tab: true)
        end

        it 'shows Security configuration in the menu' do
          expect(menu_items).to include("Security configuration")
        end

        context 'when user does not have read_security_scan_profiles permission' do
          let(:user) { guest }

          it 'does not show Security configuration' do
            expect(menu_items).not_to include("Security configuration")
          end
        end
      end

      context 'when group_security_configuration_scanners_tab feature flag is disabled' do
        before do
          stub_licensed_features(security_scan_profiles: true)
          stub_feature_flags(group_security_configuration_scanners_tab: false)
        end

        it 'does not show Security configuration' do
          expect(menu_items).not_to include("Security configuration")
        end
      end

      context 'when security_scan_profiles feature is not available' do
        before do
          stub_licensed_features(security_scan_profiles: false)
        end

        it { is_expected.to be_nil }
      end
    end

    describe 'Dependency List' do
      let(:item_id) { :dependency_list }

      before do
        stub_licensed_features(security_dashboard: false)
      end

      it { is_expected.to be_nil }

      context 'when `security_dashboard` & `dependency_scanning` feature is enabled' do
        before do
          stub_licensed_features(security_dashboard: true, dependency_scanning: true)
        end

        it { is_expected.not_to be_nil }
      end
    end

    describe 'Secrets manager' do
      let(:item_id) { :secrets_manager }
      let_it_be(:secrets_manager, freeze: false) { build(:group_secrets_manager, group: group) }

      before_all do
        stub_feature_flags(group_secrets_manager: true)
        secrets_manager.activate!
      end

      before do
        # SM availability now requires (FF AND enrollment). Enroll the instance
        # by default so positive-path tests are reachable. Negative-path tests
        # override either the FF, license, or enrollment as needed.
        stub_application_setting(secrets_manager_instance_enrolled: true)
      end

      context 'when all conditions are met' do
        before do
          stub_licensed_features(native_secrets_management: true)
        end

        it { is_expected.not_to be_nil }
      end

      context 'when not enrolled' do
        before do
          stub_licensed_features(native_secrets_management: true)
          stub_application_setting(secrets_manager_instance_enrolled: false)
        end

        it { is_expected.to be_nil }
      end

      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(group_secrets_manager: false)
          stub_licensed_features(native_secrets_management: true)
        end

        it { is_expected.to be_nil }
      end

      context 'when native_secrets_management feature is not licensed' do
        before do
          stub_licensed_features(native_secrets_management: false)
        end

        it { is_expected.to be_nil }
      end

      context 'when user does not have read_secret permission' do
        let(:user) { guest }

        before do
          stub_licensed_features(native_secrets_management: true)
        end

        it { is_expected.to be_nil }
      end

      context 'when secrets manager is not provisioned' do
        let_it_be(:group_without_sm) { create(:group).tap { |g| g.add_owner(owner) } }
        let(:context) { Sidebars::Groups::Context.new(current_user: user, container: group_without_sm) }

        before do
          stub_licensed_features(native_secrets_management: true)
        end

        it { is_expected.to be_nil }
      end

      context 'when secrets manager is not active' do
        let_it_be(:group_provisioning) { create(:group).tap { |g| g.add_owner(owner) } }
        let_it_be(:provisioning_sm) { create(:group_secrets_manager, group: group_provisioning) }
        let(:context) { Sidebars::Groups::Context.new(current_user: user, container: group_provisioning) }

        before do
          stub_licensed_features(native_secrets_management: true)
        end

        it { is_expected.to be_nil }
      end
    end
  end
end
