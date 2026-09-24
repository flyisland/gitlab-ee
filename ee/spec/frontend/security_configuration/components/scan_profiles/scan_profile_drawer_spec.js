import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlDrawer, GlSkeletonLoader } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { stubComponent } from 'helpers/stub_component';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import ScanProfileDrawer from 'ee/security_configuration/components/scan_profiles/scan_profile_drawer.vue';
import ScanProfileList from 'ee/security_configuration/components/scan_profiles/scan_profile_list.vue';
import ScanProfileDetail from 'ee/security_configuration/components/scan_profiles/scan_profile_detail.vue';
import groupAvailableSecurityScanProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/group_available_security_scan_profiles.query.graphql';
import {
  SCAN_PROFILE_TYPE_SAST,
  SCAN_PROFILE_TYPE_SECRET_DETECTION,
} from '~/security_configuration/constants';

Vue.use(VueApollo);

jest.mock('~/alert');

const GROUP_FULL_PATH = 'my-group';

describe('ScanProfileDrawer', () => {
  let wrapper;

  const buildProfile = (overrides = {}) => ({
    id: 'gid://gitlab/Security::ScanProfile/1',
    name: 'Secret Detection (default)',
    description: 'The recommended profile',
    scanType: SCAN_PROFILE_TYPE_SECRET_DETECTION,
    gitlabRecommended: true,
    triggers: ['MERGE_REQUEST_PIPELINE'],
    __typename: 'ScanProfileType',
    ...overrides,
  });

  const recommendedProfile = buildProfile();
  const customProfile = buildProfile({
    id: 'gid://gitlab/Security::ScanProfile/2',
    name: 'A custom profile',
    description: 'One the group made',
    gitlabRecommended: false,
  });
  const sastProfile = buildProfile({
    id: 'gid://gitlab/Security::ScanProfile/3',
    name: 'SAST (default)',
    scanType: SCAN_PROFILE_TYPE_SAST,
  });

  const createResolver = (profiles = [recommendedProfile, customProfile, sastProfile]) =>
    jest.fn().mockResolvedValue({
      data: {
        group: {
          id: 'gid://gitlab/Group/1',
          name: GROUP_FULL_PATH,
          availableSecurityScanProfiles: profiles,
          __typename: 'Group',
        },
      },
    });

  const createComponent = ({ props = {}, resolver = createResolver() } = {}) => {
    wrapper = shallowMountExtended(ScanProfileDrawer, {
      apolloProvider: createMockApollo([[groupAvailableSecurityScanProfilesQuery, resolver]]),
      propsData: {
        open: true,
        scanType: SCAN_PROFILE_TYPE_SECRET_DETECTION,
        ...props,
      },
      provide: {
        groupFullPath: GROUP_FULL_PATH,
      },
      stubs: {
        GlDrawer: stubComponent(GlDrawer, {
          template: '<div><slot name="title" /><slot /></div>',
        }),
      },
    });
  };

  const findDrawer = () => wrapper.findComponent(GlDrawer);
  const findList = () => wrapper.findComponent(ScanProfileList);
  const findDetail = () => wrapper.findComponent(ScanProfileDetail);
  const findLoader = () => wrapper.findComponent(GlSkeletonLoader);
  const findEmptyState = () => wrapper.findByTestId('scan-profile-drawer-empty');

  describe('drawer', () => {
    it('is closed by default', () => {
      createComponent({ props: { open: false } });

      expect(findDrawer().props('open')).toBe(false);
    });

    it('is open when the open prop is set', () => {
      createComponent();

      expect(findDrawer().props('open')).toBe(true);
    });

    it('emits close when the drawer is dismissed', () => {
      createComponent();

      findDrawer().vm.$emit('close');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });

  describe('title', () => {
    it('names the scanner for a known scan type, in sentence case', () => {
      createComponent();

      expect(wrapper.text()).toContain('Manage secret detection profiles');
    });

    it('keeps the capitals in an acronym scanner name', () => {
      createComponent({ props: { scanType: SCAN_PROFILE_TYPE_SAST } });

      expect(wrapper.text()).toContain(
        'Manage static application security testing (SAST) profiles',
      );
    });

    it('falls back to a generic title for an unknown scan type', () => {
      createComponent({ props: { scanType: 'NOT_A_SCANNER' } });

      expect(wrapper.text()).toContain('Manage profiles');
    });
  });

  describe('fetching', () => {
    it('does not query while the drawer is closed', async () => {
      const resolver = createResolver();
      createComponent({ props: { open: false }, resolver });
      await waitForPromises();

      expect(resolver).not.toHaveBeenCalled();
    });

    it('queries the group when the drawer is open', async () => {
      const resolver = createResolver();
      createComponent({ resolver });
      await waitForPromises();

      expect(resolver).toHaveBeenCalledWith({ fullPath: GROUP_FULL_PATH });
    });

    it('renders a skeleton while loading', () => {
      createComponent();

      expect(findLoader().exists()).toBe(true);
      expect(findList().exists()).toBe(false);
    });
  });

  describe('the list', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it("passes only profiles of the drawer's scan type", () => {
      expect(findList().props('profiles')).toEqual([recommendedProfile, customProfile]);
    });

    it('selects the first profile by default', () => {
      expect(findList().props('selectedId')).toBe(recommendedProfile.id);
      expect(findDetail().props('profile')).toEqual(recommendedProfile);
    });

    it('swaps the detail pane when another profile is selected', async () => {
      findList().vm.$emit('select', customProfile.id);
      await waitForPromises();

      expect(findDetail().props('profile')).toEqual(customProfile);
    });
  });

  describe('default selection', () => {
    it('takes the first profile the resolver returns', async () => {
      createComponent({ resolver: createResolver([customProfile, recommendedProfile]) });
      await waitForPromises();

      expect(findList().props('selectedId')).toBe(customProfile.id);
    });
  });

  describe('when the scan type changes', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();

      await wrapper.setProps({ scanType: SCAN_PROFILE_TYPE_SAST });
      await waitForPromises();
    });

    it('lists the profiles of the new scan type', () => {
      expect(findList().props('profiles')).toEqual([sastProfile]);
    });

    it('selects the first profile of the new scan type', () => {
      expect(findList().props('selectedId')).toBe(sastProfile.id);
      expect(findDetail().props('profile')).toEqual(sastProfile);
    });
  });

  describe('when the drawer is reopened', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();

      findList().vm.$emit('select', customProfile.id);
      await waitForPromises();

      await wrapper.setProps({ open: false });
      await wrapper.setProps({ open: true });
      await waitForPromises();
    });

    it('goes back to the default selection', () => {
      expect(findList().props('selectedId')).toBe(recommendedProfile.id);
    });
  });

  describe('empty state', () => {
    it('is shown when no profile matches the scan type', async () => {
      createComponent({ resolver: createResolver([sastProfile]) });
      await waitForPromises();

      expect(findEmptyState().exists()).toBe(true);
      expect(findList().exists()).toBe(false);
    });
  });

  describe('when the query fails', () => {
    beforeEach(async () => {
      jest.spyOn(Sentry, 'captureException');
      createComponent({ resolver: jest.fn().mockRejectedValue(new Error()) });
      await waitForPromises();
    });

    it('reports the error to Sentry', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(expect.any(Error));
    });

    it('alerts inside the drawer rather than behind it', () => {
      expect(createAlert).toHaveBeenCalledWith({
        message: 'Failed to load scan profiles.',
        containerSelector: '.js-scan-profile-drawer-flash-container',
      });
    });

    it('renders neither the list nor the empty state behind the alert', () => {
      expect(findList().exists()).toBe(false);
      expect(findEmptyState().exists()).toBe(false);
    });
  });
});
