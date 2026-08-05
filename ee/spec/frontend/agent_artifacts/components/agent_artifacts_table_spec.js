import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlKeysetPagination, GlTruncate, GlLoadingIcon, GlAlert } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import AgentArtifactsTable from 'ee/agent_artifacts/components/agent_artifacts_table.vue';
import getAgentArtifactsQuery from 'ee/agent_artifacts/graphql/queries/get_agent_artifacts.query.graphql';
import getProjectAgentArtifactsQuery from 'ee/agent_artifacts/graphql/queries/get_project_agent_artifacts.query.graphql';
import waitForPromises from 'helpers/wait_for_promises';
import {
  mockArtifactNodes,
  mockPageInfo,
  mockAgentArtifactsResponse,
  mockProjectAgentArtifactsResponse,
  mockEmptyAgentArtifactsResponse,
} from '../mock_data';

Vue.use(VueApollo);

const GROUP_FULL_PATH = 'gitlab-org';
const PROJECT_FULL_PATH = 'g/p';

describe('AgentArtifactsTable', () => {
  let wrapper;

  const createComponent = ({
    handler = jest.fn().mockResolvedValue(mockAgentArtifactsResponse),
    filter = {},
  } = {}) => {
    const apolloProvider = createMockApollo([[getAgentArtifactsQuery, handler]]);

    wrapper = mountExtended(AgentArtifactsTable, {
      apolloProvider,
      provide: {
        groupFullPath: GROUP_FULL_PATH,
      },
      propsData: {
        filter,
      },
      stubs: {
        GlTruncate,
      },
    });

    return handler;
  };

  const findPagination = () => wrapper.findComponent(GlKeysetPagination);

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({ handler: jest.fn().mockReturnValue(new Promise(() => {})) });
    });

    it('shows the table with busy state', () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('when data is loaded', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('displays ai items', () => {
      const truncate = wrapper.findByTestId('ai-item-name').findComponent(GlTruncate);
      expect(truncate.props('text')).toBe('False positive detection/v1');
    });

    it('renders session links', () => {
      const sessionLinks = wrapper.findAllByTestId('session-link');
      expect(sessionLinks).toHaveLength(2);
      expect(sessionLinks.at(0).attributes('href')).toBe(mockArtifactNodes[0].webPath);
      expect(sessionLinks.at(0).text()).toBe('#1908');
    });

    it('displays audit events count', () => {
      const auditCounts = wrapper.findAllByTestId('audit-events-count');
      expect(auditCounts).toHaveLength(2);
      expect(auditCounts.at(0).text()).toBe(`${mockArtifactNodes[0].auditEventsCount}`);
    });

    it('renders project links', () => {
      const { project } = mockArtifactNodes[0];
      const projectLinks = wrapper.findAllByTestId('project-link');
      expect(projectLinks).toHaveLength(2);
      expect(projectLinks.at(0).attributes('href')).toBe(project.webPath);
      const truncate = projectLinks.at(0).findComponent(GlTruncate);
      expect(truncate.props('text')).toBe(project.name);
    });

    it('displays formatted start time', () => {
      const startTimes = wrapper.findAllByTestId('start-time');
      expect(startTimes).toHaveLength(2);
      expect(startTimes.at(0).text()).toContain('2026-03-05');
      expect(startTimes.at(0).text()).toContain('22:14:17');
    });
  });

  describe('pagination', () => {
    describe('when pages available', () => {
      let handler;

      beforeEach(async () => {
        handler = createComponent();
        await waitForPromises();
      });

      it('renders pagination', () => {
        expect(findPagination().exists()).toBe(true);
      });

      it('fetches next page when pagination emits next', async () => {
        findPagination().vm.$emit('next', mockPageInfo.endCursor);
        await waitForPromises();

        expect(handler).toHaveBeenCalledTimes(2);
        expect(handler).toHaveBeenLastCalledWith(
          expect.objectContaining({ after: mockPageInfo.endCursor, before: null }),
        );
      });

      it('fetches previous page when pagination emits prev', async () => {
        findPagination().vm.$emit('prev', mockPageInfo.startCursor);
        await waitForPromises();

        expect(handler).toHaveBeenCalledTimes(2);
        expect(handler).toHaveBeenLastCalledWith(
          expect.objectContaining({ before: mockPageInfo.startCursor, after: null }),
        );
      });
    });

    describe('when no pages available', () => {
      it('does not render pagination', async () => {
        createComponent({
          handler: jest.fn().mockResolvedValue(mockEmptyAgentArtifactsResponse),
        });
        await waitForPromises();

        expect(findPagination().exists()).toBe(false);
      });
    });
  });

  describe('empty state', () => {
    beforeEach(async () => {
      createComponent({
        handler: jest.fn().mockResolvedValue(mockEmptyAgentArtifactsResponse),
      });
      await waitForPromises();
    });

    it('shows empty state message', () => {
      expect(wrapper.text()).toContain('No agent artifacts found.');
    });
  });

  describe('error state', () => {
    beforeEach(async () => {
      createComponent({
        handler: jest.fn().mockRejectedValue(new Error('GraphQL error')),
      });
      await waitForPromises();
    });

    it('shows error alert', () => {
      const alert = wrapper.findComponent(GlAlert);
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain('Failed to load agent artifacts.');
    });
  });

  describe('row click handling', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('emits row-click event when a row is clicked', async () => {
      const rows = wrapper.findAllByTestId('agent-artifacts-table-row');
      await rows.at(0).trigger('click');

      expect(wrapper.emitted('row-click')).toHaveLength(1);
      expect(wrapper.emitted('row-click')[0][0]).toEqual(mockArtifactNodes[0]);
    });
  });

  describe('filtering', () => {
    it('passes filter to GraphQL query', async () => {
      const filter = { name: 'Test Agent' };
      const handler = createComponent({ filter });
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith(expect.objectContaining(filter));
    });

    it('passes not filter to GraphQL query', async () => {
      const filter = { not: { name: 'Excluded Agent' } };
      const handler = createComponent({ filter });
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith(expect.objectContaining(filter));
    });

    it('resets pagination when filter changes', async () => {
      const handler = createComponent({ filter: { name: 'Initial' } });
      await waitForPromises();

      findPagination().vm.$emit('next', mockPageInfo.endCursor);
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith(
        expect.objectContaining({ after: mockPageInfo.endCursor }),
      );

      await wrapper.setProps({ filter: { name: 'Updated' } });
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith(expect.objectContaining({ after: null, before: null }));
    });
  });

  describe('project mode', () => {
    let handler;

    const createProjectComponent = () => {
      handler = jest.fn().mockResolvedValue(mockProjectAgentArtifactsResponse);
      const apolloProvider = createMockApollo([[getProjectAgentArtifactsQuery, handler]]);

      wrapper = mountExtended(AgentArtifactsTable, {
        apolloProvider,
        provide: {
          groupFullPath: null,
          projectFullPath: PROJECT_FULL_PATH,
        },
        propsData: {
          filter: {},
        },
        stubs: {
          GlTruncate,
        },
      });
    };

    beforeEach(async () => {
      createProjectComponent();
      await waitForPromises();
    });

    it('queries the project query with projectFullPath and no group/project path vars', () => {
      expect(handler).toHaveBeenCalledWith(
        expect.objectContaining({ projectFullPath: PROJECT_FULL_PATH }),
      );
      const variables = handler.mock.calls[0][0];
      expect(variables).not.toHaveProperty('groupFullPath');
      expect(variables).not.toHaveProperty('projectPath');
    });

    it('renders rows from data.project.duoWorkflowSessionArtifacts', () => {
      expect(wrapper.findAllByTestId('session-link')).toHaveLength(mockArtifactNodes.length);
    });

    it('hides the redundant Project column', () => {
      expect(wrapper.findAllByTestId('project-link')).toHaveLength(0);
      expect(wrapper.findAll('th').wrappers.map((th) => th.text())).not.toContain('Project');
    });
  });

  describe('group mode (regression)', () => {
    let handler;

    beforeEach(async () => {
      handler = createComponent();
      await waitForPromises();
    });

    it('queries the group query with groupFullPath', () => {
      expect(handler).toHaveBeenCalledWith(
        expect.objectContaining({ groupFullPath: GROUP_FULL_PATH }),
      );
    });

    it('renders rows from data.group.duoWorkflowSessionArtifacts', () => {
      expect(wrapper.findAllByTestId('session-link')).toHaveLength(mockArtifactNodes.length);
    });
  });
});
