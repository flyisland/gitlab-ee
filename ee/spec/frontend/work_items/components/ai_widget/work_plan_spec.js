import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import WorkPlan from 'ee/work_items/components/ai_widget/work_plan.vue';
import WorkPlanInlineRow from 'ee/work_items/components/ai_widget/work_plan_inline_row.vue';
import WorkPlanPanel from 'ee/work_items/components/ai_widget/work_plan_panel.vue';
import WorkplanEmptyStateHeader from 'ee/work_items/components/ai_widget/workplan_empty_state_header.vue';
import {
  eventHub,
  DUO_CHAT_REGISTER_EMPTY_STATE_HEADER,
  OPEN_AGENT_PLAN_PANEL,
  GENERATE_AGENT_PLAN,
} from 'ee/ai/events/panel';
import updateWorkItemAgentPlanMutation from 'ee/work_items/graphql/update_work_item_agent_plan.mutation.graphql';
import workItemGenerateWorkplanMutation from 'ee/work_items/graphql/work_item_generate_workplan.mutation.graphql';
import { writeAgentPlanToCache } from 'ee/work_items/graphql/cache_utils';
import { createAlert } from '~/alert';
import { confirmAction } from '~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal';
import * as urlUtility from '~/lib/utils/url_utility';
import { getDraft, updateDraft, clearDraft } from '~/lib/utils/autosave';
import {
  buildAgentPlanWidgetMock,
  buildWorkplanFlowMutationResponse,
  workItemResponseFactory,
} from 'ee_jest/work_items/mock_data';

jest.mock('ee/work_items/graphql/cache_utils');
jest.mock('~/lib/utils/autosave');
jest.mock('~/alert');
jest.mock('~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal', () => ({
  confirmAction: jest.fn(),
}));

Vue.use(VueApollo);

