import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import ImplementationWidget from 'ee/work_items/components/implementation_widget/implementation_widget.vue';
import WorkItemReadinessScore from 'ee/work_items/components/implementation_widget/work_item_readiness_score.vue';
import WorkItemWorkplan from 'ee/work_items/components/implementation_widget/work_item_workplan.vue';
import workItemAgentPlanQuery from 'ee/work_items/graphql/work_item_agent_plan.query.graphql';
import workItemAgentPlanUpdatedSubscription from 'ee/work_items/graphql/work_item_agent_plan.subscription.graphql';
import { buildAgentPlanWidgetMock } from 'ee_jest/work_items/mock_data';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { WORKPLAN_PANEL } from '~/work_items/constants';
import { ACTIVE_RUN_POLL_INTERVAL_MS } from 'ee/work_items/components/implementation_widget/constants';

jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);

describe('ImplementationWidget', () => {
  let wrapper;

  const mockWorkItemId = 'gid://gitlab/WorkItem/1';
  const workItem = { id: mockWorkItemId };

  const workplanResponse = ({
    content = 'a plan',
    contentHtml = '<p>a plan</p>',
    aiPlanningEnabled = true,
    readinessScore = null,
    generationStatus = null,
    useWorkItemFeatures = false,
  } = {}) => {
    const workplan = buildAgentPlanWidgetMock({
      content,
      contentHtml,
      aiPlanningEnabled,
      readinessScore,
      generationStatus,
    });

    return {
      data: {
        workItem: {
          __typename: 'WorkItem',
          id: mockWorkItemId,
          iid: '1',
          ...(useWorkItemFeatures
            ? { features: { __typename: 'WorkItemFeatures', agentPlan: workplan } }
            : { widgets: [workplan] }),
        },
      },
    };
  };

  const createComponent = ({
    props = {},
    glFeatures = {},
    queryHandler = jest.fn().mockResolvedValue(workplanResponse()),
    subscriptionHandler = jest.fn().mockResolvedValue({ data: null }),
  } = {}) => {
    wrapper = shallowMountExtended(ImplementationWidget, {
      apolloProvider: createMockApollo([
        [workItemAgentPlanQuery, queryHandler],
        [workItemAgentPlanUpdatedSubscription, subscriptionHandler],
      ]),
      propsData: { workItem, ...props },
      provide: { glFeatures },
    });
  };

  const findReadinessScore = () => wrapper.findComponent(WorkItemReadinessScore);
  const findWorkplan = () => wrapper.findComponent(WorkItemWorkplan);

  it('always renders the work plan child', () => {
    createComponent();
    expect(findWorkplan().exists()).toBe(true);
  });

  it('forwards props to the work plan child', () => {
    createComponent({
      props: { canUpdate: true, workItemWebUrl: '/url', isInDrawer: true, isPanelOpen: true },
    });
    expect(findWorkplan().props()).toMatchObject({
      workItem,
      canUpdate: true,
      workItemWebUrl: '/url',
      isInDrawer: true,
      isPanelOpen: true,
    });
  });

  it('re-emits request-panel from the work plan child', () => {
    createComponent();
    findWorkplan().vm.$emit('request-panel', WORKPLAN_PANEL);
    expect(wrapper.emitted('request-panel')).toEqual([[WORKPLAN_PANEL]]);
  });

  describe('agent plan query', () => {
    it('marks the work plan as loading until the query settles', async () => {
      createComponent();

      expect(findWorkplan().props('isLoading')).toBe(true);

      await waitForPromises();

      expect(findWorkplan().props('isLoading')).toBe(false);
    });

    it('passes the queried plan down to the work plan child', async () => {
      createComponent();
      await waitForPromises();

      expect(findWorkplan().props('workplan')).toMatchObject({
        content: 'a plan',
        contentHtml: '<p>a plan</p>',
      });
    });

    describe('when the work item has no id yet', () => {
      const queryHandler = jest.fn().mockResolvedValue(workplanResponse());

      beforeEach(async () => {
        createComponent({ props: { workItem: {} }, queryHandler });
        await waitForPromises();
      });

      it('does not query', () => {
        expect(queryHandler).not.toHaveBeenCalled();
      });
    });

    describe('when workItemFeaturesField is enabled', () => {
      const queryHandler = jest
        .fn()
        .mockResolvedValue(workplanResponse({ useWorkItemFeatures: true }));

      beforeEach(async () => {
        createComponent({ queryHandler, glFeatures: { workItemFeaturesField: true } });
        await waitForPromises();
      });

      it('reads the plan from the features field', () => {
        expect(queryHandler).toHaveBeenCalledWith(
          expect.objectContaining({ useWorkItemFeatures: true }),
        );
        expect(findWorkplan().props('workplan')).toMatchObject({
          content: 'a plan',
          contentHtml: '<p>a plan</p>',
        });
      });
    });

    describe('when the query errors', () => {
      beforeEach(async () => {
        createComponent({ queryHandler: jest.fn().mockRejectedValue(new Error('boom')) });
        await waitForPromises();
      });

      it('reports to Sentry and leaves the plan empty', () => {
        expect(Sentry.captureException).toHaveBeenCalledWith(expect.any(Error));
        expect(findWorkplan().props('workplan')).toBe(null);
      });
    });
  });

  describe('readiness score', () => {
    describe('when the workplanScore feature flag is disabled', () => {
      const queryHandler = jest.fn().mockResolvedValue(workplanResponse({ readinessScore: 85 }));

      beforeEach(async () => {
        createComponent({ glFeatures: { workplanScore: false }, queryHandler });
        await waitForPromises();
      });

      it('does not render the score', () => {
        expect(findReadinessScore().exists()).toBe(false);
      });

      it('does not request the score field', () => {
        expect(queryHandler).toHaveBeenCalledWith(
          expect.objectContaining({ includeReadinessScore: false }),
        );
      });
    });

    describe('when the workplanScore feature flag is enabled', () => {
      const queryHandler = jest.fn().mockResolvedValue(workplanResponse({ readinessScore: 85 }));

      beforeEach(async () => {
        createComponent({ glFeatures: { workplanScore: true }, queryHandler });
        await waitForPromises();
      });

      it('requests the score field', () => {
        expect(queryHandler).toHaveBeenCalledWith(
          expect.objectContaining({ includeReadinessScore: true }),
        );
      });

      it('renders the score', () => {
        expect(findReadinessScore().exists()).toBe(true);
      });

      it('passes the queried readiness score to the score component', () => {
        expect(findReadinessScore().props('score')).toBe(85);
      });
    });

    describe('when the flag is enabled but the query is still loading', () => {
      const queryHandler = jest.fn().mockResolvedValue(workplanResponse({ readinessScore: 85 }));

      it('does not render the score until the query settles', async () => {
        createComponent({ glFeatures: { workplanScore: true }, queryHandler });

        expect(findReadinessScore().exists()).toBe(false);

        await waitForPromises();

        expect(findReadinessScore().props('score')).toBe(85);
      });
    });

    describe('when the flag is enabled but the score is not available yet', () => {
      beforeEach(async () => {
        createComponent({
          glFeatures: { workplanScore: true },
          queryHandler: jest.fn().mockResolvedValue(workplanResponse({ readinessScore: null })),
        });
        await waitForPromises();
      });

      it('does not render the score', () => {
        expect(findReadinessScore().exists()).toBe(false);
      });
    });

    describe('when the flag is enabled and the score is zero', () => {
      beforeEach(async () => {
        createComponent({
          glFeatures: { workplanScore: true },
          queryHandler: jest.fn().mockResolvedValue(workplanResponse({ readinessScore: 0 })),
        });
        await waitForPromises();
      });

      it('renders the score', () => {
        expect(findReadinessScore().props('score')).toBe(0);
      });
    });
  });
  describe('polling while a run is active', () => {
    // A subscription that never emits, so the poll is the only thing re-reading the plan.
    const mountWithStatus = async (generationStatus) => {
      const queryHandler = jest.fn().mockResolvedValue(workplanResponse({ generationStatus }));
      createComponent({ queryHandler, subscriptionHandler: jest.fn(() => new Promise(() => {})) });
      await waitForPromises();

      return queryHandler;
    };

    const advanceWorkplanPollTimer = async (intervals = 1) => {
      jest.advanceTimersByTime(ACTIVE_RUN_POLL_INTERVAL_MS * intervals);
      await waitForPromises();
    };

    beforeEach(() => {
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it.each(['GENERATING', 'NEEDS_INPUT'])(
      're-reads the plan while the run is %s, since the terminal status push can go missing',
      async (generationStatus) => {
        const queryHandler = await mountWithStatus(generationStatus);

        expect(queryHandler).toHaveBeenCalledTimes(1);

        await advanceWorkplanPollTimer();

        expect(queryHandler).toHaveBeenCalledTimes(2);
      },
    );

    it.each(['COMPLETED', 'FAILED', null])(
      'stops once the run has settled on %s',
      async (generationStatus) => {
        const queryHandler = await mountWithStatus(generationStatus);

        await advanceWorkplanPollTimer(3);

        expect(queryHandler).toHaveBeenCalledTimes(1);
      },
    );

    // The refetch after a mutation is a single shot, so a stale read there would
    // otherwise leave a running flow with nothing watching it.
    it('polls while an action is in flight, even though the run still reads as settled', async () => {
      const queryHandler = await mountWithStatus('COMPLETED');
      await advanceWorkplanPollTimer();

      expect(queryHandler).toHaveBeenCalledTimes(1);

      findWorkplan().vm.$emit('run-active', true);
      await waitForPromises();
      await advanceWorkplanPollTimer();

      expect(queryHandler).toHaveBeenCalledTimes(2);
    });
  });
});
