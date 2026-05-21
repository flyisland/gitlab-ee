import { shallowMount } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import StatsBar from 'ee/security_policies/components/list/stats_bar.vue';

const mockStats = [
  { icon: 'shield', count: 5, label: 'Total Policies', variant: 'default' },
  { icon: 'check-circle', count: 3, label: 'Active', variant: 'success' },
];

describe('StatsBar', () => {
  let wrapper;

  const createComponent = ({ stats = mockStats } = {}) => {
    wrapper = shallowMount(StatsBar, {
      propsData: { stats },
    });
  };

  it('renders one icon per stat entry', () => {
    createComponent();

    expect(wrapper.findAllComponents(GlIcon)).toHaveLength(mockStats.length);
  });

  it('renders count and label for each stat', () => {
    createComponent();

    expect(wrapper.text()).toContain('5');
    expect(wrapper.text()).toContain('Total Policies');
    expect(wrapper.text()).toContain('3');
    expect(wrapper.text()).toContain('Active');
  });
});
