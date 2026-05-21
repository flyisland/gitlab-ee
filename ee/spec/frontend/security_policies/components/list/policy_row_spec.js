import { shallowMount } from '@vue/test-utils';
import { GlBadge, GlDisclosureDropdown, GlLink } from '@gitlab/ui';
import PolicyRow from 'ee/security_policies/components/list/policy_row.vue';

const mockPolicy = {
  id: 1,
  name: 'Test Policy',
  type: 'scan_execution',
  severity: 'critical',
  status: 'active',
};

describe('PolicyRow', () => {
  let wrapper;

  const createComponent = ({ policy = mockPolicy } = {}) => {
    wrapper = shallowMount(PolicyRow, {
      propsData: { policy },
    });
  };

  const findLink = () => wrapper.findComponent(GlLink);
  const findBadges = () => wrapper.findAllComponents(GlBadge);
  const findDropdown = () => wrapper.findComponent(GlDisclosureDropdown);

  it('renders the policy name as a link', () => {
    createComponent();

    expect(findLink().text()).toBe('Test Policy');
  });

  it('renders type, severity, and status badges', () => {
    createComponent();

    expect(findBadges()).toHaveLength(3);
  });

  it.each([
    ['critical', 'danger'],
    ['high', 'warning'],
    ['medium', 'neutral'],
    ['low', 'muted'],
  ])('maps severity "%s" to variant "%s"', (severity, expected) => {
    createComponent({ policy: { ...mockPolicy, severity } });

    expect(wrapper.vm.severityVariant).toBe(expected);
  });

  it('returns "success" status variant for active policies', () => {
    createComponent({ policy: { ...mockPolicy, status: 'active' } });

    expect(wrapper.vm.statusVariant).toBe('success');
  });

  it('returns "neutral" status variant for non-active policies', () => {
    createComponent({ policy: { ...mockPolicy, status: 'inactive' } });

    expect(wrapper.vm.statusVariant).toBe('neutral');
  });

  it('emits edit and delete when the corresponding dropdown actions fire', () => {
    createComponent();

    findDropdown().vm.$emit('action', 'edit');
    expect(wrapper.emitted('edit')).toBeDefined();

    findDropdown().vm.$emit('action', 'delete');
    expect(wrapper.emitted('delete')).toBeDefined();
  });
});