describe('WorkPlan component (orchestrator)', () => {
  let wrapper;
  let apolloProvider;

  const mockWorkItemId = 'gid://gitlab/WorkItem/1';
  const mockWorkItemWebUrl = 'http://gdk.test/gitlab-org/gitlab/-/issues/1';
  const planStorageKey = `work-plan-draft-${mockWorkItemId}`;

  const buildWorkItem = ({ workItemId = mockWorkItemId, workItemType = 'Epic' } = {}) => {
    const base = workItemResponseFactory({ id: workItemId }).data.workItem;
    return {
      ...base,
      workItemType: { ...base.workItemType, name: workItemType },
    };
  };

  const paragraphHtml = (text) => {
    const p = document.createElement('p');
    p.textContent = text;
    return p.outerHTML;
  };

  const generateHandlerFor = (options) =>
    jest
      .fn()
      .mockResolvedValue(buildWorkplanFlowMutationResponse('workItemGenerateWorkplan', options));

  const buildAgentPlan = ({
    content = '',
    contentHtml = null,
    aiPlanningEnabled = true,
    readinessScore = null,
    generationStatus = null,
  } = {}) =>
    buildAgentPlanWidgetMock({
      content,
      contentHtml: contentHtml ?? (content ? paragraphHtml(content) : ''),
      aiPlanningEnabled,
      readinessScore,
      generationStatus,
    });

  const successMutationHandler = jest.fn().mockImplementation(({ input, useWorkItemFeatures }) =>
    Promise.resolve({
      data: {
        workItemUpdate: {
          __typename: 'WorkItemUpdatePayload',
          workItem: {
            __typename: 'WorkItem',
            id: mockWorkItemId,
            iid: '1',
            ...(useWorkItemFeatures
              ? {
                  features: {
                    __typename: 'WorkItemFeatures',
                    agentPlan: buildAgentPlan({ content: input.agentPlanWidget.content }),
                  },
                }
              : { widgets: [buildAgentPlan({ content: input.agentPlanWidget.content })] }),
          },
          errors: [],
        },
      },
    }),
  );

  const pushAgentPlanContent = (content) =>
    wrapper.setProps({ agentPlan: buildAgentPlan({ content }) });

  const createComponent = ({
    canUpdate = true,
    content = '',
    agentPlan = buildAgentPlan({ content }),
    isLoading = false,
    workItem = buildWorkItem(),
    workItemWebUrl = mockWorkItemWebUrl,
    isInDrawer = false,
    isPanelOpen = false,
    mutationHandler = successMutationHandler,
    generateHandler = generateHandlerFor(),
    duoRemoteFlowsAvailability = false,
    fullPath = 'group/project',
    glFeatures = {},
  } = {}) => {
    apolloProvider = createMockApollo([
      [updateWorkItemAgentPlanMutation, mutationHandler],
      [workItemGenerateWorkplanMutation, generateHandler],
    ]);
    wrapper = shallowMountExtended(WorkPlan, {
      apolloProvider,
      propsData: {
        workItem,
        canUpdate,
        workItemWebUrl,
        isInDrawer,
        isPanelOpen,
        agentPlan,
        isLoading,
      },
      provide: { fullPath, duoRemoteFlowsAvailability, glFeatures },
    });
  };

  const findInlineRow = () => wrapper.findComponent(WorkPlanInlineRow);
  const findPanel = () => wrapper.findComponent(WorkPlanPanel);

  const setSearch = (search) => {
    Object.defineProperty(window, 'location', {
      configurable: true,
      value: { ...window.location, search },
    });
  };

  const triggerPopstate = () => window.dispatchEvent(new PopStateEvent('popstate'));

  beforeEach(() => {
    getDraft.mockReturnValue(null);
    successMutationHandler.mockClear();
    confirmAction.mockReset();
  });

  describe('inline row wiring', () => {
    describe('when there is no saved content', () => {
      beforeEach(() => {
        createComponent({ content: '' });
      });

      it('passes hasContent=false', () => {
        expect(findInlineRow().props('hasContent')).toBe(false);
      });
    });

    describe('when content is set on the work item', () => {
      beforeEach(async () => {
        createComponent({ content: 'some plan' });
        await waitForPromises();
      });

      it('passes hasContent=true', () => {
        expect(findInlineRow().props('hasContent')).toBe(true);
      });
    });

    describe('when canUpdate is false', () => {
      beforeEach(() => {
        createComponent({ canUpdate: false });
      });

      it('forwards canUpdate to the inline row', () => {
        expect(findInlineRow().props('canUpdate')).toBe(false);
      });
    });
  });

  describe('panel wiring', () => {
    describe('when the panel is open', () => {
      beforeEach(() => {
        createComponent({ isPanelOpen: true });
      });

      it('passes isPanelOpen down as the panel open prop', () => {
        expect(findPanel().props('open')).toBe(true);
      });
    });

    describe('when the parent provides saved content', () => {
      beforeEach(async () => {
        createComponent({ content: 'plan via widgets' });
        await waitForPromises();
      });

      it('passes the queried content as savedContent', () => {
        expect(findPanel().props('savedContent')).toBe('plan via widgets');
      });

      it('passes the queried contentHtml as savedContentHtml', () => {
        expect(findPanel().props('savedContentHtml')).toBe(paragraphHtml('plan via widgets'));
      });
    });

    describe('cache write on save', () => {
      const lastCacheWrite = () => writeAgentPlanToCache.mock.calls.at(-1)[0];

      const save = async (options) => {
        createComponent(options);
        await findPanel().vm.$emit('save', 'new plan');
        await waitForPromises();
      };

      describe('when workplanScore is enabled', () => {
        beforeEach(() =>
          save({
            agentPlan: buildAgentPlan({ content: 'old plan', readinessScore: 72 }),
            glFeatures: { workplanScore: true },
          }),
        );

        it('writes the new content and carries the existing plan values forward', () => {
          expect(lastCacheWrite()).toMatchObject({
            workItemId: mockWorkItemId,
            workItemIid: '1',
            content: 'new plan',
            contentHtml: '<p>new plan</p>',
            aiPlanningEnabled: true,
            readinessScore: 72,
            includeReadinessScore: true,
          });
        });
      });

      describe('when workplanScore is disabled', () => {
        beforeEach(() => save({ agentPlan: buildAgentPlan({ content: 'old plan' }) }));

        it('leaves the readiness score out of the write', () => {
          expect(lastCacheWrite()).toMatchObject({
            content: 'new plan',
            contentHtml: '<p>new plan</p>',
            readinessScore: null,
            includeReadinessScore: false,
          });
        });
      });

      describe('when workItemFeaturesField is enabled', () => {
        beforeEach(() =>
          save({
            agentPlan: buildAgentPlan({ content: 'old plan' }),
            glFeatures: { workItemFeaturesField: true },
          }),
        );

        it('writes the rendered HTML returned through features', () => {
          expect(lastCacheWrite()).toMatchObject({
            content: 'new plan',
            contentHtml: '<p>new plan</p>',
            aiPlanningEnabled: true,
            useWorkItemFeatures: true,
          });
        });
      });
    });

    describe('when rendered with defaults', () => {
      beforeEach(() => {
        createComponent({ canUpdate: true });
      });

      it('forwards canUpdate to the panel', () => {
        expect(findPanel().props('canUpdate')).toBe(true);
      });

      it('passes the work item id to the panel', () => {
        expect(findPanel().props('workItemId')).toBe(mockWorkItemId);
      });
    });
  });

  describe('openPanel', () => {
    describe('when the inline row opens', () => {
      beforeEach(async () => {
        createComponent({ content: 'existing' });
        await findInlineRow().vm.$emit('open');
      });

      it('emits request-panel with the agent-plan key', () => {
        expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
      });
    });

    describe('when opening with no content and the user can update', () => {
      beforeEach(async () => {
        createComponent({ content: '', canUpdate: true });
        await findInlineRow().vm.$emit('open');
      });

      it('opens in view mode (empty state)', () => {
        expect(findPanel().props('isEditing')).toBe(false);
      });

      describe('when the panel empty state requests edit ("Create manually")', () => {
        beforeEach(async () => {
          await findPanel().vm.$emit('start-edit');
        });

        it('enters edit mode', () => {
          expect(findPanel().props('isEditing')).toBe(true);
        });
      });
    });

    describe('when opening with existing content', () => {
      beforeEach(async () => {
        createComponent({ content: 'existing', canUpdate: true });
        await findInlineRow().vm.$emit('open');
      });

      it('stays in view mode', () => {
        expect(findPanel().props('isEditing')).toBe(false);
      });
    });

    describe('when the user cannot update', () => {
      beforeEach(async () => {
        createComponent({ content: '', canUpdate: false });
        await findInlineRow().vm.$emit('open');
      });

      it('stays in view mode', () => {
        expect(findPanel().props('isEditing')).toBe(false);
      });
    });

    describe('when a leftover draft exists', () => {
      beforeEach(async () => {
        getDraft.mockImplementation((key) => (key === planStorageKey ? 'half-typed' : null));
        createComponent({ content: 'existing', canUpdate: true });
        await findInlineRow().vm.$emit('open');
      });

      it('opens in view mode (View workplan must not force edit)', () => {
        expect(findPanel().props('isEditing')).toBe(false);
      });
    });

    describe('when the inline row re-emits open while already open (toggle)', () => {
      let updateHistorySpy;
      let originalSearch;

      beforeEach(async () => {
        originalSearch = window.location.search;
        setSearch('?show=workplan');
        updateHistorySpy = jest.spyOn(urlUtility, 'updateHistory').mockImplementation(() => {});
        createComponent({ content: 'existing', isPanelOpen: true });
        await findInlineRow().vm.$emit('open');
      });

      afterEach(() => {
        setSearch(originalSearch);
        updateHistorySpy.mockRestore();
      });

      it('closes the panel', () => {
        expect(wrapper.emitted('request-panel')).toEqual([[null]]);
      });

      it('strips the workplan params from the URL', () => {
        expect(updateHistorySpy).toHaveBeenCalledTimes(1);
        expect(updateHistorySpy.mock.calls[0][0].url).not.toMatch(/show=/);
      });
    });

    describe('when the inline row emits "create-manually"', () => {
      beforeEach(async () => {
        createComponent({ content: '', canUpdate: true });
        await findInlineRow().vm.$emit('create-manually');
      });

      it('opens the panel directly in edit mode', () => {
        expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
        expect(findPanel().props('isEditing')).toBe(true);
      });
    });

    describe('when rendered inside a drawer', () => {
      let visitUrlSpy;

      beforeEach(() => {
        visitUrlSpy = jest.spyOn(urlUtility, 'visitUrl').mockImplementation(() => {});
        createComponent({
          isInDrawer: true,
          workItemWebUrl: '/group/project/-/work_items/42',
        });
      });

      afterEach(() => {
        visitUrlSpy.mockRestore();
      });

      describe('when the inline row opens', () => {
        beforeEach(async () => {
          await findInlineRow().vm.$emit('open');
        });

        it('navigates to the full work-item page with ?show=workplan', () => {
          expect(visitUrlSpy).toHaveBeenCalledWith('/group/project/-/work_items/42?show=workplan');
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });

      describe('when creating manually', () => {
        beforeEach(async () => {
          await findInlineRow().vm.$emit('create-manually');
        });

        it('navigates to the full page with the edit deep-link so the state survives the jump', () => {
          expect(visitUrlSpy).toHaveBeenCalledWith(
            '/group/project/-/work_items/42?show=workplan&workplan_state=edit',
          );
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });
    });

    describe('when the empty-state header requests the panel via the event hub', () => {
      beforeEach(async () => {
        createComponent({ content: 'existing' });
        eventHub.$emit(OPEN_AGENT_PLAN_PANEL);
        await waitForPromises();
      });

      it('opens the panel immediately', () => {
        expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
      });
    });
  });

  describe('Duo "Generate" path', () => {
    describe('open-chat-request (before chat opens)', () => {
      beforeEach(async () => {
        createComponent({ content: '', canUpdate: true });
        await waitForPromises();
      });

      describe('when the chat opens', () => {
        beforeEach(async () => {
          await findInlineRow().vm.$emit('open-chat-request');
        });

        it('does not open the empty panel on the Generate click itself', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });

        describe('and the generated plan is saved', () => {
          beforeEach(async () => {
            pushAgentPlanContent('generated plan');
            await waitForPromises();
          });

          it('opens the panel in view mode', () => {
            expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
            expect(findPanel().props('isEditing')).toBe(false);
          });
        });
      });

      describe('when content arrives without a prior Generate click', () => {
        beforeEach(async () => {
          pushAgentPlanContent('generated plan');
          await waitForPromises();
        });

        it('does not open the panel', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });

      describe('when the panel is already open', () => {
        beforeEach(async () => {
          createComponent({ content: '', canUpdate: true, isPanelOpen: true });
          await waitForPromises();
          await findInlineRow().vm.$emit('open-chat-request');
          pushAgentPlanContent('generated plan');
          await waitForPromises();
        });

        it('does not re-open the panel', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });

      describe('when in a drawer', () => {
        beforeEach(async () => {
          createComponent({ content: '', canUpdate: true, isInDrawer: true, isPanelOpen: false });
          await waitForPromises();
          await findInlineRow().vm.$emit('open-chat-request');
          pushAgentPlanContent('generated plan');
          await waitForPromises();
        });

        it('keeps the user in place by not opening the panel', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });
    });

    describe('when the empty-state header requests generation via the event hub', () => {
      let updateHistorySpy;

      beforeEach(async () => {
        updateHistorySpy = jest.spyOn(urlUtility, 'updateHistory').mockImplementation(() => {});
        createComponent({ content: '', canUpdate: true });
        await waitForPromises();
      });

      afterEach(() => {
        updateHistorySpy.mockRestore();
      });

      describe('when generation is requested but nothing is saved yet', () => {
        beforeEach(async () => {
          eventHub.$emit(GENERATE_AGENT_PLAN);
          await waitForPromises();
        });

        it('does not open the empty panel on the Generate click itself', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });

      describe('when the generated plan is saved', () => {
        beforeEach(async () => {
          eventHub.$emit(GENERATE_AGENT_PLAN);
          pushAgentPlanContent('generated plan');
          await waitForPromises();
        });

        it('opens the panel', () => {
          expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
        });

        it('writes the workplan URL so the panel survives a refresh or shared link', () => {
          expect(updateHistorySpy.mock.calls[0][0].url).toMatch(/show=workplan/);
        });
      });
    });

    describe('open-chat-completed (after chat opens)', () => {
      describe('when the user was editing', () => {
        beforeEach(async () => {
          createComponent({ content: 'existing', canUpdate: true, isPanelOpen: true });
          await findPanel().vm.$emit('start-edit');
        });

        it('starts in edit mode before the chat completes', () => {
          expect(findPanel().props('isEditing')).toBe(true);
        });

        describe('once the chat completes', () => {
          beforeEach(async () => {
            await findInlineRow().vm.$emit('open-chat-completed');
          });

          it('cancels editing', () => {
            expect(findPanel().props('isEditing')).toBe(false);
          });
        });
      });

      describe('when not editing', () => {
        beforeEach(async () => {
          createComponent({ content: 'existing', canUpdate: true, isPanelOpen: true });
          await findInlineRow().vm.$emit('open-chat-completed');
        });

        it('is a no-op', () => {
          expect(findPanel().props('isEditing')).toBe(false);
        });
      });
    });
  });

  describe('closePanel', () => {
    describe('when the panel emits close', () => {
      let updateHistorySpy;
      let originalSearch;

      beforeEach(async () => {
        originalSearch = window.location.search;
        setSearch('?show=workplan&workplan_state=edit');
        updateHistorySpy = jest.spyOn(urlUtility, 'updateHistory').mockImplementation(() => {});
        createComponent({ isPanelOpen: true });
        await findPanel().vm.$emit('close');
      });

      afterEach(() => {
        setSearch(originalSearch);
        updateHistorySpy.mockRestore();
      });

      it('emits request-panel null', () => {
        expect(wrapper.emitted('request-panel')).toEqual([[null]]);
      });

      it('strips both workplan params from the URL', () => {
        expect(updateHistorySpy).toHaveBeenCalledTimes(1);
        expect(updateHistorySpy.mock.calls[0][0].url).not.toMatch(/show=/);
        expect(updateHistorySpy.mock.calls[0][0].url).not.toMatch(/workplan_state/);
      });

      it('resets editing so a later reopen starts in view mode', () => {
        expect(findPanel().props('isEditing')).toBe(false);
      });
    });
  });

  describe('URL sync', () => {
    let originalSearch;

    beforeEach(() => {
      originalSearch = window.location.search;
    });

    afterEach(() => {
      setSearch(originalSearch);
    });

    describe('on load', () => {
      describe('when ?show=workplan is present', () => {
        beforeEach(() => {
          setSearch('?show=workplan');
          createComponent({ isPanelOpen: false });
        });

        it('opens the panel', () => {
          expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
        });

        it('opens in view mode', () => {
          expect(findPanel().props('isEditing')).toBe(false);
        });
      });

      describe('when the edit deep-link is present', () => {
        beforeEach(() => {
          setSearch('?show=workplan&workplan_state=edit');
          createComponent({ isPanelOpen: false });
        });

        it('opens the panel directly in edit mode', () => {
          expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
          expect(findPanel().props('isEditing')).toBe(true);
        });
      });

      describe('when the param is absent', () => {
        beforeEach(() => {
          setSearch('');
          createComponent({ isPanelOpen: false });
        });

        it('does not open the panel', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });
    });

    describe('on popstate', () => {
      describe('when the param is (re)added and the panel is closed', () => {
        beforeEach(() => {
          setSearch('');
          createComponent({ isPanelOpen: false });

          setSearch('?show=workplan');
          triggerPopstate();
        });

        it('re-opens the panel', () => {
          expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
        });
      });

      describe('when the param is removed and the panel is open', () => {
        beforeEach(() => {
          setSearch('?show=workplan');
          createComponent({ isPanelOpen: true });

          setSearch('');
          triggerPopstate();
        });

        it('closes the panel', () => {
          expect(wrapper.emitted('request-panel')).toEqual([[null]]);
        });
      });

      describe('when the panel state already matches the URL', () => {
        beforeEach(() => {
          setSearch('?show=workplan');
          createComponent({ isPanelOpen: true });

          triggerPopstate();
        });

        it('does not re-emit', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });

      describe('when rendered inside a drawer', () => {
        beforeEach(() => {
          setSearch('?show=workplan');
          createComponent({ isInDrawer: true, isPanelOpen: false });

          triggerPopstate();
        });

        it('ignores popstate', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });

      describe('when the component has been destroyed', () => {
        beforeEach(() => {
          setSearch('');
          createComponent({ isPanelOpen: false });
          wrapper.destroy();

          setSearch('?show=workplan');
          triggerPopstate();
        });

        it('stops listening to popstate', () => {
          expect(wrapper.emitted('request-panel')).toBeUndefined();
        });
      });
    });
  });

  describe('while the parent reports the agent plan as loading', () => {
    beforeEach(() => {
      createComponent({ isLoading: true, agentPlan: null });
    });

    it('marks the inline row and panel as loading', () => {
      expect(findInlineRow().props('isLoading')).toBe(true);
      expect(findPanel().props('isLoading')).toBe(true);
    });

    it('reports no saved content until the plan arrives', () => {
      expect(findInlineRow().props('hasContent')).toBe(false);
    });
  });

  describe('handleSave', () => {
    describe('when the save succeeds', () => {
      beforeEach(() => {
        createComponent({ isPanelOpen: true });
      });

      describe('with fresh content', () => {
        beforeEach(async () => {
          await findPanel().vm.$emit('save', 'fresh plan');
          await waitForPromises();
        });

        it('sends the new content to the mutation', () => {
          expect(successMutationHandler).toHaveBeenCalledWith(
            expect.objectContaining({
              input: { id: mockWorkItemId, agentPlanWidget: { content: 'fresh plan' } },
            }),
          );
        });

        it('writes the content and contentHtml from the mutation response to the cache', () => {
          expect(writeAgentPlanToCache).toHaveBeenCalledWith(
            expect.objectContaining({
              content: 'fresh plan',
              contentHtml: paragraphHtml('fresh plan'),
            }),
          );
        });
      });

      describe('with persisted content', () => {
        beforeEach(async () => {
          await findPanel().vm.$emit('save', 'persisted');
          await waitForPromises();
        });

        it('clears the draft on successful save', () => {
          expect(clearDraft).toHaveBeenCalledWith(planStorageKey);
        });
      });
    });

    describe('when the save fails', () => {
      const failingHandler = jest
        .fn()
        .mockResolvedValue({ data: { workItemUpdate: { errors: ['boom'] } } });

      describe('with no saved content', () => {
        beforeEach(async () => {
          createComponent({ isPanelOpen: true, mutationHandler: failingHandler });
          await findPanel().vm.$emit('save', 'broken');
          await waitForPromises();
        });

        it('surfaces a mutation error via createAlert and Sentry', () => {
          expect(createAlert).toHaveBeenCalled();
        });
      });

      describe('and content was already saved', () => {
        const typedFailingHandler = jest.fn().mockResolvedValue({
          data: { workItemUpdate: { __typename: 'WorkItemUpdatePayload', errors: ['boom'] } },
        });

        beforeEach(async () => {
          createComponent({
            content: 'saved plan',
            isPanelOpen: true,
            mutationHandler: typedFailingHandler,
          });
          await waitForPromises();

          await findPanel().vm.$emit('save', 'unsaved edit');
          await waitForPromises();
        });

        it('does not write the attempted content to the cache', () => {
          expect(findPanel().props('savedContent')).toBe('saved plan');
          expect(findPanel().props('savedContentHtml')).toBe(paragraphHtml('saved plan'));
        });
      });
    });
  });

  describe('handleDelete', () => {
    describe('when confirmed', () => {
      beforeEach(async () => {
        confirmAction.mockResolvedValueOnce(true);
        createComponent({ content: 'old plan', isPanelOpen: true });
        await findPanel().vm.$emit('delete');
        await waitForPromises();
      });

      it('clears the saved plan via the mutation', () => {
        expect(successMutationHandler).toHaveBeenCalledWith(
          expect.objectContaining({
            input: { id: mockWorkItemId, agentPlanWidget: { content: '' } },
          }),
        );
      });

      it('clears the draft', () => {
        expect(clearDraft).toHaveBeenCalledWith(planStorageKey);
      });
    });

    describe('when the confirm modal is dismissed', () => {
      beforeEach(async () => {
        confirmAction.mockResolvedValueOnce(false);
        createComponent({ content: 'old plan', isPanelOpen: true });
        await findPanel().vm.$emit('delete');
        await waitForPromises();
      });

      it('aborts', () => {
        expect(successMutationHandler).not.toHaveBeenCalled();
      });
    });
  });

  describe('handleDraftChange', () => {
    describe('when the panel emits a value', () => {
      beforeEach(async () => {
        createComponent({ isPanelOpen: true });
        await findPanel().vm.$emit('draft-change', 'half-typed plan');
      });

      it('persists the draft to storage on every keystroke', () => {
        expect(updateDraft).toHaveBeenCalledWith(planStorageKey, 'half-typed plan');
      });
    });

    describe('when the panel emits an empty value', () => {
      beforeEach(async () => {
        createComponent({ isPanelOpen: true });
        await findPanel().vm.$emit('draft-change', '');
      });

      it('clears the draft', () => {
        expect(clearDraft).toHaveBeenCalledWith(planStorageKey);
      });
    });
  });

  describe('Generate MR with Duo wiring', () => {
    describe('when remote flows are disabled', () => {
      beforeEach(() => {
        createComponent({ duoRemoteFlowsAvailability: false, content: 'A plan' });
      });

      it('passes hasRemoteFlowsEnabled=false', () => {
        expect(findInlineRow().props('hasRemoteFlowsEnabled')).toBe(false);
      });
    });

    describe('when no plan exists', () => {
      beforeEach(() => {
        createComponent({ duoRemoteFlowsAvailability: true, content: '' });
      });

      it('passes hasContent=false', () => {
        expect(findInlineRow().props('hasContent')).toBe(false);
      });
    });

    describe('when remote flows are enabled', () => {
      beforeEach(() => {
        createComponent({ duoRemoteFlowsAvailability: true, content: 'A plan' });
      });

      it('passes hasRemoteFlowsEnabled=true', () => {
        expect(findInlineRow().props('hasRemoteFlowsEnabled')).toBe(true);
      });

      it('forwards the work-item identifiers the MR button needs', () => {
        expect(findInlineRow().props()).toMatchObject({
          projectPath: 'group/project',
          workItemIid: '1',
          workItemType: 'Epic',
          workItemWebUrl: mockWorkItemWebUrl,
        });
      });

      it('forwards the work-item identifiers and remote-flow state to the panel', () => {
        expect(findPanel().props()).toMatchObject({
          hasRemoteFlowsEnabled: true,
          workItemIid: '1',
          workItemType: 'Epic',
          workItemWebUrl: mockWorkItemWebUrl,
        });
      });
    });
  });

  describe('Duo Chat empty-state header registration', () => {
    let emitSpy;

    const findRegisterCalls = () =>
      emitSpy.mock.calls.filter(([event]) => event === DUO_CHAT_REGISTER_EMPTY_STATE_HEADER);
    const lastRegisterCall = () => {
      const calls = findRegisterCalls();
      return calls[calls.length - 1];
    };

    beforeEach(() => {
      emitSpy = jest.spyOn(eventHub, '$emit');
    });

    afterEach(() => {
      emitSpy.mockRestore();
    });

    describe('when no workplan exists', () => {
      beforeEach(() => {
        createComponent({ content: '' });
      });

      it('registers the workplan header on creation', () => {
        expect(lastRegisterCall()).toEqual([
          DUO_CHAT_REGISTER_EMPTY_STATE_HEADER,
          {
            id: 'workplan',
            component: WorkplanEmptyStateHeader,
            props: {
              hasExistingWorkplan: false,
              resourceId: mockWorkItemId,
              workItemWebUrl: mockWorkItemWebUrl,
              projectPath: 'group/project',
              workItemIid: '1',
              workItemType: 'Epic',
              isPanelOpen: false,
            },
          },
        ]);
      });

      describe('when destroyed', () => {
        beforeEach(() => {
          emitSpy.mockClear();
          wrapper.destroy();
        });

        it('deregisters the header with a null component', () => {
          expect(lastRegisterCall()).toEqual([
            DUO_CHAT_REGISTER_EMPTY_STATE_HEADER,
            { id: 'workplan', component: null },
          ]);
        });
      });
    });

    describe('when a workplan already exists', () => {
      beforeEach(async () => {
        createComponent({ content: 'existing plan' });
        await waitForPromises();
      });

      it('registers the header with hasExistingWorkplan set to true', async () => {
        await nextTick();
        expect(lastRegisterCall()[1].props.hasExistingWorkplan).toBe(true);
      });
    });

    describe('when a save succeeds', () => {
      beforeEach(async () => {
        createComponent({ content: '', isPanelOpen: true });
        await waitForPromises();
        emitSpy.mockClear();
        await findPanel().vm.$emit('save', 'fresh plan');
        await waitForPromises();
        await pushAgentPlanContent('fresh plan');
      });

      it('re-registers the header reflecting the now-saved workplan', () => {
        expect(lastRegisterCall()).toEqual([
          DUO_CHAT_REGISTER_EMPTY_STATE_HEADER,
          {
            id: 'workplan',
            component: WorkplanEmptyStateHeader,
            props: {
              hasExistingWorkplan: true,
              resourceId: mockWorkItemId,
              workItemWebUrl: mockWorkItemWebUrl,
              projectPath: 'group/project',
              workItemIid: '1',
              workItemType: 'Epic',
              isPanelOpen: true,
            },
          },
        ]);
      });
    });

    describe('when a delete is confirmed', () => {
      beforeEach(async () => {
        confirmAction.mockResolvedValueOnce(true);
        createComponent({ content: 'old plan', isPanelOpen: true });
        await waitForPromises();
        emitSpy.mockClear();
        await findPanel().vm.$emit('delete');
        await waitForPromises();
        await pushAgentPlanContent('');
      });

      it('re-registers the header reflecting the removed workplan', () => {
        expect(lastRegisterCall()).toEqual([
          DUO_CHAT_REGISTER_EMPTY_STATE_HEADER,
          {
            id: 'workplan',
            component: WorkplanEmptyStateHeader,
            props: {
              hasExistingWorkplan: false,
              resourceId: mockWorkItemId,
              workItemWebUrl: mockWorkItemWebUrl,
              projectPath: 'group/project',
              workItemIid: '1',
              workItemType: 'Epic',
              isPanelOpen: true,
            },
          },
        ]);
      });
    });

    describe('when isPanelOpen changes after mount', () => {
      // Regression guard: the header component is delivered once via the
      // eventHub (not as a live reactive binding), so the emptyStateHeaderProps
      // watcher must re-call publishEmptyStateHeader whenever a prop changes
      // so the "View" toggle state stays in sync.
      beforeEach(async () => {
        createComponent({ content: 'existing plan', isPanelOpen: false });
        await waitForPromises();
      });

      it('re-registers the header on every isPanelOpen change', async () => {
        const initialRegisterCount = findRegisterCalls().length;
        expect(lastRegisterCall()).toEqual([
          DUO_CHAT_REGISTER_EMPTY_STATE_HEADER,
          {
            id: 'workplan',
            component: WorkplanEmptyStateHeader,
            props: expect.objectContaining({ isPanelOpen: false }),
          },
        ]);

        await wrapper.setProps({ isPanelOpen: true });

        expect(findRegisterCalls()).toHaveLength(initialRegisterCount + 1);
        expect(lastRegisterCall()).toEqual([
          DUO_CHAT_REGISTER_EMPTY_STATE_HEADER,
          {
            id: 'workplan',
            component: WorkplanEmptyStateHeader,
            props: expect.objectContaining({ isPanelOpen: true }),
          },
        ]);
      });
    });
  });

  describe('async generation status', () => {
    it('forwards the status, reporting the refinement phase until the flow pauses', () => {
      createComponent({ agentPlan: buildAgentPlan({ generationStatus: 'GENERATING' }) });

      expect(findInlineRow().props('generation')).toMatchObject({
        status: 'GENERATING',
        hasAwaitedInput: false,
      });
    });

    it('remembers that the flow paused, so a later run is the plan-writing pass', async () => {
      createComponent({ agentPlan: buildAgentPlan({ generationStatus: 'GENERATING' }) });

      expect(findInlineRow().props('generation').hasAwaitedInput).toBe(false);

      await wrapper.setProps({ agentPlan: buildAgentPlan({ generationStatus: 'NEEDS_INPUT' }) });
      await wrapper.setProps({ agentPlan: buildAgentPlan({ generationStatus: 'GENERATING' }) });

      expect(findInlineRow().props('generation').hasAwaitedInput).toBe(true);
    });

    it('opens the panel once a running flow lands its plan', async () => {
      createComponent({ agentPlan: buildAgentPlan({ generationStatus: 'GENERATING' }) });

      expect(wrapper.emitted('request-panel')).toBeUndefined();

      await wrapper.setProps({
        agentPlan: buildAgentPlan({ content: 'the plan', generationStatus: 'COMPLETED' }),
      });

      expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
    });
  });

  describe('starting a run from the widget', () => {
    const failedPlan = buildAgentPlan({ generationStatus: 'FAILED' });

    describe.each`
      trigger        | findSource
      ${'the row'}   | ${() => findInlineRow()}
      ${'the panel'} | ${() => findPanel()}
    `('when $trigger asks to generate', ({ findSource }) => {
      let generateHandler;

      beforeEach(async () => {
        generateHandler = generateHandlerFor();
        createComponent({ generateHandler });

        findSource().vm.$emit('generate');
        await waitForPromises();
      });

      it('starts a run for the work item', () => {
        expect(generateHandler).toHaveBeenCalledWith({ input: { id: mockWorkItemId } });
      });
    });

    describe('when retrying a run that failed', () => {
      let generateHandler;

      beforeEach(async () => {
        generateHandler = generateHandlerFor();
        createComponent({ agentPlan: failedPlan, generateHandler });

        findInlineRow().vm.$emit('retry');
        await waitForPromises();
      });

      it('starts a run for the work item', () => {
        expect(generateHandler).toHaveBeenCalledWith({ input: { id: mockWorkItemId } });
      });

      it('asks the parent to re-read the plan, since it owns the query', () => {
        expect(wrapper.emitted('refetch-plan')).toHaveLength(1);
      });
    });

    it('marks the action as in flight while the mutation runs', async () => {
      createComponent({
        agentPlan: failedPlan,
        generateHandler: jest.fn().mockReturnValue(new Promise(() => {})),
      });

      expect(findInlineRow().props('generation').actionInFlight).toBe(false);

      findInlineRow().vm.$emit('retry');
      await nextTick();

      expect(findInlineRow().props('generation').actionInFlight).toBe(true);
    });

    describe('when the run cannot be started', () => {
      it('alerts the service message verbatim', async () => {
        createComponent({
          agentPlan: failedPlan,
          generateHandler: generateHandlerFor({
            errors: ['Async workplan generation is not enabled for this project'],
          }),
        });

        findInlineRow().vm.$emit('retry');
        await waitForPromises();

        expect(createAlert).toHaveBeenCalledWith({
          message: 'Async workplan generation is not enabled for this project',
        });
      });

      it('alerts a generic message and captures the error when the mutation rejects', async () => {
        createComponent({
          agentPlan: failedPlan,
          generateHandler: jest.fn().mockRejectedValue(new Error('network error')),
        });

        findInlineRow().vm.$emit('retry');
        await waitForPromises();

        expect(createAlert).toHaveBeenCalledWith({
          message: 'Something went wrong while starting workplan generation.',
          captureError: true,
          error: expect.any(Error),
        });
      });
    });
  });
});
