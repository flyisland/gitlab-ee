import { GlBadge } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import ComponentHealthCard from 'ee/orbit/components/component_health_card.vue';

describe('ComponentHealthCard', () => {
  let wrapper;

  const createComponent = (component) => {
    wrapper = mount(ComponentHealthCard, {
      propsData: { component },
    });
  };

  const findBadge = () => wrapper.findComponent(GlBadge);

  describe('when component is healthy', () => {
    beforeEach(() => {
      createComponent({ name: 'clickhouse', status: 'healthy' });
    });

    it('renders the component name', () => {
      expect(wrapper.text()).toContain('clickhouse');
    });

    it('renders a success badge with "Healthy" label', () => {
      const badge = findBadge();
      expect(badge.props('variant')).toBe('success');
      expect(badge.text()).toBe('Healthy');
    });

    it('renders a success dot', () => {
      const dot = wrapper.find('.gl-rounded-full');
      expect(dot.classes()).toContain('gl-bg-status-success');
    });
  });

  describe('when component is unknown', () => {
    beforeEach(() => {
      createComponent({ name: 'indexer', status: 'unknown' });
    });

    it('renders a danger badge with "No connection" label', () => {
      const badge = findBadge();
      expect(badge.props('variant')).toBe('danger');
      expect(badge.text()).toBe('No connection');
    });

    it('renders a danger dot', () => {
      const dot = wrapper.find('.gl-rounded-full');
      expect(dot.classes()).toContain('gl-bg-status-danger');
    });
  });

  describe('when component is unhealthy', () => {
    beforeEach(() => {
      createComponent({ name: 'indexer', status: 'unhealthy' });
    });

    it('renders a danger badge with "Unhealthy" label', () => {
      const badge = findBadge();
      expect(badge.props('variant')).toBe('danger');
      expect(badge.text()).toBe('Unhealthy');
    });
  });

  describe('when component has metadata', () => {
    it('renders additional metadata section', () => {
      createComponent({ name: 'clickhouse', status: 'healthy', metadata: { key: 'value' } });
      expect(wrapper.text()).toContain('Additional metadata');
    });

    it('does not render metadata section when absent', () => {
      createComponent({ name: 'clickhouse', status: 'healthy' });
      expect(wrapper.text()).not.toContain('Additional metadata');
    });
  });
});
