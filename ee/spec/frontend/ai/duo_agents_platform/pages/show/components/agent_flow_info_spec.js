import { GlBadge, GlLink, GlSkeletonLoader } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentFlowInfo from 'ee/ai/duo_agents_platform/pages/show/components/agent_flow_info.vue';
import AgentFlowTriggeredUser from 'ee/ai/duo_agents_platform/components/common/agent_flow_triggered_user.vue';
import { localeDateFormat } from '~/lib/utils/datetime/locale_dateformat';
import { mockUser1, mockWorkItem, mockMergeRequest } from '../../../../mocks';

jest.mock('~/lib/utils/datetime/locale_dateformat');

describe('AgentFlowInfo', () => {
  let wrapper;

  const mockDateTimeFormatter = {
    format: jest.fn(),
  };

  beforeEach(() => {
    localeDateFormat.asDateTime = mockDateTimeFormatter;
    mockDateTimeFormatter.format.mockImplementation((date) => {
      if (date.toISOString() === '2023-01-01T00:00:00.000Z') {
        return 'Jan 1, 2023, 12:00 AM';
      }
      if (date.toISOString() === '2024-01-01T00:00:00.000Z') {
        return 'Jan 1, 2024, 12:00 AM';
      }
      return date.toISOString();
    });
  });

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(AgentFlowInfo, {
      propsData: {
        isLoading: false,
        status: 'RUNNING',
        humanStatus: 'Running',
        agentFlowDefinition: 'software_development',
        allExecutorUrls: ['https://gitlab.com/gitlab-org/gitlab/-/jobs/123'],
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
        user: mockUser1,
        canUpdateWorkflow: true,
        workItem: mockWorkItem,
        mergeRequest: mockMergeRequest,
        project: {
          id: 'gid://gitlab/Project/1',
          name: 'Test Project',
          fullPath: 'gitlab-org/test-project',
          webUrl: 'https://gitlab.com/gitlab-org/test-project',
          namespace: {
            id: 'gid://gitlab/Group/1',
            name: 'gitlab-org',
            webUrl: 'https://gitlab.com/gitlab-org',
          },
        },
        ...props,
      },
      mocks: {
        $route: {
          params: {
            id: '4545',
          },
        },
      },
    });
  };

  const findHeading = () => wrapper.findByTestId('session-info-heading');
  const findInfoList = () => wrapper.find('ul');
  const findListItems = () => wrapper.findAll('li');
  const findRow = (label) => wrapper.findByTestId(`info-row-${label}`);
  const findListItemTitles = () => wrapper.findAllByTestId('info-title');
  const findListItemValues = () => wrapper.findAllByTestId('info-value');
  const findSkeletonLoaders = () => wrapper.findAllComponents(GlSkeletonLoader);
  const findCancelButton = () => wrapper.findByTestId('cancel-session-button');
  const findLinks = () => wrapper.findAllComponents(GlLink);
  const findBadge = () => wrapper.findComponent(GlBadge);
  const findTriggeredUser = () => wrapper.findComponent(AgentFlowTriggeredUser);

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({ isLoading: true });
    });

    it('renders the heading', () => {
      expect(findHeading().text()).toBe('Session information');
    });

    it('renders the info list', () => {
      expect(findInfoList().exists()).toBe(true);
    });

    it('renders all session info items as list items', () => {
      expect(findListItems()).toHaveLength(12);
    });

    it('displays the skeleton loaders', () => {
      expect(findSkeletonLoaders()).toHaveLength(12);
    });

    it('does not display placeholder N/A values', () => {
      expect(wrapper.text()).not.toContain('N/A');
    });
  });

  describe('info data', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders all expected info values in the correct order', () => {
      const listItems = findListItemValues();
      const expectedData = [
        'software_development', // AI Item
        '#4545', // Session ID
        'Flow', // Type
        'Test Project', // Project
        'gitlab-org', // Group
        `#42`, // Work item
        `!7`, // Merge request
        'Running', // Status
        'Jan 1, 2023, 12:00 AM', // Started
        'Jan 1, 2024, 12:00 AM', // Last updated
        '#123', // Job IDs
      ];

      expectedData.forEach((expectedText, index) => {
        expect(listItems.at(index).text()).toContain(expectedText);
      });
    });

    it('renders the status badge with the correct props', () => {
      const badge = findBadge();

      expect(badge.exists()).toBe(true);
      expect(badge.props()).toMatchObject({
        icon: 'play',
        iconSize: 'sm',
        variant: 'info',
      });
      expect(badge.text()).toBe('Running');
    });

    it('renders all the expected titles in the correct order', () => {
      const listItemTitles = findListItemTitles();
      const expectedTitles = [
        'AI Item',
        'Session ID',
        'Type',
        'Project',
        'Group',
        'Triggered by',
        'Work item',
        'Merge request',
        'Status',
        'Started',
        'Last updated',
        'Job IDs',
      ];

      expectedTitles.forEach((expectedTitle, index) => {
        expect(listItemTitles.at(index).text()).toContain(expectedTitle);
      });
    });

    it.each`
      label              | href                                                               | text
      ${'Session ID'}    | ${'/gitlab-org/test-project/-/automate/agent-sessions/4545'}       | ${'#4545'}
      ${'Project'}       | ${'https://gitlab.com/gitlab-org/test-project'}                    | ${'Test Project'}
      ${'Group'}         | ${'https://gitlab.com/gitlab-org'}                                 | ${'gitlab-org'}
      ${'Work item'}     | ${'https://gitlab.com/gitlab-org/test-project/-/work_items/42'}    | ${'#42'}
      ${'Merge request'} | ${'https://gitlab.com/gitlab-org/test-project/-/merge_requests/7'} | ${'!7'}
      ${'Job IDs'}       | ${'https://gitlab.com/gitlab-org/gitlab/-/jobs/123'}               | ${'#123'}
    `('renders link for $label', ({ label, href, text }) => {
      const link = findRow(label).findComponent(GlLink);
      expect(link.attributes('href')).toBe(href);
      expect(link.text()).toBe(text);
    });

    describe('when work item is linked', () => {
      beforeEach(() => {
        createComponent({ workItem: mockWorkItem });
      });

      it('renders the work item row with a link', () => {
        const workItemRow = findRow('Work item');
        expect(workItemRow.text()).toContain(`#${mockWorkItem.iid}`);
        expect(workItemRow.findComponent(GlLink).attributes('href')).toBe(mockWorkItem.webUrl);
      });
    });

    describe('when work item is not linked', () => {
      it('displays None for work item', () => {
        createComponent({ workItem: null });
        expect(findRow('Work item').text()).toContain('None');
      });
    });

    describe('when merge request is linked', () => {
      beforeEach(() => {
        createComponent({ mergeRequest: mockMergeRequest });
      });

      it('renders the merge request row with a link', () => {
        const mrRow = findRow('Merge request');
        expect(mrRow.text()).toContain(`!${mockMergeRequest.iid}`);
        expect(mrRow.findComponent(GlLink).attributes('href')).toBe(mockMergeRequest.webUrl);
      });
    });

    describe('when merge request is not linked', () => {
      it('displays None for merge request', () => {
        createComponent({ mergeRequest: null });
        expect(findRow('Merge request').text()).toContain('None');
      });
    });

    describe('when project information is missing', () => {
      beforeEach(() => {
        createComponent({ project: {} });
      });

      it('displays None for missing project information', () => {
        expect(findRow('Project').text()).toContain('None');
        expect(findRow('Group').text()).toContain('None');
      });

      it('does not display links for project, group, and sessionId', () => {
        expect(findRow('Session ID').findComponent(GlLink).exists()).toBe(false);
        expect(findRow('Project').findComponent(GlLink).exists()).toBe(false);
        expect(findRow('Group').findComponent(GlLink).exists()).toBe(false);
      });
    });

    describe('when project namespace is missing', () => {
      beforeEach(() => {
        createComponent({
          project: {
            id: 'gid://gitlab/Project/1',
            name: 'Test Project',
            fullPath: 'gitlab-org/test-project',
            webUrl: 'https://gitlab.com/gitlab-org/test-project',
          },
        });
      });

      it('displays None for missing namespace information', () => {
        expect(findRow('Project').text()).toContain('Test Project');
        expect(findRow('Group').text()).toContain('None');
      });

      it('displays project, sessionId, and executor links but not group link', () => {
        const links = findLinks();

        expect(links).toHaveLength(5);
        expect(links.at(0).attributes('href')).toBe(
          '/gitlab-org/test-project/-/automate/agent-sessions/4545',
        );
        expect(links.at(1).attributes('href')).toBe('https://gitlab.com/gitlab-org/test-project');
        expect(links.at(2).attributes('href')).toBe(
          'https://gitlab.com/gitlab-org/test-project/-/work_items/42',
        );
        expect(links.at(3).attributes('href')).toBe(
          'https://gitlab.com/gitlab-org/test-project/-/merge_requests/7',
        );
        expect(links.at(4).attributes('href')).toBe(
          'https://gitlab.com/gitlab-org/gitlab/-/jobs/123',
        );
      });
    });

    describe('when executor URL is invalid', () => {
      beforeEach(() => {
        createComponent({
          allExecutorUrls: ['https://gitlab.com/invalid-url'],
        });
      });

      it('does not display a link or job ID for an invalid URL', () => {
        expect(findRow('Job IDs').findComponent(GlLink).exists()).toBe(false);
        expect(findRow('Job IDs').text()).toContain('None');
      });
    });

    describe('when executor URL is empty', () => {
      beforeEach(() => {
        createComponent({
          allExecutorUrls: [],
        });
      });

      it('displays None for empty executor URL', () => {
        expect(findRow('Job IDs').text()).toContain('None');
      });
    });

    it('uses locale-aware date formatting', () => {
      expect(mockDateTimeFormatter.format).toHaveBeenCalledWith(new Date('2023-01-01T00:00:00Z'));
      expect(mockDateTimeFormatter.format).toHaveBeenCalledWith(new Date('2024-01-01T00:00:00Z'));
    });

    describe('when date values are invalid', () => {
      beforeEach(() => {
        mockDateTimeFormatter.format.mockClear();
        createComponent({ createdAt: null, updatedAt: 'invalid-date' });
      });

      it('does not display if invalid dates', () => {
        expect(findRow('Started').exists()).toBe(false);
        expect(findRow('Last updated').exists()).toBe(false);
      });

      it('does not call the date formatter for invalid dates', () => {
        expect(mockDateTimeFormatter.format).not.toHaveBeenCalled();
      });
    });

    it('renders AgentFlowTriggeredUser component', () => {
      createComponent();
      expect(findTriggeredUser().exists()).toBe(true);
    });
  });

  describe('Cancel session button', () => {
    describe('when session can be cancelled', () => {
      it.each`
        status                           | description
        ${'CREATED'}                     | ${'created status'}
        ${'RUNNING'}                     | ${'running status'}
        ${'PAUSED'}                      | ${'paused status'}
        ${'INPUT_REQUIRED'}              | ${'input_required status'}
        ${'PLAN_APPROVAL_REQUIRED'}      | ${'plan_approval_required status'}
        ${'TOOL_CALL_APPROVAL_REQUIRED'} | ${'tool_call_approval_required status'}
      `('shows cancel button for $description', ({ status }) => {
        createComponent({ status });

        expect(findCancelButton().exists()).toBe(true);
        expect(findCancelButton().text()).toBe('Cancel session');
        expect(findCancelButton().attributes('variant')).toBe('danger');
        expect(findCancelButton().props().disabled).toBe(false);
      });

      it('emits cancel-session event when clicked', async () => {
        createComponent({ status: 'RUNNING' });

        await findCancelButton().vm.$emit('click');

        expect(wrapper.emitted('cancel-session')).toHaveLength(1);
      });
    });

    describe('when session cannot be cancelled', () => {
      it.each`
        status        | description
        ${'FINISHED'} | ${'finished status'}
        ${'FAILED'}   | ${'failed status'}
      `('does not show cancel button for $description', ({ status }) => {
        createComponent({ status });

        expect(findCancelButton().exists()).toBe(false);
      });
    });

    describe('when user lacks permission to cancel', () => {
      beforeEach(() => {
        createComponent({ status: 'RUNNING', canUpdateWorkflow: false });
      });

      it('shows cancel button disabled', () => {
        expect(findCancelButton().exists()).toBe(true);
        expect(findCancelButton().props('disabled')).toBe(true);
      });
    });
  });
});
