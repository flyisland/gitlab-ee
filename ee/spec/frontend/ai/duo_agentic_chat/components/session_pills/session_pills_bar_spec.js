import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlCollapse, GlDisclosureDropdown } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import SessionPillsBar from 'ee/ai/duo_agentic_chat/components/session_pills/session_pills_bar.vue';
import SessionPill from 'ee/ai/duo_agentic_chat/components/session_pills/session_pill.vue';
import getWorkflowsByIdsQuery from 'ee/ai/graphql/get_workflows_by_ids.query.graphql';
import AgentFlowCancelationModal from 'ee/ai/duo_agents_platform/pages/show/components/agent_flow_cancelation_modal.vue';
import { eventHub, SHOW_SESSION } from 'ee/ai/events/panel';
import { cancelWorkflow } from 'ee/rest_api';
import { createAlert } from '~/alert';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPENAME_AI_DUO_WORKFLOW } from '~/graphql_shared/constants';

jest.mock('ee/rest_api');
jest.mock('~/alert');

Vue.use(VueApollo);

const toGid = (id) => convertToGraphQLId(TYPENAME_AI_DUO_WORKFLOW, id);

const buildStartFlowMessage = ({ workflowId, flowName, status = 'RUNNING' }) => ({
  message_type: 'tool',
  message_sub_type: 'start_flow',
  tool_info: {
    name: 'start_flow',
    tool_response: {
      content: JSON.stringify({
        workflow_id: workflowId,
        flow_name: flowName,
        status,
      }),
    },
  },
});

const buildWorkflowsByIdsResponse = (workflows) => ({
  data: {
    duoWorkflowWorkflows: {
      edges: workflows.map((w) => ({
        node: {
          id: toGid(w.id),
          status: w.status,
          // Before generation, the title is the workflow definition.
          title: w.title === undefined ? 'fix_pipeline/v1' : w.title,
          workflowDefinition: 'fix_pipeline/v1',
        },
      })),
    },
  },
});

