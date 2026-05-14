import { GlButton, GlDrawer } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { joinPaths } from '~/lib/utils/url_utility';
import { SCAN_PROFILE_CATEGORIES } from '~/security_configuration/constants';
import TroubleshootJobDrawer from 'ee/security_configuration/components/scan_profiles/troubleshoot_job_drawer.vue';
import TroubleshootJobData from 'ee/security_configuration/components/scan_profiles/troubleshoot_job_data.vue';

const mockGitlabUrl = 'https://gitlab.com';

const mockDrawerData = {
  scanType: 'SAST',
  webPath: '/root/project/-/jobs/123',
  buildId: 'gid://gitlab/Ci::Build/123',
  failureMessage: 'Job failed due to an error',
  trace: {
    htmlSummary: '<p>Root cause details</p>',
  },
  pipeline: {
    id: 'gid://gitlab/Ci::Pipeline/456',
  },
  name: 'SAST',
  status: 'failed',
  duration: 120,
  source: 'push',
  finishedAt: '2024-01-01T00:00:00Z',
  fullPath: 'root/project',
};

describe('TroubleshootJobDrawer', () => {
  let wrapper;

  beforeEach(() => {
    gon.gitlab_url = mockGitlabUrl;
  });

  const createWrapper = (props = {}) => {
    wrapper = shallowMountExtended(TroubleshootJobDrawer, {
      propsData: {
        openDrawer: true,
        drawerData: mockDrawerData,
        ...props,
      },
    });
  };

  const findDrawer = () => wrapper.findComponent(GlDrawer);
  const findJobData = () => wrapper.findComponent(TroubleshootJobData);
  const findButton = () => wrapper.findComponent(GlButton);
  const findTraceSummary = () => wrapper.findByTestId('job-trace-summary');
  const findFailureMessage = () => wrapper.findByTestId('failure-message');

  describe('rendering', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders the drawer', () => {
      expect(findDrawer().exists()).toBe(true);
    });

    it('passes openDrawer prop to GlDrawer', () => {
      expect(findDrawer().props('open')).toBe(true);
    });

    it('renders TroubleshootJobData with correct props', () => {
      expect(findJobData().props('data')).toEqual(mockDrawerData);
      expect(findJobData().props('isDrawer')).toBe(true);
    });

    it('renders the correct drawer title', () => {
      const scannerName = SCAN_PROFILE_CATEGORIES[mockDrawerData.scanType]?.displayName || '';
      expect(wrapper.vm.drawerTitle).toContain(`${scannerName} ${'failure'}`);
    });

    it('renders Job details heading', () => {
      expect(wrapper.text()).toContain('Job details');
    });
  });

  describe('failure message', () => {
    it('renders failure message when present', () => {
      createWrapper();
      expect(findFailureMessage().exists()).toBe(true);
    });

    it('does not render failure message when absent', () => {
      createWrapper({
        drawerData: { ...mockDrawerData, failureMessage: null },
      });
      expect(wrapper.findByText(mockDrawerData.failureMessage).exists()).toBe(false);
    });
  });

  describe('trace summary', () => {
    it('renders trace summary when htmlSummary is present', () => {
      createWrapper();
      expect(findTraceSummary().exists()).toBe(true);
    });

    it('does not render trace summary when htmlSummary is absent', () => {
      createWrapper({
        drawerData: { ...mockDrawerData, trace: { htmlSummary: null } },
      });
      expect(findTraceSummary().exists()).toBe(false);
    });
  });

  describe('view job button', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders the view job button', () => {
      expect(findButton().exists()).toBe(true);
    });

    it('renders the button with correct href', () => {
      const expectedPath = joinPaths(mockGitlabUrl, mockDrawerData.webPath);
      expect(findButton().attributes('href')).toBe(expectedPath);
    });

    it('renders the button with correct title', () => {
      const jobId = getIdFromGraphQLId(mockDrawerData.buildId);
      expect(findButton().text()).toContain(`${'View job #'}${jobId}`);
    });
  });

  describe('when openDrawer is false', () => {
    it('passes open=false to GlDrawer', () => {
      createWrapper({ openDrawer: false });
      expect(findDrawer().props('open')).toBe(false);
    });
  });

  describe('events', () => {
    it('emits close-drawer when drawer is closed', async () => {
      createWrapper();
      await findDrawer().vm.$emit('close');
      expect(wrapper.emitted('close-drawer')).toHaveLength(1);
    });
  });
});
