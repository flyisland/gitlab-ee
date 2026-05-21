import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import TriggerStep from 'ee/security_policies/components/create/steps/trigger_step.vue';
import SelectableCard from 'ee/security_policies/components/create/selectable_card.vue';
import GenericConfig from 'ee/security_policies/components/create/generic_config.vue';
import { TRIGGER_TYPES } from 'ee/security_policies/constants';

describe('TriggerStep', () => {
  let wrapper;

  const defaultValue = { triggerId: null, config: {} };

  const createComponent = ({ value = defaultValue } = {}) => {
    wrapper = shallowMount(TriggerStep, {
      propsData: { value },
    });
  };

  const findSelectableCards = () => wrapper.findAllComponents(SelectableCard);
  const findButtons = () => wrapper.findAllComponents(GlButton);
  const findNextButton = () => findButtons().wrappers.find((w) => w.text() === 'Next');
  const findBackButton = () => findButtons().wrappers.find((w) => w.text().includes('Back'));
  const findGenericConfig = () => wrapper.findComponent(GenericConfig);

  it('renders 19 selectable cards', () => {
    createComponent();

    expect(findSelectableCards()).toHaveLength(TRIGGER_TYPES.length);
    expect(TRIGGER_TYPES).toHaveLength(19);
  });

  it('Next button is disabled when no trigger is selected', () => {
    createComponent();

    expect(findNextButton().props('disabled')).toBe(true);
  });

  it('emits input with triggerId when a trigger card is selected', () => {
    createComponent();

    findSelectableCards().at(0).vm.$emit('select', 'merge_request');

    expect(wrapper.emitted('input')[0][0]).toEqual({
      triggerId: 'merge_request',
      config: {},
    });
  });

  it('shows config panel with fields when a trigger is selected', () => {
    createComponent({ value: { triggerId: 'merge_request', config: {} } });

    expect(findGenericConfig().exists()).toBe(true);
    expect(findGenericConfig().props('fields').length).toBeGreaterThan(0);
  });

  it('passes correct fields to generic config for pipeline_triggered', () => {
    createComponent({ value: { triggerId: 'pipeline_triggered', config: {} } });

    const fields = findGenericConfig().props('fields');
    expect(fields.some((f) => f.key === 'sources')).toBe(true);
    expect(fields.some((f) => f.key === 'branchPattern')).toBe(true);
  });

  it('emits next when Next is clicked with a trigger selected', () => {
    createComponent({ value: { triggerId: 'merge_request', config: {} } });

    findNextButton().vm.$emit('click');

    expect(wrapper.emitted('next')).toBeDefined();
  });

  it('emits back when Back is clicked', () => {
    createComponent();

    findBackButton().vm.$emit('click');

    expect(wrapper.emitted('back')).toBeDefined();
  });
});
