import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import {
  GlTable,
  GlButton,
  GlAlert,
  GlLink,
  GlDisclosureDropdownItem,
  GlLoadingIcon,
  GlPopover,
} from '@gitlab/ui';
import { PROMO_URL } from '~/constants';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { stubComponent } from 'helpers/stub_component';
import ScanProfileConfiguration from 'ee/security_configuration/components/scan_profiles/scan_profile_configuration.vue';
import ScanProfileTable from '~/security_configuration/components/scan_profiles/scan_profile_table.vue';
import DisableScanProfileConfirmationModal from 'ee/security_configuration/components/scan_profiles/disable_scan_profile_confirmation_modal.vue';
import ScanProfileDetailsModal from 'ee/security_configuration/components/scan_profiles/scan_profile_details_modal.vue';
import InsufficientPermissionsPopover from 'ee/security_configuration/components/scan_profiles/insufficient_permissions_popover.vue';
import ScanProfileLaunchModal from 'ee/security_configuration/components/scan_profiles/scan_profile_launch_modal.vue';
import JobDetailsPopover from 'ee/security_configuration/components/scan_profiles/job_details_popover.vue';
import TroubleshootJobDrawer from 'ee/security_configuration/components/scan_profiles/troubleshoot_job_drawer.vue';
import availableProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/group_available_security_scan_profiles.query.graphql';
import projectProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/project_security_scan_profiles.query.graphql';
import attachMutation from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile_attach.mutation.graphql';
import detachMutation from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile_detach.mutation.graphql';
import profileDetailsQuery from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile.query.graphql';

Vue.use(VueApollo);

