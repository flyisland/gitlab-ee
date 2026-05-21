import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlCollapsibleListbox } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import AgentPlan from 'ee/work_items/components/agent_plan/agent_plan.vue';
import DuoChatQuickAction from 'ee_component/ai/shared/widgets/duo_chat_quick_action.vue';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import MarkdownEditor from '~/vue_shared/components/markdown/markdown_editor.vue';
import { getDraft, updateDraft, clearDraft } from '~/lib/utils/autosave';
import namespacePathsQuery from '~/work_items/graphql/namespace_paths.query.graphql';
import workplanTemplatesListQuery from '~/work_items/graphql/work_item_description_templates_list.query.graphql';
import workplanTemplateQuery from '~/work_items/graphql/work_item_description_template.query.graphql';

jest.mock('~/lib/utils/autosave');

Vue.use(VueApollo);

const mockMarkdownPaths = {
  markdownPreviewPath: '/group/project/-/preview_markdown',
  uploadsPath: '/group/project/uploads',
  autocompleteSourcesPath: '/group/project/-/autocomplete_sources',
};

const namespacePathsHandler = jest.fn().mockResolvedValue({
  data: {
    namespace: {
      id: 'gid://gitlab/Group/1',
      markdownPaths: mockMarkdownPaths,
    },
  },
});

const workplanTemplatesHandler = jest.fn().mockResolvedValue({
  data: {
    namespace: {
      __typename: 'Namespace',
      id: 'gid://gitlab/Project/1',
      workItemDescriptionTemplates: {
        __typename: 'WorkItemDescriptionTemplateConnection',
        nodes: [
          {
            __typename: 'WorkItemDescriptionTemplate',
            name: 'feature.plan',
            category: 'Project Templates',
            projectId: 1,
          },
          {
            __typename: 'WorkItemDescriptionTemplate',
            name: 'Bug',
            category: 'Project Templates',
            projectId: 2,
          },
        ],
      },
    },
  },
});

const workplanTemplateContentHandler = jest.fn().mockResolvedValue({
  data: {
    workItemDescriptionTemplateContent: {
      __typename: 'WorkItemDescriptionTemplateContent',
      content: '## Plan steps',
    },
  },
});

