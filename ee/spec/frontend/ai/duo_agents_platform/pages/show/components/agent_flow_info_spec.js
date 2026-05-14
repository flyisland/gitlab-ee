import { GlBadge, GlLink, GlSkeletonLoader } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentFlowInfo from 'ee/ai/duo_agents_platform/pages/show/components/agent_flow_info.vue';
import AgentFlowTriggeredUser from 'ee/ai/duo_agents_platform/components/common/agent_flow_triggered_user.vue';
import { localeDateFormat } from '~/lib/utils/datetime/locale_dateformat';

jest.mock('~/lib/utils/datetime/locale_dateformat');

describe('AgentFlowInfo', () => {
  let wrapper;

  const mockDateTimeFormatter = {
    format: jest.fn(),
  };

  beforeEach(() => {
    localeDateFormat.asDateTime = mockDateTimeFormatter;
    mockDateTimeFormatter.format.mockImplementation((date) => {
      // Mock the locale-aware formatting to return a predictable format for testing
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
        executorUrl: 'https://gitlab.com/gitlab-org/gitlab/-/jobs/123',
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
        userId: 'gid://gitlab/User/1',
        canUpdateWorkflow: true,
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
  const findListItemTitles = () => wrapper.findAllByTestId('info-title');
  const findListItemValues = () => wrapper.findAllByTestId('info-value');
  const findSkeletonLoaders = () => wrapper.findAllComponents(GlSkeletonLoader);
  const findCancelButton = () => wrapper.findByTestId('cancel-session-button');
  const findLinks = () => wrapper.findAllComponents(GlLink);
  const findBadge = () => wrapper.findComponent(GlBadge);
  const findTriggeredUser = () => wrapper.findComponent(AgentFlowTriggeredUser);

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({
        isLoading: true,
      });
    });

    it('renders the heading', () => {
      expect(findHeading().text()).toBe('Session information');
    });

    it('renders the info list', () => {
      expect(findInfoList().exists()).toBe(true);
    });

    it('renders all session info items as list items', () => {
      expect(findListItems()).toHaveLength(10);
    });

    it('displays the skeleton loaders', () => {
      expect(findSkeletonLoaders()).toHaveLength(10);
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
        '4545', // Session ID
        'Flow', // Type
        'Test Project', // Project
        'gitlab-org', // Group
        // Triggered by (AgentFlowTriggeredUser component)
        'Running', // Status
        'Jan 1, 2023, 12:00 AM', // Started
        'Jan 1, 2024, 12:00 AM', // Last updated
        '123', // Job ID
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
        'Status',
        'Started',
        'Last updated',
        'Job ID',
      ];

      expectedTitles.forEach((expectedTitle, index) => {
        expect(listItemTitles.at(index).text()).toContain(expectedTitle);
      });
    });

    it.each`
      index | href                                                                           | text
      ${0}  | ${'https://gitlab.com/gitlab-org/test-project/-/automate/agent-sessions/4545'} | ${'#4545'}
      ${1}  | ${'https://gitlab.com/gitlab-org/test-project'}                                | ${'Test Project'}
      ${2}  | ${'https://gitlab.com/gitlab-org'}                                             | ${'gitlab-org'}
      ${3}  | ${'https://gitlab.com/gitlab-org/gitlab/-/jobs/123'}                           | ${'#123'}
    `('renders links for session ID, project, group, and job ID', ({ index, href, text }) => {
      const links = findLinks();
      expect(links.at(index).attributes('href')).toBe(href);
      expect(links.at(index).text()).toBe(text);
    });

    describe('when project information is missing', () => {
      beforeEach(() => {
        createComponent({
          project: {},
        });
      });

      it('displays N/A for missing project information', () => {
        expect(findListItems().at(3).text()).toContain('N/A'); // Project name
        expect(findListItems().at(4).text()).toContain('N/A'); // Group name
      });

      it('does not display links for project, group, and sessionId', () => {
        expect(findListItems().at(1).findComponent(GlLink).exists()).toBe(false); // Session ID link
        expect(findListItems().at(3).findComponent(GlLink).exists()).toBe(false); // Project link
        expect(findListItems().at(4).findComponent(GlLink).exists()).toBe(false); // Group link
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

      it('displays N/A for missing namespace information', () => {
        expect(findListItems().at(3).text()).toContain('Test Project'); // Project name should still show
        expect(findListItems().at(4).text()).toContain('N/A'); // Group name should be N/A
      });

      it('displays project, sessionId, and executor links but not group link', () => {
        const links = findLinks();

        expect(links).toHaveLength(3);
        expect(links.at(0).attributes('href')).toBe(
          'https://gitlab.com/gitlab-org/test-project/-/automate/agent-sessions/4545',
        );
        expect(links.at(1).attributes('href')).toBe('https://gitlab.com/gitlab-org/test-project');
        expect(links.at(2).attributes('href')).toBe(
          'https://gitlab.com/gitlab-org/gitlab/-/jobs/123',
        );
      });
    });

    describe('when executor URL is invalid', () => {
      beforeEach(() => {
        createComponent({
          executorUrl: 'https://gitlab.com/invalid-url',
        });
      });

      it('displays N/A for invalid job ID', () => {
        expect(findListItems().at(9).text()).toContain('N/A');
      });
    });

    describe('when executor URL is empty', () => {
      beforeEach(() => {
        createComponent({
          executorUrl: '',
        });
      });

      it('displays N/A for empty executor URL', () => {
        expect(findListItems().at(9).text()).toContain('N/A');
      });
    });

    it('uses locale-aware date formatting', () => {
      expect(mockDateTimeFormatter.format).toHaveBeenCalledWith(new Date('2023-01-01T00:00:00Z'));
      expect(mockDateTimeFormatter.format).toHaveBeenCalledWith(new Date('2024-01-01T00:00:00Z'));
    });

    describe('when date values are invalid', () => {
      beforeEach(() => {
        mockDateTimeFormatter.format.mockClear();
        createComponent({
          createdAt: null,
          updatedAt: 'invalid-date',
        });
      });

      it('displays N/A for invalid dates', () => {
        expect(findListItems().at(7).text()).toContain('N/A'); // Started
        expect(findListItems().at(8).text()).toContain('N/A'); // Last updated
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
