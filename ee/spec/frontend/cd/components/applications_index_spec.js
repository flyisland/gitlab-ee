import { GlButton } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import ApplicationsIndex from 'ee/cd/components/applications_index.vue';
import ApplicationsList from 'ee/cd/components/applications_list.vue';
import FilterBar from 'ee/cd/components/shared/filter_bar.vue';
import NewApplicationPanel from 'ee/cd/components/new_application_panel.vue';
import {
  STATUS_ALL,
  STATUS_DEGRADED,
  STATUS_DEPLOYING,
  STATUS_HEALTHY,
  STATUS_PENDING,
} from 'ee/cd/constants';
import cdApplicationsQuery from 'ee/cd/graphql/cd_applications.query.graphql';

Vue.use(VueApollo);

describe('ApplicationsIndex', () => {
  let wrapper;

  const makeApplication = ({ id = '1', name = 'app-1' } = {}) => ({
    id,
    name,
    description: 'description',
    updatedAt: 'updated at',
  });

  const makeApplications = (count) =>
    Array.from({ length: count }, (_, index) => makeApplication({ id: `${index + 1}` }));

  const buildQueryResponse = (applications) => ({
    data: {
      organization: {
        id: 'gid://gitlab/Organizations::Organization/1',
        cdApplications: {
          nodes: applications,
        },
      },
    },
  });

  const defaultQueryHandler = jest.fn().mockResolvedValue(buildQueryResponse([makeApplication()]));

  const findPageHeading = () => wrapper.findComponent(PageHeading);
  const findNewApplicationButton = () => wrapper.findComponent(GlButton);
  const findApplicationsList = () => wrapper.findComponent(ApplicationsList);
  const findFilterBar = () => wrapper.findComponent(FilterBar);
  const findPanel = () => wrapper.findComponent(NewApplicationPanel);

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

  it('renders the applications list', () => {
    createComponent();

    expect(findApplicationsList().exists()).toBe(true);
  });

  describe('FilterBar filters', () => {
    it('passes the correct filters with counts to FilterBar', async () => {
      createComponent({
        queryHandler: jest.fn().mockResolvedValue(buildQueryResponse(makeApplications(4))),
      });
      await waitForPromises();

      expect(findFilterBar().props('filters')).toEqual([
        { id: STATUS_ALL, text: 'All', count: 4 },
        { id: STATUS_PENDING, text: 'Awaiting approval', count: 1 },
        { id: STATUS_DEGRADED, text: 'Degraded', count: 1 },
        { id: STATUS_DEPLOYING, text: 'Deploying', count: 1 },
        { id: STATUS_HEALTHY, text: 'Healthy', count: 1 },
      ]);
    });

    it('updates filter counts when the fetched applications change', async () => {
      createComponent({
        queryHandler: jest.fn().mockResolvedValue(buildQueryResponse(makeApplications(8))),
      });
      await waitForPromises();

      expect(findFilterBar().props('filters')).toEqual([
        { id: STATUS_ALL, text: 'All', count: 8 },
        { id: STATUS_PENDING, text: 'Awaiting approval', count: 2 },
        { id: STATUS_DEGRADED, text: 'Degraded', count: 2 },
        { id: STATUS_DEPLOYING, text: 'Deploying', count: 2 },
        { id: STATUS_HEALTHY, text: 'Healthy', count: 2 },
      ]);
    });

    it('passes STATUS_ALL as the selected filter by default', () => {
      createComponent();

      expect(findFilterBar().props('selectedFilterId')).toBe(STATUS_ALL);
    });

    it('sorts applications by status order when STATUS_ALL is selected', async () => {
      createComponent({
        queryHandler: jest.fn().mockResolvedValue(buildQueryResponse(makeApplications(4))),
      });
      await waitForPromises();

      const statuses = findApplicationsList()
        .props('applications')
        .map((app) => app.status);

      expect(statuses).toEqual([STATUS_PENDING, STATUS_DEGRADED, STATUS_DEPLOYING, STATUS_HEALTHY]);
    });

    it.each`
      label                  | status              | expectedCount
      ${'awaiting approval'} | ${STATUS_PENDING}   | ${1}
      ${'degraded'}          | ${STATUS_DEGRADED}  | ${2}
      ${'deploying'}         | ${STATUS_DEPLOYING} | ${1}
      ${'healthy'}           | ${STATUS_HEALTHY}   | ${2}
    `(
      'filters the list to only $label applications when filter-selected is emitted',
      async ({ status, expectedCount }) => {
        createComponent({
          queryHandler: jest.fn().mockResolvedValue(buildQueryResponse(makeApplications(6))),
        });
        await waitForPromises();

        await findFilterBar().vm.$emit('filter-selected', status);

        const displayed = findApplicationsList().props('applications');

        expect(displayed).toHaveLength(expectedCount);
        expect(displayed.every((app) => app.status === status)).toBe(true);
      },
    );

    it('shows all applications again when filter-selected is emitted with STATUS_ALL', async () => {
      createComponent({
        queryHandler: jest.fn().mockResolvedValue(buildQueryResponse(makeApplications(4))),
      });
      await waitForPromises();

      await findFilterBar().vm.$emit('filter-selected', STATUS_DEGRADED);

      expect(findApplicationsList().props('applications')).toHaveLength(1);

      await findFilterBar().vm.$emit('filter-selected', STATUS_ALL);

      expect(findApplicationsList().props('applications')).toHaveLength(4);
    });
  });

  describe('FilterBar search', () => {
    beforeEach(() => {
      createComponent();
    });

    it('passes the correct search placeholder to FilterBar', () => {
      expect(findFilterBar().props('searchPlaceholder')).toBe(
        'Search by name, team, or description',
      );
    });

    it('updates the searchTerm prop when FilterBar emits search', async () => {
      await findFilterBar().vm.$emit('search', 'my-app');

      expect(findFilterBar().props('searchTerm')).toBe('my-app');
    });
  });

  describe('new application panel', () => {
    beforeEach(() => {
      createComponent();
    });

    it('is closed by default', () => {
      expect(findPanel().props('open')).toBe(false);
    });

    it('passes the organization id to the panel', async () => {
      await waitForPromises();

      expect(findPanel().props('organizationId')).toBe(
        'gid://gitlab/Organizations::Organization/1',
      );
    });

    it('opens when the "New application" button is clicked', async () => {
      await findNewApplicationButton().vm.$emit('click');

      expect(findPanel().props('open')).toBe(true);
    });

    it('closes when the panel emits close', async () => {
      await findNewApplicationButton().vm.$emit('click');

      expect(findPanel().props('open')).toBe(true);

      await findPanel().vm.$emit('close');

      expect(findPanel().props('open')).toBe(false);
    });
  });
});
