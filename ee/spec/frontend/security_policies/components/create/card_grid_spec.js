import { shallowMount } from '@vue/test-utils';
import CardGrid from 'ee/security_policies/components/create/card_grid.vue';

describe('CardGrid', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(CardGrid, {
      slots: { default: '<div class="test-slot-content">item</div>' },
    });
  };

  it('renders slot content', () => {
    createComponent();

    expect(wrapper.find('.test-slot-content').exists()).toBe(true);
  });

  it('applies grid layout classes', () => {
    createComponent();

    const root = wrapper.find('div');
    expect(root.classes()).toContain('gl-grid');
    expect(root.classes()).toContain('gl-grid-cols-2');
    expect(root.classes()).toContain('gl-gap-4');
  });
});
