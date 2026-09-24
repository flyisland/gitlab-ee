import { GlAttributeList, GlLink, GlSkeletonLoader } from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import AgentFlowInfo from 'ee/ai/duo_agents_platform/pages/show/components/agent_flow_info.vue';
import AgentFlowDetailsPanel from 'ee/ai/duo_agents_platform/pages/show/components/agent_flow_details_panel.vue';
import { localeDateFormat } from '~/lib/utils/datetime/locale_dateformat';
import { mockWorkItem, mockMergeRequest } from 'ee_jest/ai/mocks';

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

  const createComponent = (props = {}, mountFn = shallowMountExtended) => {
    wrapper = mountFn(AgentFlowInfo, {
      propsData: {
        isLoading: false,
        status: 'RUNNING',
        agentFlowDefinition: 'software_development',
        allExecutorUrls: ['https://gitlab.com/gitlab-org/gitlab/-/jobs/123'],
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
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
      directives: {
        GlTooltip: createMockDirective('gl-tooltip'),
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

  const findInfoList = () => wrapper.findComponent(GlAttributeList);
  const findListItems = () => wrapper.findComponent(GlAttributeList).props('items');
  const findRow = (label) => wrapper.findByTestId(`info-row-${label}`);
  const findListItemTitles = () => wrapper.findAllByTestId('info-title');
  const findListItemValues = () => wrapper.findAllByTestId('info-value');
  const findSkeletonLoaders = () => wrapper.findAllComponents(GlSkeletonLoader);
  const findLinks = () => wrapper.findAllComponents(GlLink);
  const findModelBadge = () => wrapper.findByTestId('model-badge');
  const findModelRow = () => findRow('Default model');
  const findDetailsPanel = () => wrapper.findComponent(AgentFlowDetailsPanel);

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({ isLoading: true }, mountExtended);
    });

    it('renders the attribute list', () => {
      expect(findInfoList().exists()).toBe(true);
    });

    it('renders all session info items', () => {
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
    describe('when model name and identifier are provided', () => {
      beforeEach(() => {
        createComponent(
          { modelName: 'claude_sonnet_4_6', modelIdentifier: 'claude-sonnet-4-20250514' },
          mountExtended,
        );
      });

      it('renders all expected info values in the correct order', () => {
        const listItems = findListItemValues();
        const expectedData = [
          'software_development', // AI Item
          '4545', // Session ID
          'Flow', // Type
          'Test Project', // Project
          'gitlab-org', // Group
          `#42`, // Work item
          `!7`, // Merge request
          'Jan 1, 2023, 12:00 AM', // Started
          'Jan 1, 2024, 12:00 AM', // Last updated
          '123', // Job IDs
          'claude_sonnet_4_6', // Default model
        ];

        expectedData.forEach((expectedText, index) => {
          expect(listItems.at(index).text()).toContain(expectedText);
        });
      });

      it('renders all the expected titles in the correct order', () => {
        const listItemTitles = findListItemTitles();
        const expectedTitles = [
          'AI Item',
          'Session ID',
          'Type',
          'Project',
          'Group',
          'Work item',
          'Merge request',
          'Started',
          'Last updated',
          'Job IDs',
          'Default model',
        ];

        expectedTitles.forEach((expectedTitle, index) => {
          expect(listItemTitles.at(index).text()).toContain(expectedTitle);
        });
      });

      it.each`
        label              | href                                                               | text
        ${'Session ID'}    | ${'/gitlab-org/test-project/-/automate/agent-sessions/4545'}       | ${'4545'}
        ${'Project'}       | ${'https://gitlab.com/gitlab-org/test-project'}                    | ${'Test Project'}
        ${'Group'}         | ${'https://gitlab.com/gitlab-org'}                                 | ${'gitlab-org'}
        ${'Work item'}     | ${'https://gitlab.com/gitlab-org/test-project/-/work_items/42'}    | ${'#42'}
        ${'Merge request'} | ${'https://gitlab.com/gitlab-org/test-project/-/merge_requests/7'} | ${'!7'}
        ${'Job IDs'}       | ${'https://gitlab.com/gitlab-org/gitlab/-/jobs/123'}               | ${'123'}
      `('renders link for $label', ({ label, href, text }) => {
        const link = findRow(label).findComponent(GlLink);
        expect(link.attributes('href')).toBe(href);
        expect(link.text()).toBe(text);
      });

      it('uses locale-aware date formatting', () => {
        expect(mockDateTimeFormatter.format).toHaveBeenCalledWith(new Date('2023-01-01T00:00:00Z'));
        expect(mockDateTimeFormatter.format).toHaveBeenCalledWith(new Date('2024-01-01T00:00:00Z'));
      });
    });

    describe('when the session ran a catalog item', () => {
      beforeEach(() => {
        createComponent({ aiCatalogItemPath: '/explore/ai-catalog/flows/1799' }, mountExtended);
      });

      it('links the AI Item row to the catalog item', () => {
        const row = findRow('AI Item');
        expect(row.text()).toContain('software_development');
        expect(row.findComponent(GlLink).attributes('href')).toBe('/explore/ai-catalog/flows/1799');
      });
    });

    describe('when a flow version is resolved', () => {
      beforeEach(() => {
        createComponent({ flowVersion: 'v1' }, mountExtended);
      });

      it('appends the version to the AI Item row', () => {
        expect(findRow('AI Item').text()).toContain('software_development · v1');
      });

      describe('when sessionDetailsRightRail is enabled', () => {
        beforeEach(() => {
          window.gon = { features: { sessionDetailsRightRail: true } };
          createComponent({ flowVersion: 'v1' });
        });

        it('passes the versioned name to the details panel', () => {
          expect(findDetailsPanel().props('flowName')).toBe('software_development · v1');
        });
      });
    });

    describe('when the session has no catalog item', () => {
      beforeEach(() => {
        createComponent({}, mountExtended);
      });

      it('renders the AI Item row as plain text', () => {
        const row = findRow('AI Item');
        expect(row.text()).toContain('software_development');
        expect(row.findComponent(GlLink).exists()).toBe(false);
      });
    });

    describe('when work item is linked', () => {
      beforeEach(() => {
        createComponent({ workItem: mockWorkItem }, mountExtended);
      });

      it('renders the work item row with a link', () => {
        const workItemRow = findRow('Work item');
        expect(workItemRow.text()).toContain(`#${mockWorkItem.iid}`);
        expect(workItemRow.findComponent(GlLink).attributes('href')).toBe(mockWorkItem.webUrl);
      });
    });

    describe('when work item is not linked', () => {
      beforeEach(() => {
        createComponent({ workItem: null }, mountExtended);
      });

      it('displays None for work item', () => {
        expect(findRow('Work item').text()).toContain('None');
      });
    });

    describe('when merge request is linked', () => {
      beforeEach(() => {
        createComponent({ mergeRequest: mockMergeRequest }, mountExtended);
      });

      it('renders the merge request row with a link', () => {
        const mrRow = findRow('Merge request');
        expect(mrRow.text()).toContain(`!${mockMergeRequest.iid}`);
        expect(mrRow.findComponent(GlLink).attributes('href')).toBe(mockMergeRequest.webUrl);
      });
    });

    describe('when merge request is not linked', () => {
      beforeEach(() => {
        createComponent({ mergeRequest: null }, mountExtended);
      });

      it('displays None for merge request', () => {
        expect(findRow('Merge request').text()).toContain('None');
      });
    });

    describe('when project information is missing', () => {
      beforeEach(() => {
        createComponent({ project: {} }, mountExtended);
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
        createComponent(
          {
            project: {
              id: 'gid://gitlab/Project/1',
              name: 'Test Project',
              fullPath: 'gitlab-org/test-project',
              webUrl: 'https://gitlab.com/gitlab-org/test-project',
            },
          },
          mountExtended,
        );
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

    describe('job IDs payload text', () => {
      const findJobIdsItem = () => wrapper.vm.payload.find((item) => item.type === 'jobItems');

      it.each`
        allExecutorUrls                                                                                           | expectedText
        ${['https://gitlab.com/gitlab-org/gitlab/-/jobs/123']}                                                    | ${'123'}
        ${['https://gitlab.com/gitlab-org/gitlab/-/jobs/123', 'https://gitlab.com/gitlab-org/gitlab/-/jobs/456']} | ${'123, 456'}
        ${[]}                                                                                                     | ${'None'}
        ${['https://gitlab.com/invalid-url']}                                                                     | ${'None'}
      `(
        'sets text to "$expectedText" for $allExecutorUrls',
        ({ allExecutorUrls, expectedText }) => {
          createComponent({ allExecutorUrls }, mountExtended);

          expect(findJobIdsItem().text).toBe(expectedText);
        },
      );
    });

    describe('Model', () => {
      describe('when a model is available', () => {
        beforeEach(() => {
          createComponent(
            { modelName: 'claude_sonnet_4_6', modelIdentifier: 'claude-sonnet-4-20250514' },
            mountExtended,
          );
        });

        it('renders a pill with the model name', () => {
          expect(findModelBadge().exists()).toBe(true);
          expect(findModelBadge().text()).toBe('claude_sonnet_4_6');
        });

        it('exposes the model identifier as the pill tooltip', () => {
          expect(getBinding(findModelBadge().element, 'gl-tooltip').value).toBe(
            'claude-sonnet-4-20250514',
          );
        });
      });

      describe('when the model has no identifier', () => {
        beforeEach(() => {
          createComponent({ modelName: 'claude_sonnet_4_6', modelIdentifier: '' }, mountExtended);
        });

        it('still renders the model name pill', () => {
          expect(findModelBadge().exists()).toBe(true);
          expect(findModelBadge().text()).toBe('claude_sonnet_4_6');
        });

        it('does not set a tooltip', () => {
          expect(getBinding(findModelBadge().element, 'gl-tooltip').value).toBe('');
        });
      });

      describe('when no model is available', () => {
        beforeEach(() => {
          createComponent({ modelName: '' }, mountExtended);
        });

        it('does not render the Model row', () => {
          expect(findModelRow().exists()).toBe(false);
          expect(findModelBadge().exists()).toBe(false);
        });
      });
    });

    describe('when executor URL is invalid', () => {
      beforeEach(() => {
        createComponent({ allExecutorUrls: ['https://gitlab.com/invalid-url'] }, mountExtended);
      });

      it('does not display a link or job ID for an invalid URL', () => {
        expect(findRow('Job IDs').findComponent(GlLink).exists()).toBe(false);
        expect(findRow('Job IDs').text()).toContain('None');
      });
    });

    describe('when executor URL is empty', () => {
      beforeEach(() => {
        createComponent({ allExecutorUrls: [] }, mountExtended);
      });

      it('displays None for empty executor URL', () => {
        expect(findRow('Job IDs').text()).toContain('None');
      });
    });

    describe('when date values are invalid', () => {
      beforeEach(() => {
        mockDateTimeFormatter.format.mockClear();
        createComponent({ createdAt: null, updatedAt: 'invalid-date' }, mountExtended);
      });

      it('does not display if invalid dates', () => {
        expect(findRow('Started').exists()).toBe(false);
        expect(findRow('Last updated').exists()).toBe(false);
      });

      it('does not call the date formatter for invalid dates', () => {
        expect(mockDateTimeFormatter.format).not.toHaveBeenCalled();
      });
    });
  });

  describe('AgentFlowDetailsPanel', () => {
    afterEach(() => {
      window.gon = {};
    });

    describe('when sessionDetailsRightRail is enabled', () => {
      beforeEach(() => {
        window.gon = { features: { sessionDetailsRightRail: true } };
        createComponent();
      });

      it('renders AgentFlowDetailsPanel instead of GlAttributeList', () => {
        expect(findDetailsPanel().exists()).toBe(true);
        expect(findInfoList().exists()).toBe(false);
      });
    });

    describe('when sessionDetailsRightRail is disabled', () => {
      beforeEach(() => {
        window.gon = { features: { sessionDetailsRightRail: false } };
        createComponent();
      });

      it('renders GlAttributeList instead of AgentFlowDetailsPanel', () => {
        expect(findDetailsPanel().exists()).toBe(false);
        expect(findInfoList().exists()).toBe(true);
      });
    });
  });
});
