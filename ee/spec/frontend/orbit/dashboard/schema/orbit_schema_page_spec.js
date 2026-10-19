import { ref } from 'vue';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import OrbitSchemaPage from 'ee/orbit/dashboard/schema/orbit_schema_page.vue';
import SchemaDataTab from 'ee/orbit/dashboard/schema/schema_data_tab.vue';
import { fetchGraphStatus, fetchOrbitSchema } from 'ee/orbit/api/orbit_api';
import { mockExpandedSchema, mockGroups } from '../../mock_data';

jest.mock('ee/orbit/api/orbit_api', () => ({
  fetchOrbitSchema: jest.fn(),
  fetchGraphStatus: jest.fn(),
}));
jest.mock('~/sentry/sentry_browser_wrapper');

describe('OrbitSchemaPage', () => {
  let wrapper;
  const routerPush = jest.fn();

  const createComponent = ({ query = {} } = {}) => {
    wrapper = shallowMountExtended(OrbitSchemaPage, {
      provide: { enabledMemberGroups: ref([mockGroups[0]]) },
      mocks: { $route: { query }, $router: { push: routerPush } },
      stubs: { GlAlert },
    });
  };

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findError = () => wrapper.findComponent(GlAlert);
  const findTab = () => wrapper.findComponent(SchemaDataTab);

  beforeEach(() => {
    localStorage.clear();
    fetchGraphStatus.mockResolvedValue({
      data: { domains: [{ name: 'ci', items: [{ name: 'Pipeline', count: 1200 }] }] },
    });
  });

  describe('while the schema loads', () => {
    beforeEach(() => {
      fetchOrbitSchema.mockReturnValue(new Promise(() => {}));
      createComponent();
    });

    it('shows only the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(true);
      expect(findError().exists()).toBe(false);
      expect(findTab().exists()).toBe(false);
    });
  });

  describe('when the schema loads', () => {
    beforeEach(async () => {
      fetchOrbitSchema.mockResolvedValue({ data: mockExpandedSchema });
      createComponent({ query: { entity: 'pipeline' } });
      await waitForPromises();
    });

    it('passes the schema, the graph counts of the root groups, and the entity from the URL', () => {
      expect(fetchOrbitSchema).toHaveBeenCalledWith({ expand: '*' });
      expect(fetchGraphStatus).toHaveBeenCalledWith(mockGroups[0].fullPath);
      expect(findLoadingIcon().exists()).toBe(false);
      expect(findTab().props()).toEqual({
        schema: mockExpandedSchema,
        graphStats: { pipeline: 1200 },
        initialEntity: 'pipeline',
      });
    });

    it('opens Overview for an entity type from the tab', () => {
      findTab().vm.$emit('show-instances', { entityType: 'Pipeline' });

      expect(routerPush).toHaveBeenCalledWith({
        name: 'overview',
        query: { entity: 'Pipeline' },
      });
    });
  });

  describe('when the counts of one group fail', () => {
    beforeEach(async () => {
      fetchOrbitSchema.mockResolvedValue({ data: mockExpandedSchema });
      fetchGraphStatus.mockRejectedValue({ response: { status: 429 } });
      createComponent();
      await waitForPromises();
    });

    it('shows no counts, like the Overview card', () => {
      expect(findTab().props('graphStats')).toBe(null);
    });
  });

  describe('when the URL repeats the entity parameter', () => {
    beforeEach(async () => {
      fetchOrbitSchema.mockResolvedValue({ data: mockExpandedSchema });
      createComponent({ query: { entity: ['job', 'pipeline'] } });
      await waitForPromises();
    });

    it('opens the first entity', () => {
      expect(findTab().props('initialEntity')).toBe('job');
    });
  });

  describe('when the schema has no nodes or edges', () => {
    beforeEach(async () => {
      fetchOrbitSchema.mockResolvedValue({ data: { schema_version: 'v1' } });
      createComponent();
      await waitForPromises();
    });

    it('gives the tab empty lists', () => {
      expect(findTab().props('schema')).toEqual({ schema_version: 'v1', nodes: [], edges: [] });
    });
  });

  describe('when the schema fails to load', () => {
    const error = new Error('503');

    beforeEach(async () => {
      fetchOrbitSchema.mockRejectedValueOnce(error);
      createComponent();
      await waitForPromises();
    });

    it('shows an error with a retry button and no loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
      expect(findTab().exists()).toBe(false);
      expect(findError().text()).toContain('Unable to load Orbit schema. Please try again.');
      expect(findError().props('primaryButtonText')).toBe('Try again');
      expect(Sentry.captureException).toHaveBeenCalledWith(error);
    });

    describe('and the user retries', () => {
      beforeEach(async () => {
        fetchOrbitSchema.mockResolvedValueOnce({ data: mockExpandedSchema });
        findError().vm.$emit('primary-action');
        await waitForPromises();
      });

      it('loads the schema again and shows the tab', () => {
        expect(fetchOrbitSchema).toHaveBeenCalledTimes(2);
        expect(findError().exists()).toBe(false);
        expect(findTab().props('schema')).toEqual(mockExpandedSchema);
      });
    });
  });
});
