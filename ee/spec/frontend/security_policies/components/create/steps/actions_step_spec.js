import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import ActionsStep from 'ee/security_policies/components/create/steps/actions_step.vue';
import SelectableCard from 'ee/security_policies/components/create/selectable_card.vue';
import GenericConfig from 'ee/security_policies/components/create/generic_config.vue';
import { ACTION_TYPES } from 'ee/security_policies/constants';

describe('ActionsStep', () => {
  let wrapper;

  const createComponent = ({ value = [] } = {}) => {
    wrapper = shallowMount(ActionsStep, {
      propsData: { value },
    });
  };

  const findSelectableCards = () => wrapper.findAllComponents(SelectableCard);
  const findButtons = () => wrapper.findAllComponents(GlButton);
  const findBackButton = () => findButtons().wrappers.find((w) => w.text().includes('Back'));
  const findSaveButton = () => findButtons().wrappers.find((w) => w.text() === 'Save Policy');

  it('shows empty state when no actions are added', () => {
    createComponent();

    expect(wrapper.text()).toContain('No actions added yet');
  });

  it('renders all action type cards in the catalogue', () => {
    createComponent();

    expect(findSelectableCards()).toHaveLength(ACTION_TYPES.length);
    expect(ACTION_TYPES).toHaveLength(20);
  });

  it('immediately adds an action to the list when a card is selected', () => {
    createComponent();

    findSelectableCards().at(0).vm.$emit('select', 'block');

    expect(wrapper.vm.addedActions).toHaveLength(1);
    expect(wrapper.vm.addedActions[0].actionId).toBe('block');
  });

  it('emits input when an action card is selected', () => {
    createComponent();

    findSelectableCards().at(0).vm.$emit('select', 'block');

    expect(wrapper.emitted('input')[0][0]).toEqual([
      expect.objectContaining({ actionId: 'block' }),
    ]);
  });

  it('shows added action label when an action has been added', () => {
    createComponent({ value: [{ actionId: 'block', config: {} }] });

    expect(wrapper.text()).toContain('Block');
  });

  it('shows generic config when an added action is expanded and has fields', async () => {
    createComponent({ value: [{ actionId: 'block', config: {} }] });

    await wrapper.find('.gl-cursor-pointer').trigger('click');

    expect(wrapper.findComponent(GenericConfig).exists()).toBe(true);
  });

  it('shows AND/OR buttons between multiple added actions', () => {
    createComponent({
      value: [
        { actionId: 'block', config: {} },
        { actionId: 'warn', config: {}, operator: 'AND' },
      ],
    });

    const andButtons = findButtons().wrappers.filter((w) => w.text() === 'AND');
    expect(andButtons.length).toBeGreaterThan(0);
  });

  it('emits back and submit correctly', () => {
    createComponent();

    findBackButton().vm.$emit('click');
    expect(wrapper.emitted('back')).toBeDefined();

    findSaveButton().vm.$emit('click');
    expect(wrapper.emitted('submit')).toBeDefined();
  });
});
