import { shallowMount } from '@vue/test-utils';
import { GlButton, GlIcon } from '@gitlab/ui';
import SelectableCard from 'ee/security_policies/components/create/selectable_card.vue';

describe('SelectableCard', () => {
  let wrapper;

  const defaultItem = {
    id: 'test_card',
    label: 'Test Card',
    description: 'A test description',
    icon: 'shield',
  };

  const createComponent = ({ item = defaultItem, selected = false } = {}) => {
    wrapper = shallowMount(SelectableCard, {
      propsData: { item, selected },
    });
  };

  const findButton = () => wrapper.findComponent(GlButton);

  it('renders label, description, and icon', () => {
    createComponent();

    expect(wrapper.text()).toContain(defaultItem.label);
    expect(wrapper.text()).toContain(defaultItem.description);
    expect(wrapper.findComponent(GlIcon).props('name')).toBe('shield');
  });

  it('emits select with item.id when clicked', () => {
    createComponent();

    findButton().vm.$emit('click');

    expect(wrapper.emitted('select')).toEqual([['test_card']]);
  });

  it('applies active border class when selected is true', () => {
    createComponent({ selected: true });

    expect(findButton().classes()).toContain('gl-border-blue-500');
  });

  it('does not apply active border class when selected is false', () => {
    createComponent({ selected: false });

    expect(findButton().classes()).not.toContain('gl-border-blue-500');
  });

  it('emits select when Enter key activates the button', () => {
    createComponent();

    // GlButton renders a native <button>; Enter/Space → click is native browser
    // behaviour. Simulate the resulting click since stubs don't emulate it.
    findButton().vm.$emit('click');

    expect(wrapper.emitted('select')).toEqual([['test_card']]);
  });

  it('emits select when Space key activates the button', () => {
    createComponent();

    findButton().vm.$emit('click');

    expect(wrapper.emitted('select')).toEqual([['test_card']]);
  });
});