describe('SessionPillsBar', () => {
  let wrapper;
  let workflowsByIdsHandler;
  let originalResizeObserver;

  beforeEach(() => {
    originalResizeObserver = global.ResizeObserver;
    global.ResizeObserver = jest.fn().mockImplementation(() => ({
      observe: jest.fn(),
      unobserve: jest.fn(),
      disconnect: jest.fn(),
    }));

    workflowsByIdsHandler = jest
      .fn()
      .mockResolvedValue(buildWorkflowsByIdsResponse([{ id: 326, status: 'RUNNING' }]));
  });

  afterEach(() => {
    global.ResizeObserver = originalResizeObserver;
  });

  const createComponent = ({ messages = [], handler = workflowsByIdsHandler } = {}) => {
    const apolloProvider = createMockApollo();
    apolloProvider.defaultClient.setRequestHandler(getWorkflowsByIdsQuery, handler);

    wrapper = shallowMountExtended(SessionPillsBar, {
      propsData: { messages },
      apolloProvider,
      // Rendered for real so the collapsed/expanded state is observable.
      stubs: { GlCollapse },
    });
  };

  const findBar = () => wrapper.findByTestId('session-pills-bar');
  const findCollapse = () => wrapper.findComponent(GlCollapse);
  const findPills = () => wrapper.findAllComponents(SessionPill);
  const findOverflow = () => wrapper.findComponent(GlDisclosureDropdown);
  const findCancelationModal = () => wrapper.findComponent(AgentFlowCancelationModal);

  describe('initial render', () => {
    it('renders no pills before the polled query resolves', () => {
      createComponent({
        messages: [buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' })],
      });

      expect(findPills()).toHaveLength(0);
    });

    describe('when no start_flow messages are present', () => {
      beforeEach(async () => {
        createComponent({ messages: [] });
        await waitForPromises();
      });

      it('does not fire the query', () => {
        expect(workflowsByIdsHandler).not.toHaveBeenCalled();
        expect(findPills()).toHaveLength(0);
      });
    });
  });

  describe('query variables', () => {
    it('passes the workflow ids extracted from start_flow messages as GIDs', async () => {
      createComponent({
        messages: [
          buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' }),
          buildStartFlowMessage({ workflowId: 327, flowName: 'fix_pipeline/v2' }),
        ],
      });
      await waitForPromises();

      expect(workflowsByIdsHandler).toHaveBeenCalledWith({
        ids: [toGid(326), toGid(327)],
      });
    });

    it('dedupes workflow ids that appear multiple times in messages', async () => {
      const handler = jest
        .fn()
        .mockResolvedValue(
          buildWorkflowsByIdsResponse([{ id: 326, status: 'RUNNING', title: null }]),
        );
      createComponent({
        messages: [
          buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' }),
          buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v2' }),
        ],
        handler,
      });
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith({ ids: [toGid(326)] });
      expect(findPills()).toHaveLength(1);
      // With no title to show, the label falls back to the most recent flow name.
      expect(findPills().at(0).props('label')).toBe('Fix pipeline/v2 #326');
    });

    it('ignores chat messages that are not start_flow tool calls', async () => {
      createComponent({
        messages: [
          { message_type: 'user', message_sub_type: null, tool_info: null },
          buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' }),
        ],
      });
      await waitForPromises();

      expect(workflowsByIdsHandler).toHaveBeenCalledWith({ ids: [toGid(326)] });
    });

    it('handles malformed tool_response JSON gracefully', async () => {
      createComponent({
        messages: [
          {
            message_type: 'tool',
            message_sub_type: 'start_flow',
            tool_info: { tool_response: { content: 'not-json' } },
          },
        ],
      });
      await waitForPromises();

      expect(workflowsByIdsHandler).not.toHaveBeenCalled();
      expect(findPills()).toHaveLength(0);
    });
  });

  describe('pill rendering', () => {
    it('renders a pill for each non-terminal workflow returned by the query', async () => {
      createComponent({
        messages: [buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' })],
      });
      await waitForPromises();

      expect(findPills()).toHaveLength(1);
      expect(findPills().at(0).props()).toMatchObject({
        workflowId: 326,
        label: 'Fix pipeline/v1 #326',
        status: 'RUNNING',
      });
    });

    it('labels the pill with the generated session title once available', async () => {
      createComponent({
        messages: [buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' })],
        handler: jest
          .fn()
          .mockResolvedValue(
            buildWorkflowsByIdsResponse([
              { id: 326, status: 'RUNNING', title: 'Fix flaky pipeline spec' },
            ]),
          ),
      });
      await waitForPromises();

      expect(findPills().at(0).props('label')).toBe('Fix flaky pipeline spec');
    });

    it('filters out workflows in a terminal status returned by the query', async () => {
      workflowsByIdsHandler = jest.fn().mockResolvedValue(
        buildWorkflowsByIdsResponse([
          { id: 1, status: 'RUNNING' },
          { id: 2, status: 'FINISHED' },
          { id: 3, status: 'FAILED' },
          { id: 4, status: 'STOPPED' },
        ]),
      );
      createComponent({
        messages: [
          buildStartFlowMessage({ workflowId: 1, flowName: 'a' }),
          buildStartFlowMessage({ workflowId: 2, flowName: 'b' }),
          buildStartFlowMessage({ workflowId: 3, flowName: 'c' }),
          buildStartFlowMessage({ workflowId: 4, flowName: 'd' }),
        ],
      });
      await waitForPromises();

      expect(findPills()).toHaveLength(1);
      expect(findPills().at(0).props('workflowId')).toBe(1);
    });

    it('surfaces workflows awaiting user input ahead of merely active ones', async () => {
      workflowsByIdsHandler = jest.fn().mockResolvedValue(
        buildWorkflowsByIdsResponse([
          { id: 1, status: 'RUNNING' },
          { id: 2, status: 'INPUT_REQUIRED' },
          { id: 3, status: 'RUNNING' },
          { id: 4, status: 'PLAN_APPROVAL_REQUIRED' },
        ]),
      );
      createComponent({
        messages: [
          buildStartFlowMessage({ workflowId: 1, flowName: 'a' }),
          buildStartFlowMessage({ workflowId: 2, flowName: 'b' }),
          buildStartFlowMessage({ workflowId: 3, flowName: 'c' }),
          buildStartFlowMessage({ workflowId: 4, flowName: 'd' }),
        ],
      });
      await waitForPromises();

      const ids = findPills().wrappers.map((w) => w.props('workflowId'));
      expect(ids.slice(0, 2)).toEqual([2, 4]);
    });
  });

  describe('collapse state', () => {
    describe('when there are no active sessions', () => {
      beforeEach(() => {
        createComponent();
      });

      it('keeps the bar mounted but collapsed', () => {
        expect(findBar().exists()).toBe(true);
        expect(findCollapse().props('visible')).toBe(false);
        expect(findBar().isVisible()).toBe(false);
      });
    });

    describe('when a session is active', () => {
      beforeEach(async () => {
        createComponent({
          messages: [buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' })],
        });
        await waitForPromises();
      });

      it('expands the bar', () => {
        expect(findCollapse().props('visible')).toBe(true);
        expect(findBar().isVisible()).toBe(true);
      });
    });

    describe('when the last workflow reaches a terminal status', () => {
      beforeEach(async () => {
        createComponent({
          messages: [buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' })],
          handler: jest
            .fn()
            .mockResolvedValue(buildWorkflowsByIdsResponse([{ id: 326, status: 'FINISHED' }])),
        });
        await waitForPromises();
      });

      it('collapses the bar again', () => {
        expect(findPills()).toHaveLength(0);
        expect(findCollapse().props('visible')).toBe(false);
      });
    });
  });

  describe('height-change event', () => {
    it('does not emit height-change on mount', () => {
      createComponent();

      expect(wrapper.emitted('height-change')).toBeUndefined();
    });

    // jsdom never fires `transitionend`, so drive the collapse hooks directly.
    describe.each(['shown', 'hidden'])('when the collapse finishes transitioning (%s)', (event) => {
      beforeEach(() => {
        createComponent();

        findCollapse().vm.$emit(event);
      });

      it('emits height-change', () => {
        expect(wrapper.emitted('height-change')).toHaveLength(1);
      });
    });
  });

  describe('click handling', () => {
    it('emits SHOW_SESSION via eventHub when a pill is clicked', async () => {
      const emitSpy = jest.spyOn(eventHub, '$emit');
      createComponent({
        messages: [buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' })],
      });
      await waitForPromises();

      findPills().at(0).vm.$emit('click', 326);

      expect(emitSpy).toHaveBeenCalledWith(SHOW_SESSION, { id: 326 });
    });
  });

  describe('canceling a session', () => {
    const cancelFirstPill = async () => {
      createComponent({
        messages: [buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' })],
      });
      await waitForPromises();

      findPills().at(0).vm.$emit('cancel', 326);
      await nextTick();
    };

    it('keeps the confirmation modal hidden until a pill asks to cancel', async () => {
      createComponent({
        messages: [buildStartFlowMessage({ workflowId: 326, flowName: 'fix_pipeline/v1' })],
      });
      await waitForPromises();

      expect(findCancelationModal().props('visible')).toBe(false);
      expect(cancelWorkflow).not.toHaveBeenCalled();
    });

    it('opens the confirmation modal without canceling yet', async () => {
      await cancelFirstPill();

      expect(findCancelationModal().props('visible')).toBe(true);
      expect(cancelWorkflow).not.toHaveBeenCalled();
    });

    it('cancels nothing when the modal is dismissed', async () => {
      await cancelFirstPill();

      findCancelationModal().vm.$emit('hide');
      await nextTick();

      expect(findCancelationModal().props('visible')).toBe(false);
      expect(cancelWorkflow).not.toHaveBeenCalled();
    });

    describe('when the cancelation is confirmed', () => {
      beforeEach(async () => {
        cancelWorkflow.mockResolvedValue({});
        await cancelFirstPill();

        findCancelationModal().vm.$emit('confirm');
        await waitForPromises();
      });

      it('cancels the workflow and closes the modal', () => {
        expect(cancelWorkflow).toHaveBeenCalledWith(326);
        expect(findCancelationModal().props('visible')).toBe(false);
      });

      it('confirms success to the user', () => {
        expect(createAlert).toHaveBeenCalledWith({
          message: 'Session has been canceled successfully.',
          variant: 'success',
        });
      });

      it('refetches so the pill disappears without waiting for the next poll', () => {
        expect(workflowsByIdsHandler).toHaveBeenCalledTimes(2);
      });
    });

    describe('when the cancelation fails', () => {
      const error = new Error('Request failed');

      beforeEach(async () => {
        cancelWorkflow.mockRejectedValue(error);
        await cancelFirstPill();

        findCancelationModal().vm.$emit('confirm');
        await waitForPromises();
      });

      it('reports the failure to the user', () => {
        expect(createAlert).toHaveBeenCalledWith({
          message: 'Failed to cancel session. Please try again.',
          captureError: true,
          error,
          variant: 'danger',
        });
      });

      it('closes the modal and leaves the pill in place', () => {
        expect(findCancelationModal().props('visible')).toBe(false);
        expect(findPills()).toHaveLength(1);
      });
    });

    it('surfaces the server-provided message when the request fails', async () => {
      const error = { response: { data: { message: 'Can not update workflow' } } };
      cancelWorkflow.mockRejectedValue(error);
      await cancelFirstPill();

      findCancelationModal().vm.$emit('confirm');
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith({
        message: 'Can not update workflow',
        captureError: true,
        error,
        variant: 'danger',
      });
    });
  });

  describe('overflow dropdown', () => {
    const messagesFor = (ids) =>
      ids.map((id) => buildStartFlowMessage({ workflowId: id, flowName: `flow_${id}` }));

    const responseFor = (ids) =>
      buildWorkflowsByIdsResponse(
        ids.map((id) => ({ id, status: 'RUNNING', title: `Session ${id}` })),
      );

    it('renders no overflow dropdown when all pills fit', async () => {
      createComponent({
        messages: messagesFor([1, 2]),
        handler: jest.fn().mockResolvedValue(responseFor([1, 2])),
      });
      await waitForPromises();

      expect(findOverflow().exists()).toBe(false);
    });

    it('routes overflowed pills into the dropdown when container is constrained', async () => {
      // Stub getBoundingClientRect so each rendered pill reports ~120px and the
      // bar's measurePills() drives visibleCount through the real code path.
      const boundingRectSpy = jest
        .spyOn(Element.prototype, 'getBoundingClientRect')
        .mockReturnValue({ width: 120 });

      createComponent({
        messages: messagesFor([1, 2, 3]),
        handler: jest.fn().mockResolvedValue(responseFor([1, 2, 3])),
      });
      await waitForPromises();
      await nextTick();

      // Simulate the ResizeObserver firing with a constrained container width.
      wrapper.vm.handleResize({ contentRect: { width: 200 } });
      await nextTick();

      expect(findOverflow().exists()).toBe(true);
      expect(
        findOverflow()
          .props('items')
          .map(({ text }) => text),
      ).toEqual(['Session 2', 'Session 3']);

      boundingRectSpy.mockRestore();
    });
  });
});
