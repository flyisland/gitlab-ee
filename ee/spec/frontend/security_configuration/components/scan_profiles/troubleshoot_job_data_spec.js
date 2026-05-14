import { GlIcon, GlLink } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import TroubleshootJobData from 'ee/security_configuration/components/scan_profiles/troubleshoot_job_data.vue';
import { joinPaths } from '~/lib/utils/url_utility';
import { humanizeTimeInterval } from '~/lib/utils/datetime/date_format_utility';
import { SCAN_PROFILE_SOURCE_LABELS } from '~/security_configuration/constants';

const mockData = {
  name: 'SAST',
  status: 'success',
  duration: 120,
  source: 'push',
  finishedAt: '2024-01-01T00:00:00Z',
  webPath: '/root/project/-/jobs/123',
  fullPath: 'root/project',
  pipeline: {
    id: 'gid://gitlab/Ci::Pipeline/456',
    path: '/gitlab-org/gitlab/-/pipelines/456',
  },
};

const mockGitlabUrl = 'https://gitlab.com';

describe('TroubleshootJobData', () => {
  let wrapper;

  beforeEach(() => {
    gon.gitlab_url = mockGitlabUrl;
  });

  const createWrapper = (props = {}) => {
    wrapper = shallowMountExtended(TroubleshootJobData, {
      propsData: {
        data: mockData,
        ...props,
      },
    });
  };

  const findAllLinks = () => wrapper.findAllComponents(GlLink);
  const findPipelineLink = () => findAllLinks().at(0);
  const findJobLink = () => findAllLinks().at(1);
  const findStatusIcon = () => wrapper.findComponent(GlIcon);

  describe('rendering', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders the job name', () => {
      expect(wrapper.text()).toContain(mockData.name);
    });

    it('renders the job status', () => {
      expect(wrapper.text()).toContain(mockData.status);
    });

    it('renders the job source', () => {
      expect(wrapper.text()).toContain(SCAN_PROFILE_SOURCE_LABELS[mockData.source]);
    });

    it('renders the formatted duration', () => {
      expect(wrapper.text()).toContain(humanizeTimeInterval(mockData.duration));
    });

    it('renders the status icon', () => {
      expect(findStatusIcon().exists()).toBe(true);
    });

    it('does not render finished time when not in drawer mode', () => {
      expect(wrapper.findByText('Finished:').exists()).toBe(false);
    });

    it('does not render job link when not in drawer mode', () => {
      expect(findAllLinks()).toHaveLength(1);
    });
  });

  describe('pipeline link', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders the pipeline link with correct href', () => {
      const expectedPath = joinPaths(mockGitlabUrl, mockData.pipeline.path);
      expect(findPipelineLink().attributes('href')).toBe(expectedPath);
    });

    it('renders the pipeline id as link text', () => {
      expect(findPipelineLink().text()).toContain(`#${getIdFromGraphQLId(mockData.pipeline.id)}`);
    });
  });

  describe('when isDrawer is true', () => {
    beforeEach(() => {
      createWrapper({ isDrawer: true });
    });

    it('renders the finished time', () => {
      expect(wrapper.text()).toContain('Finished');
    });

    it('renders the job link', () => {
      expect(findJobLink().exists()).toBe(true);
    });

    it('renders the job link with correct href', () => {
      const expectedPath = joinPaths(mockGitlabUrl, mockData.webPath);
      expect(findJobLink().attributes('href')).toBe(expectedPath);
    });

    it('renders the job id as link text', () => {
      const jobId = mockData.webPath.split('/').pop();
      expect(findJobLink().text()).toContain(`#${jobId}`);
    });
  });
});
