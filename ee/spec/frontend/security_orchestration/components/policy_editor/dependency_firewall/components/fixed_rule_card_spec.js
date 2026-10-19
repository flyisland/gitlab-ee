import { GlBadge, GlFormCheckbox } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import FixedRuleCard from 'ee/security_orchestration/components/policy_editor/dependency_firewall/components/fixed_rule_card.vue';
import LicenseRuleBuilder from 'ee/security_orchestration/components/policy_editor/dependency_firewall/rule/license_rule_builder.vue';
import MaliciousRuleBuilder from 'ee/security_orchestration/components/policy_editor/dependency_firewall/rule/malicious_rule_builder.vue';

describe('FixedRuleCard', () => {
  let wrapper;

  // GlCard's own template guards its #header slot behind `$scopedSlots.header`, which a
  // shallow stub of GlCard never evaluates - so this mounts for real and only stubs the
  // rule-builder children, which is all we need to keep out of scope here.
  const createWrapper = (propsData = {}) => {
    wrapper = mountExtended(FixedRuleCard, {
      propsData: { type: 'license', label: 'Licenses', rule: null, ...propsData },
      stubs: {
        LicenseRuleBuilder: true,
        VulnerabilityRuleBuilder: true,
        MaliciousRuleBuilder: true,
        RiskSeverityRuleBuilder: true,
      },
    });
  };

  const findCheckbox = () => wrapper.findComponent(GlFormCheckbox);

  it('renders unchecked when no rule is present', () => {
    createWrapper({ rule: null });

    expect(findCheckbox().props('checked')).toBe(false);
  });

  it('renders checked when a rule is present', () => {
    createWrapper({ rule: { type: 'license', denied: [] } });

    expect(findCheckbox().props('checked')).toBe(true);
  });

  it('shows the Recommended badge only when recommended is true', () => {
    createWrapper({ recommended: true });
    expect(wrapper.findComponent(GlBadge).exists()).toBe(true);

    createWrapper({ recommended: false });
    expect(wrapper.findComponent(GlBadge).exists()).toBe(false);
  });

  it('renders fields (via a default draft rule) even when unchecked', () => {
    createWrapper({ type: 'license', rule: null });

    expect(wrapper.findComponent(LicenseRuleBuilder).exists()).toBe(true);
  });

  it('renders the matching builder for the given type', () => {
    createWrapper({ type: 'malicious', rule: { type: 'malicious', denied: [] } });

    expect(wrapper.findComponent(MaliciousRuleBuilder).exists()).toBe(true);
  });

  it('emits toggle with the checked state and the draft rule when the checkbox changes', () => {
    createWrapper({ type: 'license', rule: null });

    findCheckbox().vm.$emit('change', true);

    const [[payload]] = wrapper.emitted('toggle');
    expect(payload.checked).toBe(true);
    expect(payload.draftRule).toMatchObject({ type: 'license' });
  });

  it('emits changed with the updated rule only when checked', () => {
    createWrapper({ type: 'license', rule: { type: 'license', denied: [] } });

    wrapper
      .findComponent(LicenseRuleBuilder)
      .vm.$emit('changed', { type: 'license', denied: [{ name: 'MIT' }] });

    expect(wrapper.emitted('changed')).toEqual([[{ type: 'license', denied: [{ name: 'MIT' }] }]]);
  });

  it('does not emit changed when unchecked', () => {
    createWrapper({ type: 'license', rule: null });

    wrapper
      .findComponent(LicenseRuleBuilder)
      .vm.$emit('changed', { type: 'license', denied: [{ name: 'MIT' }] });

    expect(wrapper.emitted('changed')).toBeUndefined();
  });
});
