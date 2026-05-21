import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlLink } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import AgentStatusIcon from 'ee/ai/shared/widgets/agent_status_icon.vue';
import MessageToolStartFlow from 'ee/ai/duo_agentic_chat/components/messages/message_tool_start_flow.vue';
import getFlowStatusQuery from 'ee/ai/graphql/get_flow_status.query.graphql';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPENAME_AI_DUO_WORKFLOW } from '~/graphql_shared/constants';
import { captureExceptionForDuoChat } from 'ee/ai/duo_agentic_chat/observability/sentry_utils';
import { visitUrl } from '~/lib/utils/url_utility';
import { EventsTracker } from 'ee/ai/duo_agentic_chat/observability/events_tracker';
import { MOCK_START_FLOW_TOOL_MESSAGE } from '../mock_data';

jest.mock('ee/ai/duo_agentic_chat/observability/sentry_utils');
jest.mock('~/lib/utils/url_utility');
jest.mock('ee/ai/duo_agentic_chat/observability/events_tracker');

Vue.use(VueApollo);

describe('MessageToolStartFlow', () => {
  let wrapper;
  let flowStatusHandler;

  const mockFlowStatusResponse = (status = 'RUNNING') => ({
    data: {
      duoWorkflowWorkflows: {
        edges: [{ node: { id: convertToGraphQLId(TYPENAME_AI_DUO_WORKFLOW, 326), status } }],
      },
    },
  });

  beforeEach(() => {
    flowStatusHandler = jest.fn().mockResolvedValue(mockFlowStatusResponse());
  });

  const createComponent = (props = {}) => {
    const apolloProvider = createMockApollo();
    apolloProvider.defaultClient.setRequestHandler(getFlowStatusQuery, flowStatusHandler);

    wrapper = shallowMountExtended(MessageToolStartFlow, {
      propsData: { message: MOCK_START_FLOW_TOOL_MESSAGE, ...props },
      apolloProvider,
    });
  };

  const findStatusIcon = () => wrapper.findComponent(AgentStatusIcon);
  const findLink = () => wrapper.findComponent(GlLink);

  it('renders the component', () => {
    createComponent();

    expect(wrapper.findByTestId('start-flow-message').exists()).toBe(true);
  });

  describe('flow name', () => {
    it('displays the flow name from tool_response', () => {
      createComponent();

      expect(wrapper.text()).toContain('fix_pipeline/v1');
    });

    it('includes the workflow ID', () => {
      createComponent();

      expect(wrapper.text()).toContain('#326');
    });
  });

  describe('status', () => {
    it('uppercases the tool response status as the internal status', () => {
      createComponent();

      expect(findStatusIcon().props('status')).toBe('STARTED');
    });

    it('capitalizes the internal status as the human-readable status', () => {
      createComponent();

      expect(findStatusIcon().props('humanStatus')).toBe('Started');
    });

    it('displays the human-readable status text', () => {
      createComponent();

      expect(wrapper.text()).toContain('Started');
    });
  });

  describe('accessibility', () => {
    it('marks the status icon wrapper as aria-hidden', () => {
      createComponent();

      expect(findStatusIcon().element.parentElement.getAttribute('aria-hidden')).toBe('true');
    });

    it('does not set aria-label on the session link since visible text is sufficient', () => {
      createComponent();

      expect(findLink().attributes('aria-label')).toBeUndefined();
    });
  });

  describe('session link', () => {
    it('renders a link to the session URL containing the status and arrow icon', () => {
      createComponent();

      expect(findLink().exists()).toBe(true);
      expect(findLink().attributes('href')).toBe(
        'https://example.com/gitlab-duo/test/-/automate/agent-sessions/326',
      );
      expect(findLink().text()).toContain('Started');
    });

    describe('when the link is clicked', () => {
      it('tracks the click-through event with the tool name', async () => {
        createComponent();

        await findLink().vm.$emit('click', new Event('click'));

        expect(EventsTracker.trackClickThroughFlowWidget).toHaveBeenCalledWith({
          toolName: 'start_flow',
        });
      });

      it('opens the session URL via visitUrl', async () => {
        createComponent();

        await findLink().vm.$emit('click', new Event('click'));

        expect(visitUrl).toHaveBeenCalledWith(
          'https://example.com/gitlab-duo/test/-/automate/agent-sessions/326',
          true,
        );
      });
    });

    it('does not render a link when session URL is absent', () => {
      const toolResponseContent = JSON.stringify({
        status: 'started',
        workflow_id: 1,
        flow_name: 'fix_pipeline/v1',
      });
      const message = {
        ...MOCK_START_FLOW_TOOL_MESSAGE,
        tool_info: {
          ...MOCK_START_FLOW_TOOL_MESSAGE.tool_info,
          tool_response: {
            ...MOCK_START_FLOW_TOOL_MESSAGE.tool_info.tool_response,
            content: toolResponseContent,
          },
        },
      };

      createComponent({ message });

      expect(findLink().exists()).toBe(false);
    });
  });

  describe('error handling', () => {
    it('captures GraphQL errors in Sentry', async () => {
      const error = new Error('GraphQL error');
      flowStatusHandler.mockRejectedValue(error);

      createComponent();
      await waitForPromises();

      expect(captureExceptionForDuoChat).toHaveBeenCalledWith(error);
    });
  });

  describe('polling', () => {
    it('fetches the flow status immediately using the GraphQL global ID', async () => {
      createComponent();
      await waitForPromises();

      expect(flowStatusHandler).toHaveBeenCalledWith({
        id: convertToGraphQLId(TYPENAME_AI_DUO_WORKFLOW, 326),
      });
    });

    it('displays the status returned by the query', async () => {
      flowStatusHandler.mockResolvedValue(mockFlowStatusResponse('RUNNING'));

      createComponent();
      await waitForPromises();

      expect(findStatusIcon().props('status')).toBe('RUNNING');
      expect(findStatusIcon().props('humanStatus')).toBe('Running');
    });

    it('does not poll when workflowId is absent', async () => {
      const toolResponseContent = JSON.stringify({
        status: 'started',
        flow_name: 'fix_pipeline/v1',
      });
      const message = {
        ...MOCK_START_FLOW_TOOL_MESSAGE,
        tool_info: {
          ...MOCK_START_FLOW_TOOL_MESSAGE.tool_info,
          tool_response: {
            ...MOCK_START_FLOW_TOOL_MESSAGE.tool_info.tool_response,
            content: toolResponseContent,
          },
        },
      };

      createComponent({ message });
      await waitForPromises();

      expect(flowStatusHandler).not.toHaveBeenCalled();
    });

    it('stops polling when a terminal status is reached', async () => {
      flowStatusHandler.mockResolvedValue(mockFlowStatusResponse('FINISHED'));

      createComponent();
      await waitForPromises();

      expect(findStatusIcon().props('status')).toBe('FINISHED');
      expect(findStatusIcon().props('humanStatus')).toBe('Finished');

      // Subsequent polls should be skipped
      expect(flowStatusHandler).toHaveBeenCalledTimes(1);
    });
  });
});
