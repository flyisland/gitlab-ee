import { GlBadge } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import EnvironmentCard from 'ee/cd/components/environment_card.vue';

describe('EnvironmentCard', () => {
  let wrapper;

  const findBadge = () => wrapper.findComponent(GlBadge);

  const createComponent = () => {
    wrapper = shallowMountExtended(EnvironmentCard, {
      propsData: { name: 'prod-eu-west-1' },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  it('renders the environment name', () => {
    expect(wrapper.text()).toContain('prod-eu-west-1');
  });

  it('renders the healthy badge', () => {
    expect(findBadge().props('variant')).toBe('success');
    expect(findBadge().text()).toBe('Healthy');
  });

  it('renders the hardcoded deployment details', () => {
    const text = wrapper.text();

    expect(text).toContain('Kubernetes');
    expect(text).toContain('5 apps');
    expect(text).toContain('v2.4.1');
    expect(text).toContain('10m ago');
    expect(text).toContain('@abc.com');
    expect(text).toContain('eu-west-1');
    expect(text).toContain('v1.28.4');
    expect(text).toContain('gitlab-agent-prod-eu');
  });
});
