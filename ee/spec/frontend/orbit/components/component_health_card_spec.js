import { mountExtended } from 'helpers/vue_test_utils_helper';
import ComponentHealthCard from 'ee/orbit/components/component_health_card.vue';

describe('ComponentHealthCard', () => {
  let wrapper;

  const createComponent = (component) => {
    wrapper = mountExtended(ComponentHealthCard, {
      propsData: { component },
    });
  };

  const findHealthyDot = () => wrapper.findByTestId('healthy-dot');
  const findWarningIcon = () => wrapper.findByTestId('unhealthy-warning-icon');

  describe('when component is healthy', () => {
    beforeEach(() => {
      createComponent({ name: 'clickhouse', status: 'healthy' });
    });

    it('renders the component name', () => {
      expect(wrapper.text()).toContain('clickhouse');
    });

    it('renders the healthy dot indicator', () => {
      expect(findHealthyDot().exists()).toBe(true);
      expect(findHealthyDot().classes()).toContain('gl-bg-status-success');
    });

    it('does not render a warning icon next to the name', () => {
      expect(findWarningIcon().exists()).toBe(false);
    });
  });

  describe.each([
    ['unknown', { name: 'indexer', status: 'unknown' }],
    ['unhealthy', { name: 'indexer', status: 'unhealthy' }],
  ])('when component is %s', (_, component) => {
    beforeEach(() => {
      createComponent(component);
    });

    it('renders the warning icon with danger variant', () => {
      expect(findWarningIcon().exists()).toBe(true);
      expect(findWarningIcon().props('variant')).toBe('danger');
    });

    it('does not render the healthy dot', () => {
      expect(findHealthyDot().exists()).toBe(false);
    });
  });

  describe('metadata', () => {
    describe('when metadata is present', () => {
      beforeEach(() => {
        createComponent({ name: 'clickhouse', status: 'healthy', metadata: { key: 'value' } });
      });

      it('renders the metadata hint', () => {
        expect(wrapper.text()).toContain('Additional metadata');
      });
    });

    describe('when metadata is absent', () => {
      beforeEach(() => {
        createComponent({ name: 'clickhouse', status: 'healthy' });
      });

      it('does not render the metadata hint', () => {
        expect(wrapper.text()).not.toContain('Additional metadata');
      });
    });
  });
});