describe('AgentPlan component', () => {
  let wrapper;

  const mockWorkItemId = 'gid://gitlab/WorkItem/1';
  const planStorageKey = `agent-plan-draft-${mockWorkItemId}`;
  const templateStorageKey = `${planStorageKey}-template`;

  const createComponent = ({
    canUpdate = true,
    content = '',
    fullPath = 'group/project',
    workItemId = mockWorkItemId,
  } = {}) => {
    wrapper = shallowMountExtended(AgentPlan, {
      apolloProvider: createMockApollo([
        [namespacePathsQuery, namespacePathsHandler],
        [workplanTemplatesListQuery, workplanTemplatesHandler],
        [workplanTemplateQuery, workplanTemplateContentHandler],
      ]),
      propsData: { content, workItemId, canUpdate },
      provide: { fullPath },
      stubs: { CrudComponent, DuoChatQuickAction },
    });
  };

  const findCrudComponent = () => wrapper.findComponent(CrudComponent);
  const findEditButton = () => wrapper.findByTestId('edit-agent-plan-button');
  const findDeleteButton = () => wrapper.findByTestId('delete-agent-plan-button');
  const findMarkdownEditor = () => wrapper.findComponent(MarkdownEditor);
  const findPlanDefinedRow = () => wrapper.findByTestId('agent-plan-defined');
  const findSaveButton = () => wrapper.findByTestId('save-agent-plan-button');
  const findCancelButton = () => wrapper.findByTestId('cancel-agent-plan-button');
  const findEmptyState = () => wrapper.findByTestId('agent-plan-empty-state');
  const findDuoChatQuickAction = () => wrapper.findComponent(DuoChatQuickAction);
  const findTemplateDropdown = () => wrapper.findComponent(GlCollapsibleListbox);

  beforeEach(() => {
    getDraft.mockReturnValue(null);
    createComponent();
  });

  it('renders CrudComponent expanded by default', () => {
    expect(findCrudComponent().props('collapsed')).toBe(false);
  });

  describe('when user cannot update', () => {
    beforeEach(() => {
      createComponent({ canUpdate: false });
    });

    it('does not show the pencil edit button', () => {
      expect(findEditButton().exists()).toBe(false);
    });
  });

  describe('when viewing the plan', () => {
    it('does not show the editor', () => {
      expect(findMarkdownEditor().exists()).toBe(false);
    });

    it('shows the pencil edit button', () => {
      expect(findEditButton().exists()).toBe(true);
    });

    describe('and there is no content', () => {
      it('shows empty state with editable prompt when canUpdate is true', () => {
        expect(findEmptyState().exists()).toBe(true);
        expect(findEmptyState().text()).toBe(
          'Describe your intent for Duo. A workplan structures context into an agent-ready input for autonomous execution.',
        );
      });

      it('shows read-only empty state when canUpdate is false', () => {
        createComponent({ canUpdate: false });

        expect(findEmptyState().exists()).toBe(true);
        expect(findEmptyState().text()).toBe(
          "No workplan has been added yet. You don't have permission to edit the workplan.",
        );
      });
    });

    describe('and there is content', () => {
      it('renders the plan-defined row', async () => {
        wrapper.setProps({ content: 'Some plan content' });
        await nextTick();

        expect(findPlanDefinedRow().exists()).toBe(true);
        expect(findPlanDefinedRow().text()).toContain('Plan defined');
        expect(findDeleteButton().exists()).toBe(true);
      });
    });
  });

  describe('when editing the plan', () => {
    beforeEach(async () => {
      await findEditButton().vm.$emit('click');
      await waitForPromises();
    });

    it('shows the markdown editor', () => {
      expect(findMarkdownEditor().exists()).toBe(true);
    });

    it('passes the correct props to the markdown editor', () => {
      expect(findMarkdownEditor().props()).toMatchObject({
        value: '',
        renderMarkdownPath: mockMarkdownPaths.markdownPreviewPath,
        uploadsPath: mockMarkdownPaths.uploadsPath,
        enableAutocomplete: false,
        autofocus: true,
      });
    });

    it('hides the pencil edit button', () => {
      expect(findEditButton().exists()).toBe(false);
    });

    it('renders the DuoChatQuickAction component with correct props', () => {
      expect(findDuoChatQuickAction().props()).toMatchObject({
        resourceId: mockWorkItemId,
      });
    });

    describe('when cancelling', () => {
      beforeEach(async () => {
        await findCancelButton().vm.$emit('click');
      });

      it('hides the editor', () => {
        expect(findMarkdownEditor().exists()).toBe(false);
      });

      it('shows the empty state again', () => {
        expect(findEmptyState().exists()).toBe(true);
      });

      it('clears the draft from localStorage', () => {
        expect(clearDraft).toHaveBeenCalledWith(planStorageKey);
      });

      it('resets editor content to the original prop value', async () => {
        createComponent({ content: 'original content', workItemId: mockWorkItemId });
        await findEditButton().vm.$emit('click');
        await waitForPromises();
        await findMarkdownEditor().vm.$emit('input', 'modified text');
        await findCancelButton().vm.$emit('click');
        await findEditButton().vm.$emit('click');
        await waitForPromises();

        expect(findMarkdownEditor().props('value')).toBe('original content');
      });
    });

    describe('when saving', () => {
      beforeEach(async () => {
        await findMarkdownEditor().vm.$emit('input', 'Updated plan');
        await findSaveButton().vm.$emit('click');
      });

      it('exits edit mode', () => {
        expect(findMarkdownEditor().exists()).toBe(false);
      });

      it('emits save event with the new content', () => {
        expect(wrapper.emitted('save')).toEqual([['Updated plan']]);
      });

      it('persists the saved content to localStorage', () => {
        expect(updateDraft).toHaveBeenCalledWith(planStorageKey, 'Updated plan');
      });
    });

    describe('draft persistence', () => {
      it('saves draft to localStorage on each input', async () => {
        await findMarkdownEditor().vm.$emit('input', 'draft text');

        expect(updateDraft).toHaveBeenCalledWith(planStorageKey, 'draft text');
      });
    });
  });

  describe('when there is a saved draft', () => {
    it('restores draft content when entering edit mode', async () => {
      const draft = 'previously saved draft';
      getDraft.mockReturnValue(draft);
      createComponent();

      await findEditButton().vm.$emit('click');
      await waitForPromises();

      expect(findMarkdownEditor().props('value')).toBe(draft);
    });
  });

  describe('when workItemId is not set', () => {
    beforeEach(async () => {
      jest.clearAllMocks();
      createComponent({ workItemId: null });
      await findEditButton().vm.$emit('click');
      await waitForPromises();
    });

    it('does not read from localStorage', () => {
      expect(getDraft).not.toHaveBeenCalled();
    });

    it('does not write to localStorage on cancel', async () => {
      await findCancelButton().vm.$emit('click');
      expect(clearDraft).not.toHaveBeenCalled();
      expect(updateDraft).not.toHaveBeenCalled();
    });
  });

  describe('when edit button is clicked while collapsed', () => {
    beforeEach(async () => {
      await findCrudComponent().vm.$emit('collapsed');
    });

    it('expands the CrudComponent', async () => {
      expect(findCrudComponent().props('collapsed')).toBe(true);

      await findEditButton().vm.$emit('click');
      expect(findCrudComponent().props('collapsed')).toBe(false);
    });
  });

  describe('workplan template dropdown', () => {
    beforeEach(async () => {
      await findEditButton().vm.$emit('click');
      await waitForPromises();
    });

    it('shows only ".plan" templates under "Project Workplan Templates" group', () => {
      const groups = findTemplateDropdown().props('items');
      const optionTexts = groups.flatMap((g) => g.options.map((o) => o.text));

      expect(optionTexts).toEqual(['feature.plan']);
      expect(groups.map((g) => g.text)).toEqual(['Project Workplan Templates']);
    });

    it('loads template content into editor and persists template name on save', async () => {
      findTemplateDropdown().vm.$emit(
        'select',
        JSON.stringify({ name: 'feature.plan', category: 'Project Templates', projectId: 1 }),
      );
      await waitForPromises();

      expect(findMarkdownEditor().props('value')).toBe('## Plan steps');

      await findSaveButton().vm.$emit('click');

      expect(updateDraft).toHaveBeenCalledWith(templateStorageKey, 'feature.plan');
      expect(findPlanDefinedRow().text()).toContain('Plan defined based on feature.plan');
    });
  });

  describe('deleting the plan', () => {
    it('emits delete, clears storage, and returns to empty state', async () => {
      wrapper.setProps({ content: 'Some plan content' });
      await nextTick();
      await findDeleteButton().vm.$emit('click');

      expect(wrapper.emitted('delete')).toHaveLength(1);
      expect(clearDraft).toHaveBeenCalledWith(planStorageKey);
      expect(clearDraft).toHaveBeenCalledWith(templateStorageKey);
      expect(findEmptyState().exists()).toBe(true);
    });
  });
});
