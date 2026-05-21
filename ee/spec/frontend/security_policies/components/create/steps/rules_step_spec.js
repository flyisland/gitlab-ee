import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import RulesStep from 'ee/security_policies/components/create/steps/rules_step.vue';
import SelectableCard from 'ee/security_policies/components/create/selectable_card.vue';
import GenericConfig from 'ee/security_policies/components/create/generic_config.vue';
import { RULE_TYPES } from 'ee/security_policies/constants';

describe('RulesStep', () => {
  let wrapper;

  const createComponent = ({ value = [] } = {}) => {
    wrapper = shallowMount(RulesStep, {
      propsData: { value },
    });
  };

  const findSelectableCards = () => wrapper.findAllComponents(SelectableCard);
  const findButtons = () => wrapper.findAllComponents(GlButton);
  const findBackButton = () => findButtons().wrappers.find((w) => w.text().includes('Back'));
  const findNextButton = () => findButtons().wrappers.find((w) => w.text() === 'Next');

  it('shows empty state when no rules are added', () => {
    createComponent();

    expect(wrapper.text()).toContain('No rules added yet');
  });

  it('renders all rule type cards in the catalogue', () => {
    createComponent();

    expect(findSelectableCards()).toHaveLength(RULE_TYPES.length);
  });

  it('immediately adds a rule to the list when a card is selected', () => {
    createComponent();

    findSelectableCards().at(0).vm.$emit('select', 'custom_rule');

    expect(wrapper.vm.addedRules).toHaveLength(1);
    expect(wrapper.vm.addedRules[0].ruleId).toBe('custom_rule');
  });

  it('emits input when a rule card is selected', () => {
    createComponent();

    findSelectableCards().at(0).vm.$emit('select', 'custom_rule');

    expect(wrapper.emitted('input')[0][0]).toEqual([
      expect.objectContaining({ ruleId: 'custom_rule' }),
    ]);
  });

  it('shows added rule label when a rule has been added', () => {
    createComponent({ value: [{ ruleId: 'custom_rule', config: {} }] });

    expect(wrapper.text()).toContain('Custom Rule');
  });

  it('shows generic config when an added rule is expanded', async () => {
    createComponent({ value: [{ ruleId: 'security_scan_results', config: {} }] });

    await wrapper.find('.gl-cursor-pointer').trigger('click');

    expect(wrapper.findComponent(GenericConfig).exists()).toBe(true);
  });

  it('shows AND/OR buttons between multiple added rules', () => {
    createComponent({
      value: [
        { ruleId: 'custom_rule', config: {} },
        { ruleId: 'security_scan_results', config: {}, operator: 'AND' },
      ],
    });

    const andButtons = findButtons().wrappers.filter((w) => w.text() === 'AND');
    expect(andButtons.length).toBeGreaterThan(0);
  });

  it('emits back and next correctly', () => {
    createComponent();

    findBackButton().vm.$emit('click');
    expect(wrapper.emitted('back')).toBeDefined();

    findNextButton().vm.$emit('click');
    expect(wrapper.emitted('next')).toBeDefined();
  });
});
