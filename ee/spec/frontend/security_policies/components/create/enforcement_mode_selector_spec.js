import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import EnforcementModeSelector from 'ee/security_policies/components/create/enforcement_mode_selector.vue';
import { ENFORCEMENT_MODES } from 'ee/security_policies/constants';

describe('EnforcementModeSelector', () => {
  let wrapper;

  const createComponent = ({ value = 'audit' } = {}) => {
    wrapper = shallowMount(EnforcementModeSelector, {
      propsData: { value },
    });
  };

  const findModeButtons = () => wrapper.findAllComponents(GlButton);

  it('renders all 3 enforcement mode options', () => {
    createComponent();

    expect(findModeButtons()).toHaveLength(ENFORCEMENT_MODES.length);
    ENFORCEMENT_MODES.forEach(({ label }) => {
      expect(wrapper.text()).toContain(label);
    });
  });

  it('applies active styling to the selected mode', () => {
    createComponent({ value: 'enforce' });

    expect(findModeButtons().at(0).classes()).toContain('gl-border-blue-500');
  });

  it('emits input with mode id when a mode is clicked', () => {
    createComponent();

    findModeButtons().at(1).vm.$emit('click');

    expect(wrapper.emitted('input')[0][0]).toBe('warn');
  });

  it('does not apply active styling to unselected modes', () => {
    createComponent({ value: 'enforce' });

    expect(findModeButtons().at(1).classes()).not.toContain('gl-border-blue-500');
    expect(findModeButtons().at(2).classes()).not.toContain('gl-border-blue-500');
  });
});
