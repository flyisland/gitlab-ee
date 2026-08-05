import { shallowMountExtended, extendedWrapper } from 'helpers/vue_test_utils_helper';
import EnvironmentBreakdown from 'ee/cd/components/environment_breakdown.vue';
import { makeEnvironment } from './mock_data';

describe('EnvironmentBreakdown', () => {
  let wrapper;

  const findBreakdown = () => wrapper.findByTestId('environment-breakdown');
  const findTierGroups = (tier) => wrapper.findByTestId(`tier-group-${tier}`);
  const findAllTierHeadings = () => wrapper.findAllByTestId('tier-heading');
  const findEnvRow = (name) => extendedWrapper(wrapper.findByTestId(`env-row-${name}`));

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(EnvironmentBreakdown, {
      propsData: {
        environments: [makeEnvironment()],
        ...props,
      },
    });
  };

  describe('tier grouping and ordering', () => {
    it('groups environments by tier in TIER_ORDER', () => {
      createComponent({
        environments: [
          makeEnvironment({ name: 'prod-1', tier: 'prod' }),
          makeEnvironment({ name: 'dev-1', tier: 'dev' }),
          makeEnvironment({ name: 'qa-1', tier: 'qa' }),
        ],
      });

      const headings = findAllTierHeadings();
      expect(headings).toHaveLength(3);
      expect(headings.at(0).text()).toBe('Dev');
      expect(headings.at(1).text()).toBe('QA');
      expect(headings.at(2).text()).toBe('Production');
    });

    it('uses human-friendly TIER_LABELS for headings', () => {
      createComponent({
        environments: [makeEnvironment({ name: 'staging-1', tier: 'preprod' })],
      });

      expect(findAllTierHeadings().at(0).text()).toBe('Pre-production');
    });

    it('renders unknown tiers after known tiers', () => {
      createComponent({
        environments: [
          makeEnvironment({ name: 'custom-1', tier: 'custom' }),
          makeEnvironment({ name: 'dev-1', tier: 'dev' }),
        ],
      });

      const headings = findAllTierHeadings();
      expect(headings).toHaveLength(2);
      expect(headings.at(0).text()).toBe('Dev');
      expect(headings.at(1).text()).toBe('custom');
    });

    it('falls back to raw tier name for unrecognised tiers', () => {
      createComponent({
        environments: [makeEnvironment({ name: 'edge-1', tier: 'edge' })],
      });

      expect(findAllTierHeadings().at(0).text()).toBe('edge');
    });

    it('renders environments with null tier under unknown group', () => {
      createComponent({
        environments: [makeEnvironment({ name: 'untiered-1', tier: null })],
      });

      expect(findTierGroups('unknown').exists()).toBe(true);
      expect(findEnvRow('untiered-1').exists()).toBe(true);
    });

    it('renders environments with undefined tier under unknown group', () => {
      createComponent({
        environments: [makeEnvironment({ name: 'untiered-2', tier: undefined })],
      });

      expect(findTierGroups('unknown').exists()).toBe(true);
    });
  });

  describe('environment row rendering', () => {
    beforeEach(() => {
      createComponent({
        environments: [
          makeEnvironment({
            name: 'web-1',
            tier: 'prod',
            version: 'v2.0.0',
            pods: 5,
            sync: 'synced',
          }),
        ],
      });
    });

    it('renders environment name', () => {
      expect(findEnvRow('web-1').findByTestId('env-name').text()).toBe('web-1');
    });

    it('renders version in monospace', () => {
      const version = findEnvRow('web-1').findByTestId('env-version');
      expect(version.text()).toBe('v2.0.0');
      expect(version.classes()).toContain('gl-font-monospace');
    });

    it('renders pods label', () => {
      expect(findEnvRow('web-1').findByTestId('env-pods').text()).toBe('5 pods');
    });

    it('renders sync badge with correct variant and label', () => {
      const badge = findEnvRow('web-1').findByTestId('env-sync-badge');
      expect(badge.text()).toBe('Synced');
      expect(badge.attributes('variant')).toBe('success');
    });
  });

  describe('restarts', () => {
    it('renders restarts when present', () => {
      createComponent({
        environments: [makeEnvironment({ name: 'web-1', restarts: '2 restarts' })],
      });

      expect(findEnvRow('web-1').findByTestId('env-restarts').text()).toContain('2 restarts');
    });

    it('does not render restarts when null', () => {
      createComponent({
        environments: [makeEnvironment({ name: 'web-1', restarts: null })],
      });

      expect(findEnvRow('web-1').findByTestId('env-restarts').exists()).toBe(false);
    });
  });

  describe('sync badge visibility', () => {
    it('hides sync badge when sync label is empty', () => {
      createComponent({
        environments: [makeEnvironment({ name: 'web-1', sync: null })],
      });

      expect(findEnvRow('web-1').findByTestId('env-sync-badge').exists()).toBe(false);
    });

    it('shows sync badge for out-of-sync with warning variant', () => {
      createComponent({
        environments: [makeEnvironment({ name: 'web-1', sync: 'out-of-sync' })],
      });

      const badge = findEnvRow('web-1').findByTestId('env-sync-badge');
      expect(badge.text()).toBe('Out of sync');
      expect(badge.attributes('variant')).toBe('warning');
    });
  });

  describe('empty state', () => {
    it('does not render when environments array is empty', () => {
      createComponent({ environments: [] });

      expect(findBreakdown().exists()).toBe(false);
    });
  });
});
