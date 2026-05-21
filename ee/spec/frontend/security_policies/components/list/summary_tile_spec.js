import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import SummaryTile from 'ee/security_policies/components/list/summary_tile.vue';

describe('SummaryTile', () => {
  let wrapper;

  const defaultProps = {
    title: 'Global Security',
    count: 42,
    actionLabel: 'View Details',
    actionHref: '/policies/security',
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(SummaryTile, {
      propsData: { ...defaultProps, ...props },
    });
  };

  it('renders title, count, and actionLabel', () => {
    createComponent();

    expect(wrapper.text()).toContain('Global Security');
    expect(wrapper.text()).toContain('42');
    expect(wrapper.text()).toContain('View Details');
  });

  it('renders action button with correct href', () => {
    createComponent();

    const button = wrapper.findComponent(GlButton);

    expect(button.props('href')).toBe('/policies/security');
  });
});
