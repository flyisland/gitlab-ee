import { GlButton } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import ApplicationsIndex from 'ee/cd/components/applications_index.vue';
import FilterBar from 'ee/cd/components/shared/filter_bar.vue';
import cdApplicationsQuery from 'ee/cd/graphql/cd_applications.query.graphql';
import PageHeading from '~/vue_shared/components/page_heading.vue';

Vue.use(VueApollo);

describe('ApplicationsIndex', () => {
  let wrapper;

  const makeGroup = ({ name = 'group-1', applications = [] } = {}) => ({
    id: '1',
    name,
    cdApplications: {
      nodes: applications,
    },
  });

  const makeApplication = ({ name = 'app-1' } = {}) => ({
    id: '1',
    name,
    description: 'description',
    group: { id: '1', name: 'group name' },
    updatedAt: 'updated at',
  });

  const buildQueryResponse = (groups) => ({
    data: {
      organization: {
        id: '1',
        groups: {
          nodes: groups,
        },
      },
    },
  });

  const defaultQueryHandler = jest.fn().mockResolvedValue(buildQueryResponse([makeGroup()]));

  const findPageHeading = () => wrapper.findComponent(PageHeading);
  const findNewApplicationButton = () => wrapper.findComponent(GlButton);
  const findFilterBar = () => wrapper.findComponent(FilterBar);

  const createComponent = ({ queryHandler = defaultQueryHandler } = {}) => {
    wrapper = shallowMountExtended(ApplicationsIndex, {
      apolloProvider: createMockApollo([[cdApplicationsQuery, queryHandler]]),
    });
  };

  it('renders the page heading', () => {
    createComponent();

    expect(findPageHeading().props('heading')).toBe('Applications');
  });

  it('renders the New application button', () => {
    createComponent();

    expect(findNewApplicationButton().text()).toBe('New application');
    expect(findNewApplicationButton().props('variant')).toBe('confirm');
  });

  describe('filter bar', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the filter bar', () => {
      expect(findFilterBar().exists()).toBe(true);
    });

    it('passes the application status filters to the filter bar', () => {
      expect(findFilterBar().props('filters')).toEqual([
        { id: 'ALL', text: 'All' },
        { id: 'RUNNING', text: 'Running' },
        { id: 'DEGRADED', text: 'Degraded' },
      ]);
    });
  });

  describe('subheading text', () => {
    describe('with no groups and no applications', () => {
      beforeEach(async () => {
        createComponent({ queryHandler: jest.fn().mockResolvedValue(buildQueryResponse([])) });
        await waitForPromises();
      });

      it('shows 0 applications across 0 groups', () => {
        expect(findPageHeading().text()).toContain('0 applications across 0 groups');
      });
    });

    describe('with a single group and single application', () => {
      beforeEach(async () => {
        const app = makeApplication();
        const group = makeGroup({ applications: [app] });
        createComponent({ queryHandler: jest.fn().mockResolvedValue(buildQueryResponse([group])) });
        await waitForPromises();
      });

      it('uses singular "application" and singular "group" in the sub-heading', () => {
        expect(findPageHeading().text()).toContain('1 application across 1 group');
      });
    });

    describe('with a single group and multiple applications', () => {
      beforeEach(async () => {
        const apps = [makeApplication({ name: 'app-1' }), makeApplication({ name: 'app-2' })];
        const group = makeGroup({ applications: apps });
        createComponent({ queryHandler: jest.fn().mockResolvedValue(buildQueryResponse([group])) });
        await waitForPromises();
      });

      it('uses plural "applications" and singular "group"', () => {
        expect(findPageHeading().text()).toContain('2 applications across 1 group');
      });
    });

    describe('with multiple groups and multiple applications', () => {
      beforeEach(async () => {
        const group1 = makeGroup({
          name: 'group-1',
          applications: [makeApplication({ name: 'app-1' })],
        });
        const group2 = makeGroup({
          name: 'group-2',
          applications: [makeApplication({ name: 'app-2' })],
        });
        createComponent({
          queryHandler: jest.fn().mockResolvedValue(buildQueryResponse([group1, group2])),
        });
        await waitForPromises();
      });

      it('uses plural "applications" and plural "groups"', () => {
        expect(findPageHeading().text()).toContain('2 applications across 2 groups');
      });
    });
  });
});
