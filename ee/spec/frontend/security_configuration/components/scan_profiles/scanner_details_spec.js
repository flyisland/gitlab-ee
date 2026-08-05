import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlAlert, GlIcon, GlTable, GlKeysetPagination } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import setWindowLocation from 'helpers/set_window_location_helper';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { stubComponent } from 'helpers/stub_component';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import { smoothScrollTop } from '~/lib/utils/scroll_utils';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import ScannerDetails from 'ee/security_configuration/components/scan_profiles/scanner_details.vue';
import StatisticsCardRow from 'ee/security_configuration/components/scan_profiles/statistics_card_row.vue';
import ActionsCell from 'ee/security_configuration/components/scan_profiles/actions_cell.vue';
import LastScanCell from 'ee/security_configuration/components/scan_profiles/last_scan_cell.vue';
import SourceCell from 'ee/security_configuration/components/scan_profiles/source_cell.vue';
import TroubleshootJobDrawer from 'ee/security_configuration/components/scan_profiles/troubleshoot_job_drawer.vue';
import AttributesCell from 'ee/security_inventory/components/attributes_cell.vue';
import NameCell from 'ee/security_inventory/components/name_cell.vue';
import InventoryDashboardFilteredSearchBar from 'ee/security_inventory/components/inventory_dashboard_filtered_search_bar.vue';
import groupScannerDetailsProjectsQuery from 'ee/security_configuration/graphql/scan_profiles/group_scanner_details_projects.query.graphql';
import groupAvailableSecurityScanProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/group_available_security_scan_profiles.query.graphql';
import groupAnalyzerStatusesQuery from 'ee/security_configuration/graphql/scan_profiles/group_analyzer_statuses.query.graphql';
import attachMutation from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile_attach.mutation.graphql';
import detachMutation from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile_detach.mutation.graphql';
import { ROUTE_REVIEW } from 'ee/security_configuration/components/enable_scanners_wizard/constants';
import {
  mockScanner,
  mockProject,
  mockStatus,
  mockAnalyzerStatus,
  mockProjectAnalyzerStatus,
} from './mock_data';

Vue.use(VueApollo);

jest.mock('~/alert');
jest.mock('~/lib/utils/scroll_utils');

