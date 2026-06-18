import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';
import { useFakeDate } from 'helpers/fake_date';
import ExtendedDashboardPanel from '~/vue_shared/components/customizable_dashboard/extended_dashboard_panel.vue';
import AgenticAdoptionFunnelPanel from 'ee/security_dashboard/components/shared/agentic_adoption_funnel_panel.vue';
import OverTimePeriodSelector from 'ee/security_dashboard/components/shared/over_time_period_selector.vue';
import groupVulnerabilityResolutionFunnel from 'ee/security_dashboard/graphql/queries/group_vulnerability_resolution_funnel.query.graphql';
import projectVulnerabilityResolutionFunnel from 'ee/security_dashboard/graphql/queries/project_vulnerability_resolution_funnel.query.graphql';
import { vulnerabilityResolutionFunnelResolvers } from 'ee/security_dashboard/graphql/resolvers/vulnerability_resolution_funnel_resolver';
import { mockSecurityAttributesFilters } from '../mock_data';

Vue.use(VueApollo);

describe('AgenticAdoptionFunnelPanel', () => {
  // Pin the clock so the derived startDate/endDate are deterministic.
  useFakeDate(2026, 5, 5); // 2026-06-05 (month is zero-based)

  let wrapper;
  let funnelHandler;

  const mockGroupFullPath = 'group/subgroup';
  const mockProjectFullPath = 'namespace/project';
  const mockGroupFilters = {
    projectId: ['gid://gitlab/Project/123'],
    securityAttributesFilters: mockSecurityAttributesFilters,
    reportType: ['SAST'],
  };

  // The @client funnel field is stripped from the handler document and filled by
  // the local resolver, so the handler only needs to return the server portion.
  const serverResponse = (typename = 'Group', idValue = 'gid://gitlab/Group/1') => ({
    data: {
      namespace: {
        __typename: typename,
        id: idValue,
        securityMetrics: { __typename: 'SecurityMetrics' },
      },
    },
  });

  const createComponent = ({
    scope = 'group',
    props,
    mockHandler = null,
    fullPath = mockGroupFullPath,
    query = groupVulnerabilityResolutionFunnel,
  } = {}) => {
    funnelHandler = mockHandler || jest.fn().mockResolvedValue(serverResponse());
    const apolloProvider = createMockApollo(
      [[query, funnelHandler]],
      vulnerabilityResolutionFunnelResolvers,
    );

    wrapper = shallowMountExtended(AgenticAdoptionFunnelPanel, {
      apolloProvider,
      provide: { fullPath },
      propsData: {
        scope,
        filters: mockGroupFilters,
        ...props,
      },
    });
  };

  const findPanel = () => wrapper.findComponent(ExtendedDashboardPanel);
  const findTimePeriodSelector = () => wrapper.findComponent(OverTimePeriodSelector);
  const findData = () => wrapper.findByTestId('agentic-adoption-funnel-data');
  const findEmptyState = () => wrapper.findByTestId('agentic-adoption-funnel-empty-state');

  beforeEach(() => {
    createComponent();
  });

  describe('component rendering', () => {
    it('renders the panel with the correct title', () => {
      expect(findPanel().props('title')).toBe('SAST triage and remediation funnel');
    });

    it('renders the time period selector', () => {
      expect(findTimePeriodSelector().exists()).toBe(true);
    });

    it('renders the mocked funnel data as a JSON snippet', async () => {
      await waitForPromises();

      const data = findData();
      expect(data.exists()).toBe(true);
      expect(data.text()).toContain('"detectedVulnerabilities"');
      expect(data.text()).toContain('"count": 1240');
      expect(data.text()).toContain('"status": "AVAILABLE"');
      expect(data.text()).toContain('"status": "UNAVAILABLE_DISABLED"');
    });
  });

  describe('Apollo query', () => {
    it('queries with the time period as a date range and the group filters', () => {
      expect(funnelHandler).toHaveBeenCalledWith({
        fullPath: mockGroupFullPath,
        projectId: mockGroupFilters.projectId,
        securityAttributesFilters: mockSecurityAttributesFilters,
        startDate: '2026-05-06',
        endDate: '2026-06-05',
      });
    });

    it('does not send reportType (the funnel is SAST-only)', () => {
      expect(funnelHandler).toHaveBeenCalledWith(
        expect.not.objectContaining({ reportType: expect.anything() }),
      );
    });

    it('refetches with an updated date range when the time period changes', async () => {
      await findTimePeriodSelector().vm.$emit('input', 90);
      await waitForPromises();

      expect(funnelHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          startDate: '2026-03-07',
          endDate: '2026-06-05',
        }),
      );
    });
  });

  describe('loading state', () => {
    it('shows loading state initially', () => {
      expect(findPanel().props('loading')).toBe(true);
    });

    it('hides loading state after data is loaded', async () => {
      await waitForPromises();

      expect(findPanel().props('loading')).toBe(false);
    });
  });

  describe('error handling', () => {
    it('shows the error state when the query fails', async () => {
      createComponent({ mockHandler: jest.fn().mockRejectedValue(new Error('GraphQL error')) });

      await waitForPromises();

      expect(findPanel().props('showAlertState')).toBe(true);
      expect(findData().exists()).toBe(false);
      expect(findEmptyState().text()).toBe('Something went wrong. Please try again.');
    });

    it('resets the error state when a new fetch begins', async () => {
      createComponent({
        mockHandler: jest
          .fn()
          .mockRejectedValueOnce(new Error('GraphQL error'))
          .mockResolvedValue(serverResponse()),
      });

      await waitForPromises();
      expect(findEmptyState().text()).toBe('Something went wrong. Please try again.');

      await findTimePeriodSelector().vm.$emit('input', 90);
      await waitForPromises();

      expect(findEmptyState().exists()).toBe(false);
      expect(findPanel().props('showAlertState')).toBe(false);
    });
  });

  describe('when scope is "project"', () => {
    const projectFilters = {
      trackedRefIds: ['gid://gitlab/Security::ProjectTrackedContext/1'],
      reportType: ['SAST'],
    };

    beforeEach(() => {
      createComponent({
        scope: 'project',
        fullPath: mockProjectFullPath,
        query: projectVulnerabilityResolutionFunnel,
        props: { filters: projectFilters },
        mockHandler: jest
          .fn()
          .mockResolvedValue(serverResponse('Project', 'gid://gitlab/Project/1')),
      });
    });

    it('uses the project query with trackedRefIds and the date range', () => {
      expect(funnelHandler).toHaveBeenCalledWith({
        fullPath: mockProjectFullPath,
        trackedRefIds: projectFilters.trackedRefIds,
        startDate: '2026-05-06',
        endDate: '2026-06-05',
      });
    });

    it('does not send group-level filters (projectId, securityAttributesFilters)', () => {
      expect(funnelHandler).toHaveBeenCalledWith(
        expect.not.objectContaining({
          projectId: expect.anything(),
          securityAttributesFilters: expect.anything(),
        }),
      );
    });

    it('renders the funnel data from the project response', async () => {
      await waitForPromises();

      expect(findData().exists()).toBe(true);
    });
  });
});
