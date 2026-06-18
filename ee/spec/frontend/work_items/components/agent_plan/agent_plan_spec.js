import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import AgentPlan from 'ee/work_items/components/agent_plan/agent_plan.vue';
import AgentPlanInlineRow from 'ee/work_items/components/agent_plan/agent_plan_inline_row.vue';
import AgentPlanPanel from 'ee/work_items/components/agent_plan/agent_plan_panel.vue';
import updateWorkItemMutation from '~/work_items/graphql/update_work_item.mutation.graphql';
import { createAlert } from '~/alert';
import { confirmAction } from '~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal';
import * as urlUtility from '~/lib/utils/url_utility';
import { getDraft, updateDraft, clearDraft } from '~/lib/utils/autosave';
import { workItemResponseFactory } from 'ee_jest/work_items/mock_data';

jest.mock('~/lib/utils/autosave');
jest.mock('~/alert');
jest.mock('~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal', () => ({
  confirmAction: jest.fn(),
}));

Vue.use(VueApollo);

describe('AgentPlan component (orchestrator)', () => {
  let wrapper;

  const mockWorkItemId = 'gid://gitlab/WorkItem/1';
  const mockWorkItemWebUrl = 'http://gdk.test/gitlab-org/gitlab/-/issues/1';
  const planStorageKey = `agent-plan-draft-${mockWorkItemId}`;
  const templateStorageKey = `${planStorageKey}-template`;

  const buildWorkItem = ({
    workItemId = mockWorkItemId,
    workItemType = 'Epic',
    content = '',
  } = {}) => {
    const base = workItemResponseFactory({ id: workItemId }).data.workItem;
    return {
      ...base,
      workItemType: { ...base.workItemType, name: workItemType },
      widgets: [
        ...(base.widgets || []).filter((w) => w.type !== 'AGENT_PLAN'),
        { __typename: 'WorkItemWidgetAgentPlan', type: 'AGENT_PLAN', content },
      ],
    };
  };

  const buildWorkItemWithFeatures = ({ content = '' } = {}) => ({
    ...buildWorkItem(),
    features: { agentPlan: { content } },
  });

  const successMutationHandler = jest.fn().mockResolvedValue({
    data: {
      workItemUpdate: {
        __typename: 'WorkItemUpdatePayload',
        workItem: buildWorkItem(),
        errors: [],
      },
    },
  });

  const createComponent = ({
    canUpdate = true,
    content = '',
    workItem = buildWorkItem({ content }),
    workItemWebUrl = mockWorkItemWebUrl,
    isInDrawer = false,
    isPanelOpen = false,
    mutationHandler = successMutationHandler,
    duoRemoteFlowsAvailability = false,
    fullPath = 'group/project',
  } = {}) => {
    wrapper = shallowMountExtended(AgentPlan, {
      apolloProvider: createMockApollo([[updateWorkItemMutation, mutationHandler]]),
      propsData: { workItem, canUpdate, workItemWebUrl, isInDrawer, isPanelOpen },
      provide: { fullPath, duoRemoteFlowsAvailability },
    });
  };

  const findInlineRow = () => wrapper.findComponent(AgentPlanInlineRow);
  const findPanel = () => wrapper.findComponent(AgentPlanPanel);

  beforeEach(() => {
    getDraft.mockReturnValue(null);
    successMutationHandler.mockClear();
    confirmAction.mockReset();
  });

  describe('inline row wiring', () => {
    it('passes hasContent=false when there is no saved content', () => {
      createComponent({ content: '' });
      expect(findInlineRow().props('hasContent')).toBe(false);
    });

    it('passes hasContent=true when content is set on the workItem', () => {
      createComponent({ content: 'some plan' });
      expect(findInlineRow().props('hasContent')).toBe(true);
    });

    it('forwards canUpdate to the inline row', () => {
      createComponent({ canUpdate: false });
      expect(findInlineRow().props('canUpdate')).toBe(false);
    });
  });

  describe('panel wiring', () => {
    it('passes isPanelOpen down as the panel open prop', () => {
      createComponent({ isPanelOpen: true });
      expect(findPanel().props('open')).toBe(true);
    });

    it('passes the workItem content as savedContent (widgets path)', () => {
      createComponent({ content: 'plan via widgets' });
      expect(findPanel().props('savedContent')).toBe('plan via widgets');
    });

    it('passes the workItem content as savedContent (features path)', () => {
      createComponent({ workItem: buildWorkItemWithFeatures({ content: 'plan via features' }) });
      expect(findPanel().props('savedContent')).toBe('plan via features');
    });

    it('forwards canUpdate to the panel', () => {
      createComponent({ canUpdate: true });
      expect(findPanel().props('canUpdate')).toBe(true);
    });
  });

  describe('openPanel', () => {
    it('emits request-panel with the agent-plan key when the inline row opens', async () => {
      createComponent({ content: 'existing' });
      await findInlineRow().vm.$emit('open');
      expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
    });

    it('enters edit mode directly when opening with no content and user can update', async () => {
      createComponent({ content: '', canUpdate: true });
      await findInlineRow().vm.$emit('open');
      expect(findPanel().props('isEditing')).toBe(true);
    });

    it('stays in view mode when opening with existing content', async () => {
      createComponent({ content: 'existing', canUpdate: true });
      await findInlineRow().vm.$emit('open');
      expect(findPanel().props('isEditing')).toBe(false);
    });

    it('stays in view mode when the user cannot update', async () => {
      createComponent({ content: '', canUpdate: false });
      await findInlineRow().vm.$emit('open');
      expect(findPanel().props('isEditing')).toBe(false);
    });

    it('opens in view mode even when a leftover draft exists (View workplan must not force edit)', async () => {
      getDraft.mockImplementation((key) => (key === planStorageKey ? 'half-typed' : null));
      createComponent({ content: 'existing', canUpdate: true });
      await findInlineRow().vm.$emit('open');
      expect(findPanel().props('isEditing')).toBe(false);
    });

    it('closes the panel when the inline row re-emits open while already open (toggle)', async () => {
      createComponent({ content: 'existing', isPanelOpen: true });
      await findInlineRow().vm.$emit('open');
      expect(wrapper.emitted('request-panel')).toEqual([[null]]);
    });

    describe('when rendered inside a drawer', () => {
      let visitUrlSpy;

      beforeEach(() => {
        visitUrlSpy = jest.spyOn(urlUtility, 'visitUrl').mockImplementation(() => {});
      });

      afterEach(() => {
        visitUrlSpy.mockRestore();
      });

      it('navigates to the full work-item page with ?show=work-plan', async () => {
        createComponent({
          isInDrawer: true,
          workItemWebUrl: '/group/project/-/work_items/42',
        });
        await findInlineRow().vm.$emit('open');
        expect(visitUrlSpy).toHaveBeenCalledWith('/group/project/-/work_items/42?show=work-plan');
        expect(wrapper.emitted('request-panel')).toBeUndefined();
      });
    });
  });

  describe('Duo "Generate workplan" path', () => {
    describe('open-chat-request (before chat opens)', () => {
      it('opens the panel in view mode when closed', async () => {
        createComponent({ content: '', canUpdate: true });
        await findInlineRow().vm.$emit('open-chat-request');
        expect(wrapper.emitted('request-panel')).toEqual([['agent-plan']]);
        expect(findPanel().props('isEditing')).toBe(false);
      });

      it('does not re-emit request-panel when the panel is already open', async () => {
        createComponent({ content: 'existing', canUpdate: true, isPanelOpen: true });
        await findInlineRow().vm.$emit('open-chat-request');
        expect(wrapper.emitted('request-panel')).toBeUndefined();
      });
    });

    describe('open-chat-completed (after chat opens)', () => {
      it('cancels editing if user was editing', async () => {
        createComponent({ content: 'existing', canUpdate: true, isPanelOpen: true });
        await findPanel().vm.$emit('start-edit');
        expect(findPanel().props('isEditing')).toBe(true);

        await findInlineRow().vm.$emit('open-chat-completed');
        expect(findPanel().props('isEditing')).toBe(false);
      });

      it('is a no-op when not editing', async () => {
        createComponent({ content: 'existing', canUpdate: true, isPanelOpen: true });
        await findInlineRow().vm.$emit('open-chat-completed');
        expect(findPanel().props('isEditing')).toBe(false);
      });
    });
  });

  describe('closePanel', () => {
    it('emits request-panel null when the panel emits close', async () => {
      createComponent({ isPanelOpen: true });
      await findPanel().vm.$emit('close');
      expect(wrapper.emitted('request-panel')).toEqual([[null]]);
    });
  });

  describe('handleSave', () => {
    it('sends the new content to the mutation', async () => {
      createComponent({ isPanelOpen: true });
      await findPanel().vm.$emit('save', { content: 'fresh plan', templateName: null });
      await waitForPromises();

      expect(successMutationHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          input: { id: mockWorkItemId, agentPlanWidget: { content: 'fresh plan' } },
        }),
      );
    });

    it('clears the draft on successful save', async () => {
      createComponent({ isPanelOpen: true });
      await findPanel().vm.$emit('save', { content: 'persisted', templateName: null });
      await waitForPromises();
      expect(clearDraft).toHaveBeenCalledWith(planStorageKey);
    });

    it('persists the applied template name on successful save', async () => {
      createComponent({ isPanelOpen: true });
      await findPanel().vm.$emit('save', {
        content: 'persisted',
        templateName: 'feature.plan',
      });
      await waitForPromises();
      expect(updateDraft).toHaveBeenCalledWith(templateStorageKey, 'feature.plan');
    });

    it('passes the persisted template name into the panel', async () => {
      getDraft.mockImplementation((key) => (key === templateStorageKey ? 'feature.plan' : null));
      createComponent();
      await nextTick();
      expect(findPanel().props('appliedTemplateName')).toBe('feature.plan');
    });

    it('surfaces a mutation error via createAlert and Sentry', async () => {
      const failingHandler = jest
        .fn()
        .mockResolvedValue({ data: { workItemUpdate: { errors: ['boom'] } } });
      createComponent({ isPanelOpen: true, mutationHandler: failingHandler });
      await findPanel().vm.$emit('save', { content: 'broken', templateName: null });
      await waitForPromises();

      expect(createAlert).toHaveBeenCalled();
    });
  });

  describe('handleDelete', () => {
    it('clears the saved plan via the mutation when confirmed', async () => {
      confirmAction.mockResolvedValueOnce(true);
      createComponent({ content: 'old plan', isPanelOpen: true });
      await findPanel().vm.$emit('delete');
      await waitForPromises();

      expect(successMutationHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          input: { id: mockWorkItemId, agentPlanWidget: { content: '' } },
        }),
      );
    });

    it('clears both drafts (plan + template) when confirmed', async () => {
      confirmAction.mockResolvedValueOnce(true);
      createComponent({ content: 'old plan', isPanelOpen: true });
      await findPanel().vm.$emit('delete');
      await waitForPromises();

      expect(clearDraft).toHaveBeenCalledWith(planStorageKey);
      expect(clearDraft).toHaveBeenCalledWith(templateStorageKey);
    });

    it('aborts when the confirm modal is dismissed', async () => {
      confirmAction.mockResolvedValueOnce(false);
      createComponent({ content: 'old plan', isPanelOpen: true });
      await findPanel().vm.$emit('delete');
      await waitForPromises();

      expect(successMutationHandler).not.toHaveBeenCalled();
    });
  });

  describe('handleDraftChange', () => {
    it('persists the draft to storage on every keystroke', async () => {
      createComponent({ isPanelOpen: true });
      await findPanel().vm.$emit('draft-change', 'half-typed plan');
      expect(updateDraft).toHaveBeenCalledWith(planStorageKey, 'half-typed plan');
    });

    it('clears the draft when the panel emits an empty value', async () => {
      createComponent({ isPanelOpen: true });
      await findPanel().vm.$emit('draft-change', '');
      expect(clearDraft).toHaveBeenCalledWith(planStorageKey);
    });
  });

  describe('saved template restoration', () => {
    it('reads the applied template name from storage on mount', async () => {
      getDraft.mockImplementation((key) => (key === templateStorageKey ? 'feature.plan' : null));
      createComponent();
      await nextTick();
      expect(findPanel().props('appliedTemplateName')).toBe('feature.plan');
    });
  });

  describe('Generate MR with Duo wiring', () => {
    it('passes hasRemoteFlowsEnabled=false when remote flows are disabled', () => {
      createComponent({ duoRemoteFlowsAvailability: false, content: 'A plan' });
      expect(findInlineRow().props('hasRemoteFlowsEnabled')).toBe(false);
    });

    it('passes hasContent=false when no plan exists', () => {
      createComponent({ duoRemoteFlowsAvailability: true, content: '' });
      expect(findInlineRow().props('hasContent')).toBe(false);
    });

    it('passes hasRemoteFlowsEnabled=true when remote flows are enabled', () => {
      createComponent({ duoRemoteFlowsAvailability: true, content: 'A plan' });
      expect(findInlineRow().props('hasRemoteFlowsEnabled')).toBe(true);
    });

    it('forwards the work-item identifiers the MR button needs', () => {
      createComponent({ duoRemoteFlowsAvailability: true, content: 'A plan' });
      expect(findInlineRow().props()).toMatchObject({
        projectPath: 'group/project',
        workItemIid: '1',
        workItemType: 'Epic',
        workItemWebUrl: mockWorkItemWebUrl,
      });
    });
  });
});
