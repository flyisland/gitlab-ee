import { GlAttributeList, GlIntersperse, GlLink } from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { stubComponent } from 'helpers/stub_component';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import AgentFlowDetailsPanel from 'ee/ai/duo_agents_platform/pages/show/components/agent_flow_details_panel.vue';
import AgentFlowTriggeredUser from 'ee/ai/duo_agents_platform/components/common/agent_flow_triggered_user.vue';
import {
  mockUser1,
  mockProject,
  mockProjectWithoutNamespace,
  mockJobItems,
} from 'ee_jest/ai/mocks';

describe('AgentFlowDetailsPanel', () => {
  let wrapper;

  const createComponent = (props = {}, mountFn = shallowMountExtended) => {
    wrapper = mountFn(AgentFlowDetailsPanel, {
      propsData: {
        sessionId: '42',
        sessionUrl: '/gitlab-org/test-project/-/automate/agent-sessions/42',
        flowName: 'software_development',
        project: mockProject,
        user: mockUser1,
        createdAt: 'Jan 1, 2023, 12:00 AM',
        updatedAt: 'Jan 1, 2024, 12:00 AM',
        jobItems: mockJobItems,
        ...props,
      },
      directives: { GlTooltip: createMockDirective('gl-tooltip') },
      stubs: { AgentFlowTriggeredUser: stubComponent(AgentFlowTriggeredUser) },
    });
  };

  const findAttributeList = () => wrapper.findComponent(GlAttributeList);
  const findRow = (label) => wrapper.findByTestId(`row-${label}`);
  const findRowValue = (label) => findRow(label).find('[data-testid="detail-value"]');
  const findTriggeredUser = () => wrapper.findComponent(AgentFlowTriggeredUser);
  const findModelBadge = () => wrapper.findByTestId('model-badge');
  const findCiJobsRow = (count) => findRowValue(count === 1 ? 'CI job' : 'CI jobs');
  const findJobIntersperse = (count = 2) => findCiJobsRow(count).findComponent(GlIntersperse);

  describe('GlAttributeList', () => {
    beforeEach(() => createComponent());

    it('renders with vertical layout', () => {
      expect(findAttributeList().props('layout')).toBe('vertical');
    });

    it('passes three sections as items', () => {
      expect(findAttributeList().props('items')).toHaveLength(3);
    });

    it('passes the Identity, Execution, and Supplemental section labels', () => {
      const labels = findAttributeList()
        .props('items')
        .map((item) => item.label);
      expect(labels).toEqual(['Identity', 'Execution', 'Supplemental']);
    });
  });

  describe('Identity section', () => {
    describe('when sessionUrl is provided', () => {
      beforeEach(() => createComponent({}, mountExtended));

      it('renders the session ID as a link', () => {
        const link = findRowValue('Session').findComponent(GlLink);
        expect(link.text()).toBe('42');
        expect(link.attributes('href')).toBe(
          '/gitlab-org/test-project/-/automate/agent-sessions/42',
        );
      });

      it('renders the session icon', () => {
        expect(findRowValue('Session').findComponent({ name: 'GlIcon' }).props('name')).toBe(
          'session-ai',
        );
      });
    });

    describe('when sessionUrl is not provided', () => {
      beforeEach(() => createComponent({ sessionUrl: '' }, mountExtended));

      it('renders the session ID as plain text', () => {
        expect(findRowValue('Session').findComponent(GlLink).exists()).toBe(false);
        expect(findRowValue('Session').text()).toContain('42');
      });
    });

    describe('flow name', () => {
      beforeEach(() => createComponent({}, mountExtended));

      it('renders the flow name', () => {
        expect(findRowValue('Flow').text()).toContain('software_development');
      });
    });

    describe('when flowPath is provided', () => {
      beforeEach(() =>
        createComponent({ flowPath: '/explore/ai-catalog/flows/1799' }, mountExtended),
      );

      it('renders the flow name as a link to the catalog item', () => {
        const link = findRowValue('Flow').findComponent(GlLink);
        expect(link.text()).toBe('software_development');
        expect(link.attributes('href')).toBe('/explore/ai-catalog/flows/1799');
      });
    });

    describe('when flowPath is not provided', () => {
      beforeEach(() => createComponent({}, mountExtended));

      it('renders the flow name as plain text', () => {
        expect(findRowValue('Flow').findComponent(GlLink).exists()).toBe(false);
      });
    });

    describe('when project has a webPath', () => {
      beforeEach(() => createComponent({}, mountExtended));

      it('renders the project name as a link', () => {
        const link = findRowValue('Project').findComponent(GlLink);
        expect(link.text()).toBe('Test Project');
        expect(link.attributes('href')).toBe('/gitlab-org/test-project');
      });
    });

    describe('when project has no webPath', () => {
      beforeEach(() => createComponent({ project: { name: 'Test Project' } }, mountExtended));

      it('renders the project name as plain text', () => {
        expect(findRowValue('Project').findComponent(GlLink).exists()).toBe(false);
        expect(findRowValue('Project').text()).toContain('Test Project');
      });
    });

    describe('when project has no name', () => {
      beforeEach(() => createComponent({ project: {} }, mountExtended));

      it('renders None', () => {
        expect(findRowValue('Project').text()).toContain('None');
      });
    });

    describe('when project has a namespace', () => {
      beforeEach(() => createComponent({}, mountExtended));

      it('renders the group name as a link', () => {
        const link = findRowValue('Group').findComponent(GlLink);
        expect(link.text()).toBe('gitlab-org');
        expect(link.attributes('href')).toBe('/gitlab-org');
      });

      it('renders the group icon', () => {
        expect(findRowValue('Group').findComponent({ name: 'GlIcon' }).props('name')).toBe('group');
      });
    });

    describe('when project has no namespace', () => {
      beforeEach(() => createComponent({ project: mockProjectWithoutNamespace }, mountExtended));

      it('renders None for the group', () => {
        expect(findRowValue('Group').findComponent(GlLink).exists()).toBe(false);
        expect(findRowValue('Group').text()).toContain('None');
      });
    });
  });

  describe('Execution section', () => {
    describe('with default props', () => {
      beforeEach(() => createComponent({}, mountExtended));

      it('renders AgentFlowTriggeredUser with the user prop', () => {
        expect(findTriggeredUser().props('user')).toEqual(mockUser1);
      });

      it('renders the started timestamp', () => {
        expect(findRowValue('Started').text()).toContain('Jan 1, 2023, 12:00 AM');
      });

      it('renders the last updated timestamp', () => {
        expect(findRowValue('Last updated').text()).toContain('Jan 1, 2024, 12:00 AM');
      });
    });

    describe('when createdAt is null', () => {
      beforeEach(() => createComponent({ createdAt: null }, mountExtended));

      it('does not render the started row', () => {
        expect(findRow('Started').exists()).toBe(false);
      });
    });

    describe('when updatedAt is null', () => {
      beforeEach(() => createComponent({ updatedAt: null }, mountExtended));

      it('does not render the last updated row', () => {
        expect(findRow('Last updated').exists()).toBe(false);
      });
    });
  });

  describe('Supplemental section', () => {
    describe('CI jobs', () => {
      describe('when one jobItem is provided', () => {
        beforeEach(() => createComponent({}, mountExtended));

        it('renders the singular CI job label', () => {
          expect(findCiJobsRow(1).exists()).toBe(true);
        });

        it('renders job link inside GlIntersperse', () => {
          expect(findJobIntersperse(1).exists()).toBe(true);
          const link = findJobIntersperse(1).findComponent(GlLink);
          expect(link.text()).toBe('456');
          expect(link.attributes('href')).toBe('https://gitlab.com/gitlab-org/gitlab/-/jobs/456');
        });

        it('renders the raw runner output hint', () => {
          expect(findCiJobsRow(1).text()).toContain('Raw runner output');
        });
      });

      describe('when multiple jobItems are provided', () => {
        beforeEach(() =>
          createComponent(
            {
              jobItems: [
                { iid: '123', webPath: 'https://gitlab.com/-/jobs/123' },
                { iid: '456', webPath: 'https://gitlab.com/-/jobs/456' },
              ],
            },
            mountExtended,
          ),
        );

        it('renders the plural CI jobs label', () => {
          expect(findCiJobsRow(2).exists()).toBe(true);
        });

        it('renders all job links inside GlIntersperse', () => {
          const links = findJobIntersperse(2).findAllComponents(GlLink);
          expect(links).toHaveLength(2);
          expect(links.at(0).text()).toBe('123');
          expect(links.at(1).text()).toBe('456');
        });
      });

      describe('when jobItems is empty', () => {
        beforeEach(() => createComponent({ jobItems: [] }, mountExtended));

        it('renders None without GlIntersperse', () => {
          expect(findJobIntersperse(0).exists()).toBe(false);
          expect(findCiJobsRow(0).text()).toContain('None');
        });
      });
    });

    describe('model', () => {
      describe('when modelName is provided', () => {
        beforeEach(() =>
          createComponent(
            { modelName: 'claude_sonnet_4_6', modelIdentifier: 'claude-sonnet-4-20250514' },
            mountExtended,
          ),
        );

        it('renders the model badge', () => {
          expect(findModelBadge().text()).toBe('claude_sonnet_4_6');
        });

        it('sets the model identifier as the tooltip', () => {
          expect(getBinding(findModelBadge().element, 'gl-tooltip').value).toBe(
            'claude-sonnet-4-20250514',
          );
        });
      });

      describe('when modelName is not provided', () => {
        beforeEach(() => createComponent({ modelName: '' }));

        it('does not render the model row', () => {
          expect(findRow('Default model').exists()).toBe(false);
          expect(findModelBadge().exists()).toBe(false);
        });
      });
    });
  });
});