describe('ScannerDetails', () => {
  let wrapper;

  const createProjectsResolver = ({ nodes = [mockProject], pageInfo = {} } = {}) =>
    jest.fn().mockResolvedValue({
      data: {
        namespaceSecurityProjects: {
          nodes,
          pageInfo: {
            hasNextPage: false,
            hasPreviousPage: false,
            startCursor: null,
            endCursor: null,
            ...pageInfo,
          },
        },
      },
    });

  const projectWithProfileStatus = (statusOverride = {}) => ({
    ...mockProject,
    analyzerStatuses: [],
    scanProfileStatuses: [
      {
        __typename: 'ScanProfileProjectStatus',
        ...mockStatus,
        ...statusOverride,
        scanProfile: {
          __typename: 'ScanProfileType',
          ...mockStatus.scanProfile,
        },
      },
    ],
  });

  const projectsResolverWithProfileStatus = (statusOverride = {}) =>
    createProjectsResolver({ nodes: [projectWithProfileStatus(statusOverride)] });

  const createProfilesResolver = (profiles = [mockScanner]) =>
    jest.fn().mockResolvedValue({
      data: {
        group: {
          __typename: 'Group',
          id: 'gid://gitlab/Group/1',
          name: 'My Group',
          availableSecurityScanProfiles: profiles,
        },
      },
    });

  const createAnalyzerStatusesResolver = (statuses = [mockAnalyzerStatus]) =>
    jest.fn().mockResolvedValue({
      data: {
        group: {
          __typename: 'Group',
          id: 'gid://gitlab/Group/1',
          analyzerStatuses: statuses,
        },
      },
    });

  const createAttachHandler = () =>
    jest.fn().mockResolvedValue({
      data: {
        securityScanProfileAttach: {
          clientMutationId: '123',
          errors: [],
        },
      },
    });

  const createDetachHandler = () =>
    jest.fn().mockResolvedValue({
      data: {
        securityScanProfileDetach: {
          clientMutationId: '123',
          errors: [],
        },
      },
    });

  const createComponent = ({
    provide = {},
    routeParams = { scanner_key: 'SECRET_DETECTION' },
    projectsResolver = createProjectsResolver(),
    profilesResolver = createProfilesResolver(),
    analyzerStatusesResolver = createAnalyzerStatusesResolver(),
    attachHandler = createAttachHandler(),
    detachHandler = createDetachHandler(),
    stubs = {},
  } = {}) => {
    wrapper = mountExtended(ScannerDetails, {
      apolloProvider: createMockApollo([
        [groupScannerDetailsProjectsQuery, projectsResolver],
        [groupAvailableSecurityScanProfilesQuery, profilesResolver],
        [groupAnalyzerStatusesQuery, analyzerStatusesResolver],
        [attachMutation, attachHandler],
        [detachMutation, detachHandler],
      ]),
      provide: {
        groupFullPath: 'path/to/group',
        groupId: '123',
        groupName: 'My Group',
        canReadAttributes: false,
        canManageAttributes: false,
        ...provide,
      },
      mocks: {
        $route: { name: 'scanner_details', params: routeParams },
      },
      directives: {
        GlTooltip: createMockDirective('gl-tooltip'),
      },
      stubs: {
        InventoryDashboardFilteredSearchBar: true,
        NameCell: true,
        ActionsCell: stubComponent(ActionsCell),
        AttributesCell: stubComponent(AttributesCell),
        TroubleshootJobDrawer: stubComponent(TroubleshootJobDrawer),
        ...stubs,
      },
    });
  };

  const findPageHeading = () => wrapper.findComponent(PageHeading);
  const findTable = () => wrapper.findComponent(GlTable);
  const findTableRow = () => wrapper.findAll('tbody tr').at(0);
  const findFilteredSearchBar = () => wrapper.findComponent(InventoryDashboardFilteredSearchBar);
  const findPagination = () => wrapper.findComponent(GlKeysetPagination);
  const findActionsCell = () => wrapper.findComponent(ActionsCell);
  const findAttributesCell = () => wrapper.findComponent(AttributesCell);
  const findProfileTooltipIcon = () => wrapper.findComponent(GlIcon);
  const findStatisticsCardRow = () => wrapper.findComponent(StatisticsCardRow);
  const findLastScanCell = () => wrapper.findComponent(LastScanCell);
  const findTroubleshootDrawer = () => wrapper.findComponent(TroubleshootJobDrawer);
  const findCardFilterAlert = () => wrapper.findComponent(GlAlert);
  const findCardForStatus = (status) =>
    findStatisticsCardRow()
      .props('cards')
      .find((card) => card.filters.securityAnalyzerFilters[0]?.status === status);
  const findEnableScannerButton = () => wrapper.findByTestId('enable-scanner-button');
  const findEnableScannerButtonWrapper = () =>
    wrapper.findByTestId('enable-scanner-button-wrapper');

  describe('page heading', () => {
    it('renders the scanner name as the page heading based on the route parameter', () => {
      createComponent();

      expect(findPageHeading().props('heading')).toBe('Secret Detection configuration');
    });
  });

  describe('projects query', () => {
    it.each(['SECRET_DETECTION', 'SAST', 'DEPENDENCY_SCANNING'])(
      'requests projects sorted by the %s analyzer status',
      async (scannerKey) => {
        const projectsResolver = createProjectsResolver();
        createComponent({ projectsResolver, routeParams: { scanner_key: scannerKey } });
        await waitForPromises();

        expect(projectsResolver).toHaveBeenCalledWith(
          expect.objectContaining({ sortBy: scannerKey }),
        );
      },
    );
  });

  describe('enable scanner button', () => {
    describe('when the scanner has not-enabled projects', () => {
      it('renders an enabled "Enable scanner" button linking to the wizard review step', async () => {
        createComponent({ routeParams: { scanner_key: 'SECRET_DETECTION' } });
        await waitForPromises();

        expect(findEnableScannerButton().text()).toBe('Enable scanner');
        expect(findEnableScannerButton().props('disabled')).toBe(false);
        expect(findEnableScannerButton().props('to')).toEqual({
          name: ROUTE_REVIEW,
          query: { scanner: 'SECRET_DETECTION' },
        });
        expect(getBinding(findEnableScannerButtonWrapper().element, 'gl-tooltip').value).toBe('');
      });
    });

    describe('when the scanner has no not-enabled projects', () => {
      beforeEach(async () => {
        createComponent({
          analyzerStatusesResolver: createAnalyzerStatusesResolver([
            { ...mockAnalyzerStatus, notConfigured: 0 },
          ]),
        });
        await waitForPromises();
      });

      it('renders the button in a disabled state with no route', () => {
        expect(findEnableScannerButton().props('disabled')).toBe(true);
        expect(findEnableScannerButton().props('to')).toBeNull();
      });

      it('shows a tooltip on the wrapper explaining why the button is disabled', () => {
        expect(getBinding(findEnableScannerButtonWrapper().element, 'gl-tooltip').value).toBe(
          'This scanner is already enabled on all projects.',
        );
      });
    });

    describe('when a visible project has no matching profile (aggregation lag)', () => {
      it('keeps the button enabled even when scannerStatus.notConfigured is 0', async () => {
        createComponent({
          analyzerStatusesResolver: createAnalyzerStatusesResolver([
            { ...mockAnalyzerStatus, notConfigured: 0 },
          ]),
          projectsResolver: createProjectsResolver({
            nodes: [{ ...mockProject, securityScanProfiles: [] }],
          }),
        });
        await waitForPromises();

        expect(findEnableScannerButton().props('disabled')).toBe(false);
      });
    });

    describe('when the projects query is still loading', () => {
      beforeEach(async () => {
        createComponent({
          analyzerStatusesResolver: createAnalyzerStatusesResolver([
            { ...mockAnalyzerStatus, notConfigured: 0 },
          ]),
          projectsResolver: jest.fn().mockReturnValue(new Promise(() => {})),
        });
        await waitForPromises();
      });

      it('renders the button in a disabled state with no route', () => {
        expect(findEnableScannerButton().props('disabled')).toBe(true);
        expect(findEnableScannerButton().props('to')).toBeNull();
      });

      it('shows no tooltip while loading', () => {
        expect(getBinding(findEnableScannerButtonWrapper().element, 'gl-tooltip').value).toBe('');
      });
    });
  });

  describe('loading state', () => {
    it('shows the table in busy state while projects are loading', () => {
      createComponent({
        projectsResolver: jest.fn().mockReturnValue(new Promise(() => {})),
        stubs: { GlTable: stubComponent(GlTable, { props: ['busy'] }) },
      });

      expect(findTable().props('busy')).toBe(true);
    });
  });

  describe('project table row', () => {
    describe('when a project has no matching profile for the scanner', () => {
      it('shows "No profile applied"', async () => {
        createComponent({
          projectsResolver: createProjectsResolver({
            nodes: [{ ...mockProject, securityScanProfiles: [] }],
          }),
        });

        await waitForPromises();

        expect(findTableRow().text()).toContain('No profile applied');
      });
    });

    describe('when a project has a matching profile', () => {
      it('shows the profile name', async () => {
        createComponent();

        await waitForPromises();

        expect(findTableRow().text()).toContain('Secret Detection Profile');
      });
    });

    describe('when an analyzer status is available', () => {
      it('shows the normalized status label', async () => {
        createComponent();

        await waitForPromises();

        expect(findTableRow().text()).toContain('Enabled');
      });

      it('shows the last scan date', async () => {
        createComponent();

        await waitForPromises();

        expect(findTableRow().text()).toMatch(/Apr\s+14,?\s+2026/);
      });
    });

    describe('when no analyzer status is available for the scanner', () => {
      it('shows "Not enabled"', async () => {
        createComponent({
          projectsResolver: createProjectsResolver({
            nodes: [{ ...mockProject, analyzerStatuses: [] }],
          }),
        });

        await waitForPromises();

        expect(findTableRow().text()).toContain('Not enabled');
      });

      it('shows an empty dash for the last scan date', async () => {
        createComponent({
          projectsResolver: createProjectsResolver({
            nodes: [{ ...mockProject, analyzerStatuses: [] }],
          }),
        });

        await waitForPromises();

        expect(findTableRow().text()).toContain('—');
      });
    });

    it('renders a SourceCell for each project row', async () => {
      createComponent();

      await waitForPromises();

      const sourceCell = wrapper.findComponent(SourceCell);
      expect(sourceCell.exists()).toBe(true);
      expect(sourceCell.props()).toMatchObject({
        item: expect.objectContaining({ id: mockProject.id }),
        scannerKey: 'SECRET_DETECTION',
      });
    });

    it('renders the security attributes column when canReadAttributes is true', async () => {
      createComponent({ provide: { canReadAttributes: true } });

      await waitForPromises();

      expect(findAttributesCell().exists()).toBe(true);
    });

    it('does not render the security attributes column when canReadAttributes is false', async () => {
      createComponent();

      await waitForPromises();

      expect(findAttributesCell().exists()).toBe(false);
    });

    it('renders an actions cell', async () => {
      createComponent();

      await waitForPromises();

      expect(findActionsCell().exists()).toBe(true);
    });
  });

  describe('subgroup navigation', () => {
    it('passes a link to subgroup configuration, keeping the current scanner, when the project is in a subgroup', async () => {
      setWindowLocation('/groups/path/to/group/-/security/configuration');
      createComponent();

      await waitForPromises();

      expect(wrapper.findComponent(NameCell).props('subgroupHref')).toBe(
        '/groups/my-group/-/security/configuration#/scanners/SECRET_DETECTION',
      );
    });

    it('passes no link for projects that are direct descendants of the current group', async () => {
      // mockProject's parent is my-group
      setWindowLocation('/groups/my-group/-/security/configuration');
      createComponent({ provide: { groupFullPath: 'my-group' } });

      await waitForPromises();

      expect(wrapper.findComponent(NameCell).props('subgroupHref')).toBe('');
    });
  });

  describe('profile tooltip', () => {
    it('renders an info tooltip on the Profile column header containing the scanner name', async () => {
      createComponent();

      await waitForPromises();

      expect(findProfileTooltipIcon().attributes('title')).toContain(
        'How Secret Detection is configured for each project.',
      );
    });
  });

  describe('profile actions', () => {
    it('attaches the default profile to a project when actions cell emits apply-profile', async () => {
      const attachHandler = createAttachHandler();
      const analyzerStatusesResolver = createAnalyzerStatusesResolver();

      createComponent({
        attachHandler,
        analyzerStatusesResolver,
        profilesResolver: createProfilesResolver([mockScanner]),
        projectsResolver: createProjectsResolver({
          nodes: [{ ...mockProject, securityScanProfiles: [] }],
        }),
      });
      await waitForPromises();

      findActionsCell().vm.$emit('apply-profile');
      await waitForPromises();

      expect(attachHandler).toHaveBeenCalled();
      expect(analyzerStatusesResolver).toHaveBeenCalledTimes(2);
    });

    it('detaches the matching profile from a project when actions cell emits disable-profile', async () => {
      const detachHandler = createDetachHandler();
      const analyzerStatusesResolver = createAnalyzerStatusesResolver();

      createComponent({ detachHandler, analyzerStatusesResolver });
      await waitForPromises();

      findActionsCell().vm.$emit('disable-profile');
      await waitForPromises();

      expect(detachHandler).toHaveBeenCalled();
      expect(analyzerStatusesResolver).toHaveBeenCalledTimes(2);
    });

    it('shows an alert when apply-profile is emitted with no default profile', async () => {
      createComponent({ profilesResolver: createProfilesResolver([]) });
      await waitForPromises();

      findActionsCell().vm.$emit('apply-profile');
      await waitForPromises();

      expect(createAlert).toHaveBeenCalled();
    });

    it('shows an alert when disable-profile is emitted with no matching profile', async () => {
      createComponent({
        projectsResolver: createProjectsResolver({
          nodes: [{ ...mockProject, securityScanProfiles: [] }],
        }),
      });
      await waitForPromises();

      findActionsCell().vm.$emit('disable-profile');
      await waitForPromises();

      expect(createAlert).toHaveBeenCalled();
    });
  });

  describe('troubleshoot failure', () => {
    it('opens the drawer when ActionsCell emits troubleshoot-failure', async () => {
      createComponent({
        projectsResolver: projectsResolverWithProfileStatus({ status: 'FAILED' }),
      });
      await waitForPromises();

      findActionsCell().vm.$emit('troubleshoot-failure');
      await nextTick();

      const drawer = findTroubleshootDrawer();
      expect(drawer.exists()).toBe(true);
      expect(drawer.props()).toMatchObject({
        buildId: mockStatus.buildId,
        status: 'failed',
      });
    });
  });

  describe('last scan cell', () => {
    it('passes the analyzer updatedAt date and no buildId when only an analyzer status exists', async () => {
      createComponent();
      await waitForPromises();

      const cell = findLastScanCell();
      expect(cell.exists()).toBe(true);
      expect(cell.props()).toMatchObject({
        lastScanAt: mockProject.analyzerStatuses[0].updatedAt,
        buildId: null,
        linkVariant: 'pipeline-job',
        projectFullPath: mockProject.fullPath,
      });
    });

    it('passes the scan-profile buildId and lastScanAt when a profile status exists', async () => {
      createComponent({ projectsResolver: projectsResolverWithProfileStatus() });
      await waitForPromises();

      const cell = findLastScanCell();
      expect(cell.props()).toMatchObject({
        lastScanAt: mockStatus.lastScanAt,
        buildId: mockStatus.buildId,
        status: mockStatus.status.toLowerCase(),
      });
    });
  });

  describe('troubleshoot job drawer', () => {
    const mockJobData = { name: 'job-x', status: 'failed' };

    const openDrawerOnFailedRow = async () => {
      createComponent({
        projectsResolver: projectsResolverWithProfileStatus({ status: 'FAILED' }),
      });
      await waitForPromises();
      findLastScanCell().vm.$emit('open-drawer', mockJobData);
      await nextTick();
    };

    it('does not render the drawer initially', async () => {
      createComponent();
      await waitForPromises();

      expect(findTroubleshootDrawer().exists()).toBe(false);
    });

    it('opens the drawer with correct props when LastScanCell emits open-drawer', async () => {
      await openDrawerOnFailedRow();

      const drawer = findTroubleshootDrawer();
      expect(drawer.exists()).toBe(true);
      expect(drawer.props()).toMatchObject({
        openDrawer: true,
        jobData: mockJobData,
        buildId: mockStatus.buildId,
        status: 'failed',
        scanType: 'SECRET_DETECTION',
        fullPath: mockProject.fullPath,
      });
    });

    it('closes the drawer when close-drawer is emitted', async () => {
      await openDrawerOnFailedRow();
      expect(findTroubleshootDrawer().exists()).toBe(true);

      findTroubleshootDrawer().vm.$emit('close-drawer');
      await nextTick();

      expect(findTroubleshootDrawer().exists()).toBe(false);
    });
  });

  describe('render the relevant status', () => {
    it.each([
      ['ACTIVE', 'Enabled'],
      ['SUCCESS', 'Enabled'],
      ['PENDING', 'Pending'],
      ['UNCONFIGURED', 'Not enabled'],
      ['NOT_CONFIGURED', 'Not enabled'],
      ['FAILED', 'Failed'],
      ['STALE', 'Stale'],
      ['WARNING', 'Warning'],
    ])('renders correct label from %s to %s', async (backendStatus, expectedLabel) => {
      createComponent({
        projectsResolver: projectsResolverWithProfileStatus({ status: backendStatus }),
      });
      await waitForPromises();

      expect(findTableRow().text()).toContain(expectedLabel);
    });

    describe('when an analyzer failure is layered on top of a profile status', () => {
      const projectWithProfileAndFailedAnalyzer = (profileStatus) => ({
        ...mockProject,
        analyzerStatuses: [{ ...mockProjectAnalyzerStatus, status: 'Failed' }],
        scanProfileStatuses: [
          {
            __typename: 'ScanProfileProjectStatus',
            ...mockStatus,
            status: profileStatus,
            scanProfile: {
              __typename: 'ScanProfileType',
              ...mockStatus.scanProfile,
            },
          },
        ],
      });

      it.each([
        ['ACTIVE', 'Enabled, last scan failed'],
        ['PENDING', 'Pending, last scan failed'],
      ])(
        'surfaces the failure with a combined "%s" label when the profile is %s',
        async (profileStatus, expectedLabel) => {
          createComponent({
            projectsResolver: createProjectsResolver({
              nodes: [projectWithProfileAndFailedAnalyzer(profileStatus)],
            }),
          });
          await waitForPromises();

          expect(findTableRow().text()).toContain(expectedLabel);
        },
      );

      it.each([
        ['WARNING', 'Warning'],
        ['FAILED', 'Failed'],
        ['STALE', 'Stale'],
      ])(
        'keeps the profile label "%s" when the profile already conveys a scan concern',
        async (profileStatus, expectedLabel) => {
          createComponent({
            projectsResolver: createProjectsResolver({
              nodes: [projectWithProfileAndFailedAnalyzer(profileStatus)],
            }),
          });
          await waitForPromises();

          const rowText = findTableRow().text();
          expect(rowText).toContain(expectedLabel);
          expect(rowText).not.toContain('last scan failed');
        },
      );

      it('passes the profile buildId and analyzer updatedAt to LastScanCell', async () => {
        createComponent({
          projectsResolver: createProjectsResolver({
            nodes: [projectWithProfileAndFailedAnalyzer('ACTIVE')],
          }),
        });
        await waitForPromises();

        expect(findLastScanCell().props()).toMatchObject({
          buildId: mockStatus.buildId,
          lastScanAt: mockProjectAnalyzerStatus.updatedAt,
        });
      });
    });
  });

  describe('statistics cards', () => {
    describe('when loading', () => {
      it('shows a loading state while the analyzer statuses query is loading', async () => {
        createComponent({
          analyzerStatusesResolver: jest.fn().mockReturnValue(new Promise(() => {})),
        });

        await waitForPromises();

        expect(findStatisticsCardRow().props('loading')).toBe(true);
      });
    });

    describe('with data', () => {
      beforeEach(async () => {
        createComponent();

        await waitForPromises();
      });

      it('passes the matching analyzer status to the cards', () => {
        expect(findStatisticsCardRow().props('cards')).toEqual([
          {
            title: 'Enabled',
            value: 3,
            description: 'Projects with Secret Detection running successfully',
            filters: {
              securityAnalyzerFilters: [{ analyzerType: 'SECRET_DETECTION', status: 'SUCCESS' }],
            },
          },
          {
            title: 'Not enabled',
            value: 6,
            description: 'Projects without Secret Detection enabled',
            filters: {
              securityAnalyzerFilters: [
                { analyzerType: 'SECRET_DETECTION', status: 'NOT_CONFIGURED' },
              ],
            },
          },
          {
            title: 'Needs attention',
            value: 1,
            description: 'Project with scan failures',
            filters: {
              securityAnalyzerFilters: [{ analyzerType: 'SECRET_DETECTION', status: 'FAILED' }],
            },
          },
          {
            title: 'Stale',
            value: 2,
            description: 'Projects not scanned in 90+ days',
            filters: {
              securityAnalyzerFilters: [{ analyzerType: 'SECRET_DETECTION', status: 'STALE' }],
            },
          },
        ]);
      });
    });

    describe('on error', () => {
      it.each([
        ['the analyzer statuses query fails', jest.fn().mockRejectedValue(new Error())],
        [
          'no analyzer status matches the scanner',
          createAnalyzerStatusesResolver([{ ...mockAnalyzerStatus, analyzerType: 'SAST' }]),
        ],
      ])(
        'shows the error state and creates an alert when %s',
        async (_, analyzerStatusesResolver) => {
          createComponent({ analyzerStatusesResolver });

          await waitForPromises();

          expect(findStatisticsCardRow().props('error')).toBe(true);
          expect(createAlert).toHaveBeenCalledWith({
            message: 'Failed to load scanner statistics',
          });
        },
      );
    });
  });

  describe('viewing projects for a card', () => {
    let projectsResolver;

    beforeEach(async () => {
      projectsResolver = createProjectsResolver({
        pageInfo: { hasNextPage: true, endCursor: 'END_CURSOR' },
      });
      createComponent({ projectsResolver });
      await waitForPromises();
    });

    it('filters the projects list by the card status and replaces the search bar with an alert', async () => {
      const card = findCardForStatus('FAILED');
      findStatisticsCardRow().vm.$emit('view-projects', card);
      await waitForPromises();

      expect(projectsResolver).toHaveBeenLastCalledWith(
        expect.objectContaining({
          securityAnalyzerFilters: [{ analyzerType: 'SECRET_DETECTION', status: 'FAILED' }],
        }),
      );
      expect(findFilteredSearchBar().exists()).toBe(false);
      expect(findCardFilterAlert().exists()).toBe(true);
      expect(findCardFilterAlert().props('title')).toBe(card.title);
    });

    it('clears the filter and restores the search bar when the alert is dismissed', async () => {
      findStatisticsCardRow().vm.$emit('view-projects', findCardForStatus('FAILED'));
      await waitForPromises();

      findCardFilterAlert().vm.$emit('dismiss');
      await waitForPromises();

      expect(findCardFilterAlert().exists()).toBe(false);
      expect(findFilteredSearchBar().exists()).toBe(true);
    });

    it('resets pagination cursors when a card filter is applied', async () => {
      findPagination().vm.$emit('next', 'END_CURSOR');
      await waitForPromises();

      expect(projectsResolver).toHaveBeenLastCalledWith(
        expect.objectContaining({ after: 'END_CURSOR' }),
      );

      findStatisticsCardRow().vm.$emit('view-projects', findCardForStatus('FAILED'));
      await waitForPromises();

      expect(projectsResolver).toHaveBeenLastCalledWith(
        expect.objectContaining({ after: null, before: null }),
      );
    });

    it('resets pagination cursors when the card filter is cleared', async () => {
      findStatisticsCardRow().vm.$emit('view-projects', findCardForStatus('FAILED'));
      await waitForPromises();

      findPagination().vm.$emit('next', 'END_CURSOR');
      await waitForPromises();

      expect(projectsResolver).toHaveBeenLastCalledWith(
        expect.objectContaining({ after: 'END_CURSOR' }),
      );

      findCardFilterAlert().vm.$emit('dismiss');
      await waitForPromises();

      // we check that we did NOT get the second page in order to know that the cursor was cleared
      // the resolver is not called again because the first page is served from the cache
      expect(projectsResolver).not.toHaveBeenCalledWith(
        expect.objectContaining({ after: 'END_CURSOR', securityAnalyzerFilters: [] }),
      );
    });
  });

  describe('filtered search bar', () => {
    it('renders the InventoryDashboardFilteredSearchBar', () => {
      createComponent();

      expect(findFilteredSearchBar().exists()).toBe(true);
    });

    it('updates the query variables and resets pagination cursors when filters change', async () => {
      const projectsResolver = createProjectsResolver({
        pageInfo: { hasNextPage: true, endCursor: 'END_CURSOR' },
      });
      createComponent({ projectsResolver });
      await waitForPromises();

      findPagination().vm.$emit('next', 'END_CURSOR');
      await waitForPromises();

      expect(projectsResolver).toHaveBeenLastCalledWith(
        expect.objectContaining({ after: 'END_CURSOR' }),
      );

      findFilteredSearchBar().vm.$emit('filter-subgroups-and-projects', { search: 'test project' });
      await waitForPromises();

      expect(projectsResolver).toHaveBeenLastCalledWith(
        expect.objectContaining({
          search: 'test project',
          after: null,
          before: null,
        }),
      );
    });
  });

  describe('pagination', () => {
    it('does not show pagination when there is only one page', async () => {
      createComponent();

      await waitForPromises();

      expect(findPagination().exists()).toBe(false);
    });

    it('goes to the next page and scrolls to top when the next button is clicked', async () => {
      const projectsResolver = createProjectsResolver({
        pageInfo: { hasNextPage: true, endCursor: 'END_CURSOR' },
      });
      createComponent({ projectsResolver });
      await waitForPromises();

      findPagination().vm.$emit('next', 'END_CURSOR');
      await waitForPromises();

      expect(projectsResolver).toHaveBeenLastCalledWith(
        expect.objectContaining({
          after: 'END_CURSOR',
          before: null,
          first: 20,
          last: null,
        }),
      );
      expect(smoothScrollTop).toHaveBeenCalled();
    });

    it('goes to the previous page and scrolls to top when the prev button is clicked', async () => {
      const projectsResolver = createProjectsResolver({
        pageInfo: { hasPreviousPage: true, startCursor: 'START_CURSOR' },
      });
      createComponent({ projectsResolver });
      await waitForPromises();

      findPagination().vm.$emit('prev', 'START_CURSOR');
      await waitForPromises();

      expect(projectsResolver).toHaveBeenLastCalledWith(
        expect.objectContaining({
          before: 'START_CURSOR',
          after: null,
          first: null,
          last: 20,
        }),
      );
      expect(smoothScrollTop).toHaveBeenCalled();
    });
  });
});
