# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::OrbitHelper, feature_category: :knowledge_graph do
  describe '#orbit_app_data' do
    before do
      # current_user goes through Devise/Warden which is not wired up for
      # helper specs; stub the helper-level methods that depend on it.
      allow(helper).to receive_messages(current_user: nil, duo_accessible?: false,
        orbit_settings_enabled?: false, admin_orbit_configure_available?: false)
    end

    context 'with a current user' do
      using RSpec::Parameterized::TableSyntax

      let_it_be(:user) { build_stubbed(:user) }

      where(:gql, :value) do
        true  | 'true'
        false | 'false'
      end

      with_them do
        it 'exposes the per-user GQL decision' do
          allow(helper).to receive(:current_user).and_return(user)
          expect(Analytics::KnowledgeGraph).to receive(:gql_enabled_for?).with(user).once.and_return(gql)

          expect(helper.orbit_app_data[:gql_queries_enabled]).to eq(value)
        end
      end
    end

    it 'includes router_base pointing at the dashboard orbit path' do
      expect(helper.orbit_app_data[:router_base]).to eq(dashboard_orbit_path)
    end

    it 'includes duo_accessible as a string' do
      expect(helper.orbit_app_data[:duo_accessible]).to eq('false')
    end

    describe 'can_ask_duo_for_queries' do
      using RSpec::Parameterized::TableSyntax

      where(:duo, :gql, :value) do
        true  | true  | 'true'
        true  | false | 'false'
        false | true  | 'false'
        false | false | 'false'
      end

      with_them do
        it 'is true only when the user can reach GitLab Duo and write GQL' do
          allow(helper).to receive(:duo_accessible?).and_return(duo)
          allow(Analytics::KnowledgeGraph).to receive(:gql_enabled_for?).and_return(gql)

          expect(helper.orbit_app_data[:can_ask_duo_for_queries]).to eq(value)
        end
      end
    end

    it 'includes orbit_settings_enabled as a string' do
      expect(helper.orbit_app_data[:orbit_settings_enabled]).to eq('false')
    end

    context 'when deriving orbit_settings_enabled from the facade' do
      let_it_be(:user) { build_stubbed(:user) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(helper).to receive(:orbit_settings_enabled?).and_call_original
      end

      it 'reflects Ai::Orbit::Settings.orbit_in_duo_on?' do
        allow(::Ai::Orbit::Settings).to receive(:orbit_in_duo_on?).with(user).and_return(true)

        expect(helper.orbit_app_data[:orbit_settings_enabled]).to eq('true')
      end
    end

    context 'when admin orbit configure is available' do
      before do
        allow(helper).to receive(:admin_orbit_configure_available?).and_return(true)
      end

      it 'includes the admin path' do
        expect(helper.orbit_app_data[:admin_configuration_path]).to eq(admin_orbit_path)
      end
    end

    context 'when admin orbit configure is not available' do
      it 'omits the admin path' do
        expect(helper.orbit_app_data).not_to have_key(:admin_configuration_path)
      end
    end

    context 'on SaaS with no current user' do
      before do
        stub_saas_features(gitlab_com_subscriptions: true)
      end

      it 'offers no trial and does not report the default group as missing' do
        expect(helper.orbit_app_data).to include(trial_available: 'false', default_group_missing: 'false')
      end
    end

    context 'with a user who can set a governing group' do
      let_it_be(:user) { build_stubbed(:user) }
      let_it_be(:default_group) { build_stubbed(:group, path: 'acme') }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(helper).to receive(:can?).with(user, :update_governing_knowledge_graph_namespace)
          .and_return(true)
        allow(user.user_preference).to receive(:knowledge_graph_governing_namespace_with_fallback)
          .and_return(default_group)
      end

      it 'includes the preferences path anchored to the default group setting' do
        expect(helper.orbit_app_data[:preferences_path]).to eq(profile_preferences_path(anchor: 'orbit-default-group'))
      end

      context 'when the user can set a governing group but none resolves' do
        before do
          allow(user.user_preference).to receive(:knowledge_graph_governing_namespace_with_fallback)
            .and_return(nil)
        end

        it 'reports the default group as missing' do
          expect(helper.orbit_app_data[:default_group_missing]).to eq('true')
        end
      end

      context 'when the user has a governing group' do
        it 'does not report the default group as missing' do
          expect(helper.orbit_app_data[:default_group_missing]).to eq('false')
        end
      end

      context 'when the user cannot set a governing group (self-managed or no candidates)' do
        before do
          allow(helper).to receive(:can?).with(user, :update_governing_knowledge_graph_namespace)
            .and_return(false)
          allow(user.user_preference).to receive(:knowledge_graph_governing_namespace_with_fallback)
            .and_return(nil)
        end

        it 'does not report the default group as missing' do
          expect(helper.orbit_app_data[:default_group_missing]).to eq('false')
        end
      end

      context 'when SaaS subscriptions are available' do
        before do
          stub_saas_features(gitlab_com_subscriptions: true)
        end

        it 'sets trial_available to true' do
          expect(helper.orbit_app_data[:trial_available]).to eq('true')
        end
      end

      context 'when SaaS subscriptions are not available' do
        it 'sets trial_available to false' do
          expect(helper.orbit_app_data[:trial_available]).to eq('false')
        end
      end
    end
  end
end
