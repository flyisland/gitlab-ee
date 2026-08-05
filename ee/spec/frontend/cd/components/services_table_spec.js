import { GlTableLite } from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import ServicesTable from 'ee/cd/components/services_table.vue';
import { makeService } from './mock_data';

describe('ServicesTable', () => {
  let wrapper;

  const findTable = () => wrapper.findComponent(GlTableLite);
  const findHealthBadge = () => wrapper.findByTestId('health-badge');
  const findServiceTypeBadge = () => wrapper.findByTestId('service-type-badge');
  const findSyncBadge = () => wrapper.findByTestId('sync-badge');
  const findHealthDot = () => wrapper.findByTestId('health-dot');
  const findTimeAgo = () => wrapper.findComponent(TimeAgo);

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(ServicesTable, {
      propsData: {
        services: [makeService()],
        ...props,
      },
    });
  };

  const mountComponent = (props = {}) => {
    wrapper = mountExtended(ServicesTable, {
      propsData: {
        services: [makeService()],
        ...props,
      },
    });
  };

  describe('table rendering', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders a GlTableLite', () => {
      expect(findTable().exists()).toBe(true);
    });

    it('passes services as items', () => {
      expect(findTable().props('items')).toHaveLength(1);
    });

    it('stacks the table on small viewports', () => {
      expect(findTable().attributes('stacked')).toBe('sm');
    });
  });

  describe('mini variant (full=false)', () => {
    beforeEach(() => {
      createComponent({ full: false });
    });

    it('shows 2 columns (Service + Deployed)', () => {
      const fields = findTable().props('fields');

      expect(fields).toHaveLength(2);
      expect(fields.map((f) => f.key)).toEqual(['name', 'lastDeployed']);
    });
  });

  describe('full variant (full=true)', () => {
    beforeEach(() => {
      createComponent({ full: true });
    });

    it('shows 5 columns', () => {
      const fields = findTable().props('fields');

      expect(fields).toHaveLength(5);
      expect(fields.map((f) => f.key)).toEqual([
        'name',
        'health',
        'serviceType',
        'sync',
        'lastDeployed',
      ]);
    });
  });

  describe('cell rendering (full mount)', () => {
    beforeEach(() => {
      mountComponent({ full: true });
    });

    it('renders health badge with label', () => {
      expect(findHealthBadge().text()).toBe('Healthy');
      expect(findHealthBadge().props('variant')).toBe('success');
    });

    it('renders raw serviceType in badge', () => {
      expect(findServiceTypeBadge().text()).toBe('http-api');
    });

    it('renders sync badge', () => {
      expect(findSyncBadge().text()).toBe('Synced');
      expect(findSyncBadge().props('variant')).toBe('success');
    });

    it('renders TimeAgo for lastDeployed', () => {
      expect(findTimeAgo().props('time')).toBe('2024-06-10T08:00:00Z');
    });

    it('renders health dot', () => {
      expect(findHealthDot().classes()).toContain('gl-bg-green-500');
    });
  });

  describe('badge visibility guards', () => {
    it('hides health badge when health is null', () => {
      mountComponent({ full: true, services: [makeService({ health: null })] });

      expect(findHealthBadge().exists()).toBe(false);
    });

    it('hides sync badge when sync is null', () => {
      mountComponent({ full: true, services: [makeService({ sync: null })] });

      expect(findSyncBadge().exists()).toBe(false);
    });

    it('hides serviceType badge when serviceType is null', () => {
      mountComponent({ full: true, services: [makeService({ serviceType: null })] });

      expect(findServiceTypeBadge().exists()).toBe(false);
    });

    it('hides TimeAgo when lastDeployed is null', () => {
      mountComponent({ services: [makeService({ lastDeployed: null })] });

      expect(findTimeAgo().exists()).toBe(false);
    });
  });
});
