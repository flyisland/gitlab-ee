# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::Orbit::Access, feature_category: :knowledge_graph do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group) { build_stubbed(:group) }
  let_it_be(:current_user) { build_stubbed(:user) }

  let(:license) { ::Analytics::KnowledgeGraph::OrbitLicense }

  subject(:access) do
    described_class.for(group: group, current_user: current_user, trial_status: trial_status)
  end

  def cdot(state, expires_at: nil, credits_remaining: nil)
    ::Gitlab::SubscriptionPortal::ProductTrialResponse.new(
      state: state, trial_expires_at: expires_at, credits_remaining: credits_remaining
    )
  end

  def enrollment(kind)
    return if kind == :none

    attrs = {
      beta: { beta?: true, trial?: false, trial_ended_at: nil },
      trial_active: { beta?: false, trial?: true, trial_ended_at: nil },
      trial_ended: { beta?: false, trial?: true, trial_ended_at: Time.current }
    }.fetch(kind)

    instance_double(::Analytics::Orbit::NamespaceEnrollment, **attrs)
  end

  describe '.for state and reason' do
    # rubocop:disable Layout/LineLength -- an aligned parameterized table reads best on one line per case
    where(:scenario, :configured, :can_toggle, :can_start, :trial_flow, :entitled, :promo_gate, :promo_add_on,
      :beta_kind, :saas, :enabled, :cdot_status, :expected_state, :expected_reason) do
      'service off'                     | false | false | true  | false | false | false | false | :none         | true  | false | :none              | :not_configured           | nil
      'self-managed, no license'        | true  | false | true  | false | false | false | false | :none         | false | false | :none              | :unlicensed               | :no_license
      'free plan'                       | true  | false | true  | false | false | false | false | :none         | true  | false | :none              | :unlicensed               | :free_plan
      'promo gate, no access, off'      | true  | false | true  | false | false | true  | false | :none         | true  | false | :none              | :unlicensed               | :no_access
      'promo gate, no access, on'       | true  | true  | true  | false | false | true  | false | :none         | true  | true  | :none              | :unlicensed               | :no_access
      'licensed by plan'                | true  | true  | true  | false | true  | false | false | :none         | true  | false | :none              | :licensed                 | :plan
      'licensed by promo add-on'        | true  | true  | true  | false | true  | true  | true  | :none         | true  | true  | :none              | :licensed                 | :promo_add_on
      'licensed by beta'                | true  | true  | true  | false | true  | false | false | :beta         | true  | true  | :none              | :licensed                 | :beta
      'trial eligible'                  | true  | true  | true  | true  | true  | false | false | :none         | true  | false | :cdot_eligible     | :trial_eligible           | nil
      'trial active'                    | true  | true  | true  | true  | true  | false | false | :none         | true  | true  | :cdot_active       | :trial_active             | nil
      'promo gate, active trial, no row' | true | true  | true  | true  | false | true  | false | :none         | true  | true  | :cdot_active       | :trial_active             | nil
      'trial expired by date'           | true  | true  | true  | true  | true  | false | false | :none         | true  | false | :cdot_expired      | :trial_ended              | :trial_expired
      'trial out of credits'            | true  | true  | true  | true  | true  | false | false | :none         | true  | false | :cdot_credits_gone | :trial_ended              | :credits_exhausted
      'trial ended with no end date'    | true  | true  | true  | true  | true  | false | false | :none         | true  | false | :cdot_ended_no_date | :trial_ended | :credits_exhausted
      'trial not eligible'              | true  | true  | true  | true  | true  | false | false | :none         | true  | false | :cdot_ineligible   | :trial_not_eligible       | nil
      'cdot error, orbit on'            | true  | true  | true  | true  | true  | false | false | :none         | true  | true  | :unavailable       | :trial_status_unavailable | nil
      'beta in the trial flow'          | true  | true  | false | true  | true  | false | false | :beta         | true  | true  | :cdot_eligible     | :licensed                 | :beta
      'beta, CustomersDot down'         | true  | true  | false | true  | true  | false | false | :beta         | true  | true  | :unavailable       | :licensed                 | :beta
      'not eligible, cannot start'      | true  | true  | false | true  | true  | false | false | :none         | true  | false | :cdot_ineligible   | :licensed                 | :plan
      'promo gate, eligible while on'   | true  | true  | true  | true  | false | true  | false | :beta         | true  | true  | :cdot_eligible     | :trial_eligible           | nil
    end
    # rubocop:enable Layout/LineLength

    with_them do
      let(:trial_status) do
        case cdot_status
        when :cdot_eligible then cdot(:trial_eligible)
        when :cdot_active then cdot(:trial, credits_remaining: 100.0)
        when :cdot_expired then cdot(:expired, expires_at: 1.day.ago)
        when :cdot_credits_gone then cdot(:trial, expires_at: 5.days.from_now, credits_remaining: 0.0)
        when :cdot_ended_no_date then cdot(:expired)
        when :cdot_ineligible then cdot(:ineligible)
        when :none then nil
        else cdot_status
        end
      end

      before do
        allow(::Analytics::KnowledgeGraph).to receive(:service_configured?).and_return(configured)
        allow(license).to receive_messages(
          promo_gate_enabled?: promo_gate, promo_add_on_active?: promo_gate && promo_add_on, entitled?: entitled
        )
        allow(::Analytics::Orbit::Trial).to receive(:available_for?).with(group).and_return(trial_flow)
        allow(::Gitlab::Saas).to receive(:feature_available?).with(:gitlab_com_subscriptions).and_return(saas)
        allow(group).to receive_messages(
          orbit_namespace_enrollment: enrollment(beta_kind),
          knowledge_graph_enabled_namespace:
            (enabled ? instance_double(::Analytics::KnowledgeGraph::EnabledNamespace) : nil)
        )
        allow(::Ability).to receive(:allowed?).and_call_original
        allow(::Ability).to receive(:allowed?)
          .with(current_user, :update_knowledge_graph_setting, group).and_return(can_toggle)
        allow(::Ability).to receive(:allowed?)
          .with(current_user, :read_orbit_trial, group).and_return(trial_flow)
        allow(::Ability).to receive(:allowed?)
          .with(current_user, :start_orbit_trial, group).and_return(can_start)
      end

      it 'computes the expected state and reason' do
        expect(access).to have_attributes(state: expected_state, reason: expected_reason)
      end
    end
  end

  describe '.for turn_on_denial_reason' do
    let(:trial_status) { cdot(:trial_eligible) }
    let(:entitled) { true }
    let(:promo_add_on) { false }
    let(:promo_gate) { false }
    let(:trial_flow) { true }

    before do
      allow(::Analytics::KnowledgeGraph).to receive(:service_configured?).and_return(true)
      allow(license).to receive_messages(promo_gate_enabled?: promo_gate, promo_add_on_active?: promo_add_on,
        entitled?: entitled)
      allow(::Analytics::Orbit::Trial).to receive(:available_for?).with(group).and_return(trial_flow)
      allow(::Gitlab::Saas).to receive(:feature_available?).and_return(true)
      allow(group).to receive_messages(orbit_namespace_enrollment: nil, knowledge_graph_enabled_namespace: nil)
      allow(::Ability).to receive(:allowed?).and_call_original
      allow(::Ability).to receive(:allowed?).with(current_user, :read_orbit_trial, group).and_return(trial_flow)
      allow(::Ability).to receive(:allowed?).with(current_user, :start_orbit_trial, group).and_return(true)
      allow(::Ability).to receive(:allowed?)
        .with(current_user, :update_knowledge_graph_setting, group).and_return(can_toggle)
    end

    context 'when the user cannot toggle the setting' do
      let(:can_toggle) { false }

      it { expect(access.turn_on_denial_reason).to eq(:forbidden) }
    end

    context 'when the user can toggle and a trial is required' do
      let(:can_toggle) { true }

      it { expect(access.turn_on_denial_reason).to eq(:trial_required) }
    end

    context 'when the user can toggle and the trial has ended' do
      let(:can_toggle) { true }
      let(:trial_status) { cdot(:expired, expires_at: 1.day.ago) }

      it { expect(access.turn_on_denial_reason).to eq(:trial_ended) }
    end

    context 'when turning on is allowed' do
      let(:can_toggle) { true }
      let(:trial_status) { cdot(:trial, credits_remaining: 100.0) }

      it { expect(access.turn_on_denial_reason).to be_nil }
    end

    context 'when CustomersDot is unavailable' do
      let(:can_toggle) { true }
      let(:trial_status) { :unavailable }

      it { expect(access.turn_on_denial_reason).to eq(:unavailable) }
    end

    context 'when the promo gate needs a trial and the group is not in the trial flow' do
      let(:can_toggle) { true }
      let(:promo_gate) { true }
      let(:trial_flow) { false }
      let(:trial_status) { nil }

      it { expect(access.turn_on_denial_reason).to eq(:trial_required) }
    end

    context 'when Orbit is already on' do
      let(:can_toggle) { true }

      before do
        allow(group).to receive(:knowledge_graph_enabled_namespace)
          .and_return(instance_double(::Analytics::KnowledgeGraph::EnabledNamespace))
      end

      it { expect(access.turn_on_denial_reason).to be_nil }
    end
  end
end