describe('ScanProfileConfiguration', () => {
  let wrapper;
  let mockToastShow;

  const mockProfile = {
    id: 'gid://gitlab/Security::ScanProfile/2',
    name: 'Secret Push Protection (default)',
    description:
      "GitLab's recommended baseline protection using industry-standard detection rules. Blocks common secrets like API keys, tokens, and passwords from being committed to your repository, with detection optimized to minimize false positives",
    gitlabRecommended: true,
    scanType: 'SECRET_DETECTION',
    triggers: ['GIT_PUSH_EVENT', 'MERGE_REQUEST_PIPELINE', 'DEFAULT_BRANCH_PIPELINE'],
    __typename: 'ScanProfileType',
  };

  // active, failed, warning, stale, unconfigured
  const mockStatus = {
    scanType: 'SECRET_DETECTION',
    id: mockProfile.id,
    status: 'ACTIVE',
    consecutiveFailureCount: 0,
    consecutiveSuccessCount: 5,
    lastScanAt: '2026-03-17T14:30:00Z',
    buildId: 'gid://gitlab/CommitStatus/123',
  };
  const mockStatusWithStatus = (status) => ({ ...mockStatus, status });

  const mockDsProfile = {
    id: 'gid://gitlab/Security::ScanProfile/dependency_scanning',
    name: 'Dependency Scanning - Standard',
    description:
      "Identify known vulnerabilities in your project's open source dependencies before they reach production.",
    gitlabRecommended: true,
    scanType: 'DEPENDENCY_SCANNING',
    triggers: ['MERGE_REQUEST_PIPELINE', 'DEFAULT_BRANCH_PIPELINE'],
    __typename: 'ScanProfileType',
  };

  const mockProjectId = 'gid://gitlab/Project/1';

  const createAvailableProfilesResolver = (profiles = [mockProfile]) =>
    jest.fn().mockResolvedValue({
      data: {
        group: {
          id: 'gid://gitlab/Group/1',
          name: 'group',
          availableSecurityScanProfiles: profiles,
          __typename: 'Group',
        },
      },
    });

  const createProjectProfilesResolver = (profiles = []) =>
    jest.fn().mockResolvedValue({
      data: {
        project: {
          id: mockProjectId,
          name: 'project',
          securityScanProfiles: profiles,
          __typename: 'Project',
        },
      },
    });

  const createAttachMutationResolver = (errors = []) =>
    jest.fn().mockResolvedValue({ data: { securityScanProfileAttach: { errors } } });

  const createDetachMutationResolver = (errors = []) =>
    jest.fn().mockResolvedValue({ data: { securityScanProfileDetach: { errors } } });

  const createProfileDetailsResolver = (profile = mockProfile) =>
    jest.fn().mockResolvedValue({ data: { securityScanProfile: profile } });

  const createComponent = ({
    availableProfilesResolver = createAvailableProfilesResolver(),
    projectProfilesResolver = createProjectProfilesResolver(),
    attachResolver = createAttachMutationResolver(),
    detachResolver = createDetachMutationResolver(),
    profileDetailsResolver = createProfileDetailsResolver(),
    canApplyProfiles = true,
    securityScanProfilesLicensed = true,
    glFeatures = {},
    statuses = [],
  } = {}) => {
    mockToastShow = jest.fn();

    const apolloProvider = createMockApollo([
      [availableProfilesQuery, availableProfilesResolver],
      [projectProfilesQuery, projectProfilesResolver],
      [attachMutation, attachResolver],
      [detachMutation, detachResolver],
      [profileDetailsQuery, profileDetailsResolver],
    ]);

    wrapper = mountExtended(ScanProfileConfiguration, {
      apolloProvider,
      provide: {
        projectFullPath: 'group/project',
        groupFullPath: 'group',
        canApplyProfiles,
        securityScanProfilesLicensed,
        glFeatures,
      },
      mocks: {
        $toast: { show: mockToastShow },
      },
      stubs: {
        ScanProfileLaunchModal: stubComponent(ScanProfileLaunchModal),
        JobDetailsPopover: stubComponent(JobDetailsPopover),
        TroubleshootJobDrawer: stubComponent(TroubleshootJobDrawer),
      },
      data() {
        return { statuses };
      },
    });

    return wrapper;
  };

  const findTable = () => wrapper.findComponent(ScanProfileTable);
  const findGlTable = () => wrapper.findComponent(GlTable);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findLink = () => wrapper.findByTestId('learn-more-ultimate-link');
  const findDisableModal = () => wrapper.findComponent(DisableScanProfileConfirmationModal);
  const findDetailsModal = () => wrapper.findComponent(ScanProfileDetailsModal);
  const findPopover = () => wrapper.findComponent(InsufficientPermissionsPopover);
  const findDropdownItems = () => wrapper.findAllComponents(GlDisclosureDropdownItem);
  const findJobDetailsPopover = () => wrapper.findComponent(JobDetailsPopover);
  const findTroubleshootDrawer = () => wrapper.findComponent(TroubleshootJobDrawer);
  const findGlPopover = () => wrapper.findComponent(GlPopover);

  const findDisableDropdownItem = () =>
    findDropdownItems().wrappers.find((item) => item.text().includes('Disable'));

  describe('loading state', () => {
    it('shows table in busy state while queries are loading', () => {
      const loadingResolver = jest.fn(() => new Promise(() => {}));
      createComponent({
        availableProfilesResolver: loadingResolver,
        projectProfilesResolver: loadingResolver,
      });

      expect(findTable().attributes('aria-busy')).toBe('true');
    });
  });

  describe('error handling', () => {
    it('displays error message when available profiles query fails', async () => {
      const errorResolver = jest.fn().mockRejectedValue(new Error('Query failed'));
      createComponent({ availableProfilesResolver: errorResolver });
      await waitForPromises();

      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toContain('Error loading profiles');
    });

    it('displays error message when project profiles query fails', async () => {
      const errorResolver = jest.fn().mockRejectedValue(new Error('Query failed'));
      createComponent({ projectProfilesResolver: errorResolver });
      await waitForPromises();

      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toContain('Error loading profiles');
    });
  });

  describe('table rendering', () => {
    it('renders table with correct fields', async () => {
      createComponent();
      await waitForPromises();

      const table = findGlTable();
      expect(table.exists()).toBe(true);
      expect(table.props('fields')).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ key: 'scanType', label: 'Scanner' }),
          expect.objectContaining({ key: 'name', label: 'Profile' }),
          expect.objectContaining({ key: 'status', label: 'Scanner health' }),
          expect.objectContaining({ key: 'actions', label: '' }),
        ]),
      );
    });

    it('renders "No profile applied" when profile is not configured', async () => {
      createComponent();
      await waitForPromises();

      expect(findAlert().exists()).toBe(false);
      expect(findTable().exists()).toBe(true);
      expect(wrapper.text()).toContain('No profile applied');
    });

    it('renders profile name as link when profile is configured', async () => {
      createComponent({
        projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
      });
      await waitForPromises();

      const links = wrapper.findAllComponents(GlLink);
      const profileLinks = links.filter((link) => link.text() === mockProfile.name);
      expect(profileLinks.length).toBeGreaterThan(0);
    });

    it('shows not configured status when profile is not attached', async () => {
      createComponent();
      await waitForPromises();

      expect(wrapper.text()).toContain('Unconfigured');
      expect(wrapper.text()).toContain('Apply profile to enable');
    });

    it('shows active status when profile is attached', async () => {
      createComponent({
        projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
      });
      await waitForPromises();

      expect(wrapper.text()).toContain('Active');
    });

    it('renders Dependency Scanning profile when returned from API', async () => {
      createComponent({
        availableProfilesResolver: createAvailableProfilesResolver([mockDsProfile]),
      });
      await waitForPromises();

      expect(wrapper.text()).toContain('DS');
      expect(wrapper.text()).toContain('Dependency Scanning');
    });
  });

  describe('when unlicensed', () => {
    beforeEach(() => {
      createComponent({ securityScanProfilesLicensed: false });
    });

    it('renders table with correct fields', () => {
      const table = findGlTable();
      expect(table.exists()).toBe(true);
      expect(table.props('fields')).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ key: 'scanType', label: 'Scanner' }),
          expect.objectContaining({ key: 'name', label: 'Profile' }),
          expect.objectContaining({ key: 'status', label: 'Scanner health' }),
          expect.objectContaining({ key: 'actions', label: '' }),
        ]),
      );
    });

    it('renders "No profile applied"', () => {
      expect(findAlert().exists()).toBe(false);
      expect(findTable().exists()).toBe(true);
      expect(wrapper.text()).toContain('No profile applied');
    });

    it('shows "Available with Ultimate" with a learn more link', () => {
      expect(wrapper.text()).toContain('Available with Ultimate');
      expect(findLink().text()).toBe('Learn more about the Ultimate security suite');
      expect(findLink().props('href')).toBe(`${PROMO_URL}/solutions/application-security-testing/`);
    });

    it('renders disabled apply and preview buttons', () => {
      const buttons = wrapper.findAllComponents(GlButton);
      const applyButton = buttons.wrappers.find((btn) =>
        btn.text().includes('Apply default profile'),
      );
      const previewButton = buttons.wrappers.find((btn) => btn.props('icon') === 'eye');

      expect(applyButton.props('disabled')).toBe(true);
      expect(previewButton.props('disabled')).toBe(true);
    });
  });

  describe('with securityScanProfilesStatusIndicators feature flag', () => {
    const createComponentWithFlag = (overrides = {}) =>
      createComponent({
        glFeatures: { securityScanProfilesStatusIndicators: true },
        ...overrides,
      });

    describe('status cell (scanner health)', () => {
      it('shows humanized status text', async () => {
        createComponentWithFlag({
          statuses: [mockStatusWithStatus('ACTIVE')],
        });
        await waitForPromises();
        expect(wrapper.text()).toContain('Active');
      });

      it('shows consecutive success count detail for active status', async () => {
        createComponentWithFlag({
          statuses: [mockStatusWithStatus('ACTIVE')],
        });
        await waitForPromises();
        expect(wrapper.text()).toContain(
          `Last ${mockStatusWithStatus('ACTIVE').consecutiveSuccessCount} scans successful`,
        );
      });

      it('shows correct status icon and class for active status', async () => {
        createComponentWithFlag({
          statuses: [mockStatusWithStatus('ACTIVE')],
        });
        await waitForPromises();
        const icon = wrapper.findByTestId('status-icon');
        expect(icon.props('name')).toBe('status-success');
        expect(icon.classes()).toContain('gl-text-success');
      });

      it('shows consecutive failure count detail for failed status', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('FAILED')] });
        await waitForPromises();
        expect(wrapper.text()).toContain('scans failed');
      });
    });

    describe('lastScan cell', () => {
      it('renders formatted last scan time when lastScanAt is present', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('ACTIVE')] });
        await waitForPromises();
        const lastScanCell = wrapper.findByTestId('last-scan');
        expect(lastScanCell.text()).not.toBe('-');
      });

      it('renders "—" when lastScanAt is null', async () => {
        createComponentWithFlag({
          statuses: [{ ...mockStatusWithStatus('UNCONFIGURED'), lastScanAt: null }],
        });
        await waitForPromises();
        expect(wrapper.text()).toContain('—');
      });

      it('shows "View failed job #" link text for failed status', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('FAILED')] });
        await waitForPromises();
        expect(wrapper.text()).toContain('View failed job #');
      });

      it('shows "View job #" link text for non-failed status', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('ACTIVE')] });
        await waitForPromises();
        expect(wrapper.text()).toContain('View job #');
      });

      it('renders job details popover when lastScanAt is present', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('ACTIVE')] });
        await waitForPromises();
        expect(findGlPopover().exists()).toBe(true);
        expect(findJobDetailsPopover().exists()).toBe(true);
      });

      it('shows popover when hovering the last scan link', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('ACTIVE')] });
        await waitForPromises();

        const link = wrapper.find(`[id^="scanner-details-"]`);
        await link.trigger('mouseenter');

        expect(wrapper.vm.activePopover).toBe(mockProfile.id);
      });

      it('hides popover when mouse leaves the last scan link', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('ACTIVE')] });
        await waitForPromises();

        const link = wrapper.find(`[id^="scanner-details-"]`);
        await link.trigger('mouseenter');
        expect(wrapper.vm.activePopover).toBe(mockProfile.id);

        let timeoutCallback;
        jest.spyOn(global, 'setTimeout').mockImplementation((cb) => {
          timeoutCallback = cb;
        });

        await link.trigger('mouseleave');
        timeoutCallback();
        await nextTick();

        expect(wrapper.vm.activePopover).toBeNull();
        jest.restoreAllMocks();
      });
    });

    describe('drawer', () => {
      it('does not render drawer initially', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('FAILED')] });
        await waitForPromises();

        expect(findTroubleshootDrawer().exists()).toBe(false);
      });

      it('opens drawer when open-drawer event is emitted from job details popover', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('FAILED')] });
        await waitForPromises();

        const lastScanCell = wrapper.findByTestId('last-scan');
        const link = lastScanCell.find(`[id^="scanner-details-"]`);
        await link.trigger('mouseenter');

        const jobPopover = findJobDetailsPopover();
        const mockJobData = { name: 'test-job', status: 'failed' };
        jobPopover.vm.$emit('open-drawer', mockJobData);
        await nextTick();

        expect(findTroubleshootDrawer().exists()).toBe(true);
        expect(wrapper.vm.isDrawerOpen).toBe(true);
        expect(wrapper.vm.activePopover).toBeNull();
      });

      it('closes drawer when close-drawer event is emitted', async () => {
        createComponentWithFlag({ statuses: [mockStatusWithStatus('FAILED')] });
        await waitForPromises();

        wrapper.vm.isDrawerOpen = true;
        wrapper.vm.drawerData = { name: 'test-job' };
        await nextTick();

        findTroubleshootDrawer().vm.$emit('close-drawer');
        await nextTick();

        expect(wrapper.vm.isDrawerOpen).toBe(false);
      });
    });
  });

  describe('apply profile', () => {
    it('calls attach mutation when apply button is clicked', async () => {
      const attachResolver = createAttachMutationResolver();
      createComponent({ attachResolver });
      await waitForPromises();

      const buttons = wrapper.findAllComponents(GlButton);
      const applyButton = buttons.wrappers.find((btn) =>
        btn.text().includes('Apply default profile'),
      );

      expect(applyButton).toBeDefined();
      await applyButton.trigger('click');
      await waitForPromises();

      expect(attachResolver).toHaveBeenCalledWith({
        input: {
          securityScanProfileId: mockProfile.id,
          projectIds: [mockProjectId],
        },
      });
    });

    it('applies profile by calling the mutation', async () => {
      const attachResolver = createAttachMutationResolver();
      createComponent({ attachResolver });
      await waitForPromises();

      const buttons = wrapper.findAllComponents(GlButton);
      const applyButton = buttons.wrappers.find((btn) =>
        btn.text().includes('Apply default profile'),
      );

      expect(applyButton).toBeDefined();
      expect(applyButton.props('loading')).toBe(false);
      await applyButton.trigger('click');
      await waitForPromises();

      expect(attachResolver).toHaveBeenCalled();
    });

    it('handles mutation errors', async () => {
      const attachResolver = createAttachMutationResolver(['Error message']);
      createComponent({ attachResolver });
      await waitForPromises();

      const buttons = wrapper.findAllComponents(GlButton);
      const applyButton = buttons.wrappers.find((btn) =>
        btn.text().includes('Apply default profile'),
      );

      await applyButton.trigger('click');
      await waitForPromises();

      expect(attachResolver).toHaveBeenCalled();
    });

    it('shows error message when attach mutation throws error', async () => {
      const attachResolver = jest.fn().mockRejectedValue(new Error('Network error'));
      createComponent({ attachResolver });
      await waitForPromises();

      const buttons = wrapper.findAllComponents(GlButton);
      const applyButton = buttons.wrappers.find((btn) =>
        btn.text().includes('Apply default profile'),
      );

      expect(applyButton).toBeDefined();
      await applyButton.trigger('click');
      await waitForPromises();

      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toContain('Error applying profile');
    });
  });

  describe('detach profile', () => {
    describe('without securityScanProfilesStatusIndicators feature flag', () => {
      const findDisableButton = () => {
        const buttons = wrapper.findAllComponents(GlButton);
        return buttons.wrappers.find((btn) => btn.text().includes('Disable'));
      };

      it('renders a plain Disable button (not inside a dropdown)', async () => {
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
        });
        await waitForPromises();

        expect(findDisableButton()).toBeDefined();
        expect(findDropdownItems()).toHaveLength(0);
      });

      it('opens disable modal when plain Disable button is clicked', async () => {
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
        });
        await waitForPromises();

        await findDisableButton().trigger('click');
        await nextTick();

        expect(findDisableModal().props('visible')).toBe(true);
        expect(findDisableModal().props('scannerName')).toBe('Secret Detection');
      });

      it('calls detach mutation when confirmed in modal', async () => {
        const detachResolver = createDetachMutationResolver();
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
          detachResolver,
        });
        await waitForPromises();

        await findDisableButton().trigger('click');
        await waitForPromises();

        findDisableModal().vm.$emit('confirm');
        await waitForPromises();

        expect(detachResolver).toHaveBeenCalledWith({
          input: {
            securityScanProfileId: mockProfile.id,
            projectIds: [mockProjectId],
          },
        });
      });

      it('closes modal when cancel is clicked', async () => {
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
        });
        await waitForPromises();

        await findDisableButton().trigger('click');
        await waitForPromises();

        findDisableModal().vm.$emit('cancel');
        await nextTick();

        expect(findDisableModal().props('visible')).toBe(false);
      });
    });

    describe('with securityScanProfilesStatusIndicators feature flag', () => {
      it('renders Disable inside a 3-dot dropdown (not as a plain button)', async () => {
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
          glFeatures: { securityScanProfilesStatusIndicators: true },
          statuses: [mockStatusWithStatus('ACTIVE')],
        });
        await waitForPromises();

        expect(findDisableDropdownItem()).toBeDefined();

        const buttons = wrapper.findAllComponents(GlButton);
        const disableButton = buttons.wrappers.find((btn) => btn.text().includes('Disable'));
        expect(disableButton).toBeUndefined();
      });

      it('opens disable modal when disable button is clicked', async () => {
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
          glFeatures: { securityScanProfilesStatusIndicators: true },
          statuses: [mockStatusWithStatus('ACTIVE')],
        });
        await waitForPromises();

        const disableItem = findDisableDropdownItem();
        expect(disableItem).toBeDefined();
        disableItem.vm.$emit('action');
        await nextTick();

        expect(findDisableModal().props('visible')).toBe(true);
        expect(findDisableModal().props('scannerName')).toBe('Secret Detection');
      });

      it('calls detach mutation when confirmed in modal', async () => {
        const detachResolver = createDetachMutationResolver();
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
          glFeatures: { securityScanProfilesStatusIndicators: true },
          statuses: [mockStatusWithStatus('ACTIVE')],
          detachResolver,
        });
        await waitForPromises();

        const disableItem = findDisableDropdownItem();
        expect(disableItem).toBeDefined();
        disableItem.vm.$emit('action');
        await waitForPromises();

        findDisableModal().vm.$emit('confirm');
        await waitForPromises();

        expect(detachResolver).toHaveBeenCalledWith({
          input: {
            securityScanProfileId: mockProfile.id,
            projectIds: [mockProjectId],
          },
        });
      });

      it('detaches profile by calling the mutation', async () => {
        const detachResolver = createDetachMutationResolver();
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
          statuses: [mockStatusWithStatus('ACTIVE')],
          detachResolver,
          glFeatures: { securityScanProfilesStatusIndicators: true },
        });
        await waitForPromises();

        const disableItem = findDisableDropdownItem();
        expect(disableItem).toBeDefined();
        expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(false);
        disableItem.vm.$emit('action');
        await waitForPromises();

        findDisableModal().vm.$emit('confirm');
        await waitForPromises();

        expect(detachResolver).toHaveBeenCalled();
      });

      it('closes modal when cancel is clicked', async () => {
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
          glFeatures: { securityScanProfilesStatusIndicators: true },
          statuses: [mockStatusWithStatus('ACTIVE')],
        });
        await waitForPromises();

        const disableItem = findDisableDropdownItem();
        expect(disableItem).toBeDefined();
        expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(false);
        disableItem.vm.$emit('action');
        await waitForPromises();

        findDisableModal().vm.$emit('cancel');
        await nextTick();

        expect(findDisableModal().props('visible')).toBe(false);
      });

      it.each([
        ['failed', mockStatusWithStatus('FAILED')],
        ['warning', mockStatusWithStatus('WARNING')],
      ])('shows troubleshoot failure item when status is %s', async (_, status) => {
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
          glFeatures: { securityScanProfilesStatusIndicators: true },
          statuses: [status],
        });
        await waitForPromises();

        const troubleshootItem = findDropdownItems().wrappers.find((item) =>
          item.text().includes('Troubleshoot'),
        );
        expect(troubleshootItem).toBeDefined();
      });

      it.each([
        ['active', mockStatusWithStatus('ACTIVE')],
        ['stale', mockStatusWithStatus('STALE')],
        ['unconfigured', mockStatusWithStatus('UNCONFIGURED')],
      ])('does not show troubleshoot failure item when status is %s', async (_, status) => {
        createComponent({
          projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
          glFeatures: { securityScanProfilesStatusIndicators: true },
          statuses: [status],
        });
        await waitForPromises();

        const troubleshootItem = findDropdownItems().wrappers.find((item) =>
          item.text().includes('Troubleshoot'),
        );
        expect(troubleshootItem).toBeUndefined();
      });
    });

    it.each([
      ['failed', mockStatusWithStatus('FAILED')],
      ['warning', mockStatusWithStatus('WARNING')],
    ])('shows troubleshoot failure item when status is %s', async (_, status) => {
      createComponent({
        projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
        glFeatures: { securityScanProfilesStatusIndicators: true },
        statuses: [status],
      });
      await waitForPromises();

      const troubleshootItem = findDropdownItems().wrappers.find((item) =>
        item.text().includes('Troubleshoot'),
      );
      expect(troubleshootItem).toBeDefined();
    });

    it.each([
      ['active', mockStatusWithStatus('ACTIVE')],
      ['stale', mockStatusWithStatus('STALE')],
      ['unconfigured', mockStatusWithStatus('UNCONFIGURED')],
    ])('does not show troubleshoot failure item when status is %s', async (_, status) => {
      createComponent({
        projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
        glFeatures: { securityScanProfilesStatusIndicators: true },
        statuses: [status],
      });
      await waitForPromises();

      const troubleshootItem = findDropdownItems().wrappers.find((item) =>
        item.text().includes('Troubleshoot'),
      );
      expect(troubleshootItem).toBeUndefined();
    });
  });

  describe('preview profile', () => {
    it('opens details modal when preview button is clicked', async () => {
      createComponent();
      await waitForPromises();

      const buttons = wrapper.findAllComponents(GlButton);
      const previewButton = buttons.wrappers.find((btn) => btn.props('icon') === 'eye');

      expect(previewButton).toBeDefined();
      await previewButton.trigger('click');

      expect(findDetailsModal().props('visible')).toBe(true);
      expect(findDetailsModal().props('profileId')).toBe(mockProfile.id);
    });

    it('opens details modal when profile name link is clicked', async () => {
      createComponent({
        projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
      });
      await waitForPromises();

      const links = wrapper.findAllComponents(GlLink);
      const profileLinks = links.filter((link) => link.text() === mockProfile.name);
      expect(profileLinks.length).toBeGreaterThan(0);
      await profileLinks.at(0).trigger('click');

      expect(findDetailsModal().props('visible')).toBe(true);
      expect(findDetailsModal().props('profileId')).toBe(mockProfile.id);
    });

    it('closes details modal when close event is emitted', async () => {
      createComponent({
        projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
      });
      await waitForPromises();

      const links = wrapper.findAllComponents(GlLink);
      const profileLinks = links.filter((link) => link.text() === mockProfile.name);
      expect(profileLinks.length).toBeGreaterThan(0);
      await profileLinks.at(0).trigger('click');

      findDetailsModal().vm.$emit('close');
      await nextTick();

      expect(findDetailsModal().props('visible')).toBe(false);
    });

    it('applies profile from details modal', async () => {
      const attachResolver = createAttachMutationResolver();
      createComponent({
        attachResolver,
        projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
      });
      await waitForPromises();

      const links = wrapper.findAllComponents(GlLink);
      const profileLinks = links.filter((link) => link.text() === mockProfile.name);
      expect(profileLinks.length).toBeGreaterThan(0);
      await profileLinks.at(0).trigger('click');
      await waitForPromises();

      findDetailsModal().vm.$emit('apply', mockProfile.id);
      await waitForPromises();

      expect(attachResolver).toHaveBeenCalled();
    });
  });

  describe('permissions', () => {
    it('shows lock icon and popover on apply button when user cannot apply profiles', async () => {
      createComponent({ canApplyProfiles: false });
      await waitForPromises();

      const buttons = wrapper.findAllComponents(GlButton);
      const applyButton = buttons.wrappers.find((btn) =>
        btn.text().includes('Apply default profile'),
      );

      expect(applyButton.text()).toContain('Apply default profile');
      expect(applyButton.html()).toContain('lock');
      expect(findPopover().exists()).toBe(true);
      expect(findPopover().props('target')).toContain('apply-button');
    });

    it('shows lock icon and popover on disable button when user cannot apply profiles', async () => {
      createComponent({
        canApplyProfiles: false,
        projectProfilesResolver: createProjectProfilesResolver([mockProfile]),
        glFeatures: { securityScanProfilesStatusIndicators: true },
        statuses: [mockStatusWithStatus('ACTIVE')],
      });
      await waitForPromises();

      const disableItem = findDropdownItems().wrappers.find((item) =>
        item.text().includes('Disable'),
      );
      expect(disableItem).toBeDefined();
      expect(disableItem.html()).toContain('lock');

      const popovers = wrapper.findAllComponents(InsufficientPermissionsPopover);
      expect(popovers.length).toBeGreaterThan(0);
      const disablePopover = popovers.wrappers.find((p) =>
        p.props('target').includes('disable-button'),
      );
      expect(disablePopover).toBeDefined();
    });

    it('allows preview button to be clicked when user cannot apply profiles', async () => {
      createComponent({ canApplyProfiles: false });
      await waitForPromises();

      const buttons = wrapper.findAllComponents(GlButton);
      const previewButton = buttons.wrappers.find((btn) => btn.props('icon') === 'eye');

      expect(previewButton.props('disabled')).toBe(false);
    });
  });

  describe('apollo queries', () => {
    it('calls available profiles query with correct variables', () => {
      const resolver = createAvailableProfilesResolver();
      createComponent({ availableProfilesResolver: resolver });

      expect(resolver).toHaveBeenCalledWith({
        fullPath: 'group',
        gitlabRecommended: true,
      });
    });

    it('calls project profiles query with correct variables', () => {
      const resolver = createProjectProfilesResolver();
      createComponent({ projectProfilesResolver: resolver });

      expect(resolver).toHaveBeenCalledWith({
        fullPath: 'group/project',
      });
    });
  });
});
