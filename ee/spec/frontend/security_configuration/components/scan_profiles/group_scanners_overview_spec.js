import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlSkeletonLoader, GlTable, GlLink } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { stubComponent } from 'helpers/stub_component';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import GroupScannersOverview from 'ee/security_configuration/components/scan_profiles/group_scanners_overview.vue';
import SegmentedBar from 'ee/security_inventory/components/segmented_bar.vue';
import ScanTypeCell from '~/security_configuration/components/scan_profiles/scan_type_cell.vue';
import groupAvailableSecurityScanProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/group_available_security_scan_profiles.query.graphql';
import groupAnalyzerStatusesQuery from 'ee/security_configuration/graphql/scan_profiles/group_analyzer_statuses.query.graphql';
import { mockScanner, mockScanner2, mockAnalyzerStatus } from './mock_data';

Vue.use(VueApollo);

const GROUP_FULL_PATH = 'my-group';
const SECURITY_INVENTORY_PATH = '/groups/my-group/-/security/inventory';

describe('GroupScannersOverview', () => {
  let wrapper;

  const createAvailableScannersResolver = (scanners = [mockScanner]) =>
    jest.fn().mockResolvedValue({
      data: {
        group: {
          id: 'gid://gitlab/Group/1',
          name: GROUP_FULL_PATH,
          availableSecurityScanProfiles: scanners,
          __typename: 'Group',
        },
      },
    });

  const createAnalyzerStatusesResolver = (statuses = [mockAnalyzerStatus]) =>
    jest.fn().mockResolvedValue({
      data: {
        group: {
          id: 'gid://gitlab/Group/1',
          analyzerStatuses: statuses,
          __typename: 'Group',
        },
      },
    });

  const createComponent = ({
    availableScannersResolver = createAvailableScannersResolver(),
    analyzerStatusesResolver = createAnalyzerStatusesResolver(),
    stubs = {},
  } = {}) => {
    wrapper = mountExtended(GroupScannersOverview, {
      apolloProvider: createMockApollo([
        [groupAvailableSecurityScanProfilesQuery, availableScannersResolver],
        [groupAnalyzerStatusesQuery, analyzerStatusesResolver],
      ]),
      provide: {
        groupFullPath: GROUP_FULL_PATH,
        securityInventoryPath: SECURITY_INVENTORY_PATH,
      },
      stubs: { ScanTypeCell: true, ...stubs },
    });
  };

  const findTable = () => wrapper.findComponent(GlTable);
  const findSkeletonLoader = () => wrapper.findComponent(GlSkeletonLoader);
  const findSegmentedBars = () => wrapper.findAllComponents(SegmentedBar);
  const findScanTypeCells = () => wrapper.findAllComponents(ScanTypeCell);
  const findSecurityInventoryLink = () => wrapper.findComponent(GlLink);

  describe('description', () => {
    beforeEach(async () => {
      createComponent();

      await waitForPromises();
    });

    it('renders a link to the Security Inventory', () => {
      expect(findSecurityInventoryLink().attributes('href')).toBe(SECURITY_INVENTORY_PATH);
    });
  });

  describe('scanner list', () => {
    it('sets the table to busy while the scanner list is loading', () => {
      createComponent({
        availableScannersResolver: jest.fn().mockReturnValue(new Promise(() => {})),
        stubs: { GlTable: stubComponent(GlTable, { props: ['busy'] }) },
      });

      expect(findTable().props('busy')).toBe(true);
    });

    it('renders a row for each available scanner', async () => {
      createComponent({
        availableScannersResolver: createAvailableScannersResolver([mockScanner, mockScanner2]),
      });

      await waitForPromises();

      expect(findScanTypeCells()).toHaveLength(2);
    });
  });

  describe('coverage column', () => {
    it('shows a skeleton loader while analyzer statuses are loading', async () => {
      createComponent({
        analyzerStatusesResolver: jest.fn().mockReturnValue(new Promise(() => {})),
      });

      await waitForPromises();

      expect(findSkeletonLoader().exists()).toBe(true);
    });

    describe('when statuses have loaded', () => {
      beforeEach(async () => {
        createComponent();

        await waitForPromises();
      });

      it('renders a segmented bar showing active, failed, and not-configured counts', () => {
        expect(findSegmentedBars()).toHaveLength(1);
        expect(findSegmentedBars().at(0).props('segments')).toEqual([
          { class: 'gl-bg-green-500', count: 3, template: '%{count} active' },
          { class: 'gl-bg-red-500', count: 1, template: '%{count} failed' },
          { class: 'gl-bg-status-neutral', count: 6 },
        ]);
      });

      it('renders the active project coverage percentage', () => {
        expect(wrapper.text()).toContain('30%');
      });

      it('renders the active and failed project counts as text', () => {
        expect(wrapper.text()).toContain('3 active, 1 failed');
      });
    });

    describe('when total project count is zero', () => {
      it('shows 0%', async () => {
        createComponent({
          analyzerStatusesResolver: createAnalyzerStatusesResolver([
            { ...mockAnalyzerStatus, success: 0, failure: 0, notConfigured: 0 },
          ]),
        });

        await waitForPromises();

        expect(wrapper.text()).toContain('0%');
      });
    });
  });

  describe('empty state', () => {
    it('renders empty state text when there are no scanners', async () => {
      createComponent({ availableScannersResolver: createAvailableScannersResolver([]) });

      await waitForPromises();

      expect(wrapper.text()).toContain('No scanners enabled yet');
      expect(wrapper.text()).toContain(
        'Enable security scanning to automatically detect vulnerabilities in your projects.',
      );
    });
  });
});
