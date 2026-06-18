import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlCollapsibleListbox } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import AgentPlanPanel from 'ee/work_items/components/agent_plan/agent_plan_panel.vue';
import MarkdownEditor from '~/vue_shared/components/markdown/markdown_editor.vue';
import NonGfmMarkdown from '~/vue_shared/components/markdown/non_gfm_markdown.vue';
import namespacePathsQuery from '~/work_items/graphql/namespace_paths.query.graphql';
import workplanTemplatesListQuery from '~/work_items/graphql/work_item_description_templates_list.query.graphql';
import workplanTemplateQuery from '~/work_items/graphql/work_item_description_template.query.graphql';
import * as urlUtility from '~/lib/utils/url_utility';

Vue.use(VueApollo);

const MountingPortalStub = {
  name: 'MountingPortal',
  template: '<div data-testid="mounting-portal-stub"><slot /></div>',
};

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

describe('AgentPlanPanel', () => {
  let wrapper;

  const createComponent = ({
    open = true,
    canUpdate = true,
    savedContent = '',
    draftContent = '',
    appliedTemplateName = null,
    isEditing = false,
    isSaving = false,
    fullPath = 'group/project',
  } = {}) => {
    wrapper = shallowMountExtended(AgentPlanPanel, {
      apolloProvider: createMockApollo([
        [namespacePathsQuery, namespacePathsHandler],
        [workplanTemplatesListQuery, workplanTemplatesHandler],
        [workplanTemplateQuery, workplanTemplateContentHandler],
      ]),
      propsData: {
        open,
        canUpdate,
        savedContent,
        draftContent,
        appliedTemplateName,
        isEditing,
        isSaving,
      },
      provide: { fullPath },
      stubs: {
        MountingPortal: MountingPortalStub,
      },
    });
  };

  const findPortal = () => wrapper.findByTestId('mounting-portal-stub');
  const findPanel = () => wrapper.findByTestId('agent-plan-panel');
  const findEditButton = () => wrapper.findByTestId('panel-edit-button');
  const findMoreActionsDropdown = () => wrapper.findByTestId('panel-edit-more-actions');
  const findCloseButton = () => wrapper.findByTestId('panel-close-button');
  const findSaveButton = () => wrapper.findByTestId('save-agent-plan-button');
  const findCancelButton = () => wrapper.findByTestId('cancel-agent-plan-button');
  const findEmptyState = () => wrapper.findByTestId('agent-plan-empty-state');
  const findMarkdownEditor = () => wrapper.findComponent(MarkdownEditor);
  const findRenderedMarkdown = () => wrapper.findComponent(NonGfmMarkdown);
  const findTemplateDropdown = () => wrapper.findComponent(GlCollapsibleListbox);

  const enterEditMode = async () => {
    await findEditButton().vm.$emit('click');
    await wrapper.setProps({ isEditing: true });
  };

  describe('rendering', () => {
    it('does not render the portal when open is false', () => {
      createComponent({ open: false });
      expect(findPortal().exists()).toBe(false);
    });

    it('renders the panel chrome when open is true', () => {
      createComponent({ open: true });
      expect(findPanel().exists()).toBe(true);
    });
  });

  describe('view mode', () => {
    it('shows the empty state when there is no saved content', () => {
      createComponent({ savedContent: '', canUpdate: true });
      expect(findEmptyState().exists()).toBe(true);
      expect(findEmptyState().text()).toContain('Describe your intent for Duo');
    });

    it('shows a read-only empty state when canUpdate is false', () => {
      createComponent({ savedContent: '', canUpdate: false });
      expect(findEmptyState().text()).toContain("don't have permission");
    });

    it('renders the saved markdown when content exists', () => {
      createComponent({ savedContent: 'Some plan content' });
      expect(findRenderedMarkdown().exists()).toBe(true);
      expect(findRenderedMarkdown().props('markdown')).toBe('Some plan content');
    });

    describe('more actions dropdown', () => {
      describe('with saved content', () => {
        let dropdownItems;

        beforeEach(() => {
          createComponent({ savedContent: 'Some plan', canUpdate: true });
          dropdownItems = findMoreActionsDropdown().props('items') || [];
        });

        it('exposes Delete workplan as an option', () => {
          expect(dropdownItems.map((i) => i.text)).toContain('Delete workplan');
        });

        it('exposes Regenerate workplan as an option', () => {
          expect(dropdownItems.map((i) => i.text)).toContain('Regenerate workplan');
        });

        it('emits "regenerate" when the Regenerate item is activated', () => {
          const regenerate = dropdownItems.find((i) => i.text === 'Regenerate workplan');
          regenerate.action();
          expect(wrapper.emitted('regenerate')).toHaveLength(1);
        });
      });

      describe('without saved content', () => {
        beforeEach(() => {
          createComponent({ savedContent: '', canUpdate: true });
        });

        it('hides the dropdown so Regenerate is not exposed', () => {
          expect(findMoreActionsDropdown().exists()).toBe(false);
        });
      });
    });
  });

  describe('header buttons', () => {
    beforeEach(async () => {
      createComponent({ canUpdate: true });
      await waitForPromises();
    });

    it('shows the Edit button when canUpdate is true and not editing', () => {
      expect(findEditButton().exists()).toBe(true);
    });

    it('hides the Edit button when canUpdate is false', () => {
      createComponent({ canUpdate: false });
      expect(findEditButton().exists()).toBe(false);
    });

    it('emits "start-edit" when the Edit button is clicked', async () => {
      createComponent({ canUpdate: true, savedContent: 'plan' });
      await findEditButton().vm.$emit('click');
      expect(wrapper.emitted('start-edit')).toHaveLength(1);
    });

    it('emits "close" when the Close button is clicked', async () => {
      await findCloseButton().vm.$emit('click');
      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });

  describe('initial mode', () => {
    it('opens in view mode by default', () => {
      createComponent({ savedContent: 'plan' });
      expect(findMarkdownEditor().exists()).toBe(false);
      expect(findRenderedMarkdown().exists()).toBe(true);
    });
  });

  describe('edit mode', () => {
    beforeEach(async () => {
      createComponent({ savedContent: 'existing plan', canUpdate: true });
      await waitForPromises();
      await enterEditMode();
    });

    it('renders the markdown editor with the saved content', () => {
      expect(findMarkdownEditor().props()).toMatchObject({
        value: 'existing plan',
        renderMarkdownPath: mockMarkdownPaths.markdownPreviewPath,
        uploadsPath: mockMarkdownPaths.uploadsPath,
      });
    });

    it('hides the Edit header button while editing', () => {
      expect(findEditButton().exists()).toBe(false);
    });

    describe('keystrokes', () => {
      it('emits draft-change on every input', async () => {
        await findMarkdownEditor().vm.$emit('input', 'half-typed');
        expect(wrapper.emitted('draft-change')).toEqual([['half-typed']]);
      });
    });

    describe('save', () => {
      it('emits "save" with the new content and the selected template name', async () => {
        await findMarkdownEditor().vm.$emit('input', 'updated plan');
        await findSaveButton().vm.$emit('click');
        expect(wrapper.emitted('save')).toEqual([
          [{ content: 'updated plan', templateName: null }],
        ]);
      });

      it('does not flip out of edit mode locally (orchestrator decides)', async () => {
        await findMarkdownEditor().vm.$emit('input', 'updated plan');
        await findSaveButton().vm.$emit('click');
        await nextTick();
        expect(findMarkdownEditor().exists()).toBe(true);
      });
    });

    describe('cancel', () => {
      it('emits "cancel-edit" when the cancel button is clicked', async () => {
        await findCancelButton().vm.$emit('click');
        expect(wrapper.emitted('cancel-edit')).toHaveLength(1);
      });

      it('re-initialises the editor from saved content on the next edit', async () => {
        await findMarkdownEditor().vm.$emit('input', 'unsaved');
        await findCancelButton().vm.$emit('click');
        await wrapper.setProps({ isEditing: false, draftContent: '' });
        await wrapper.setProps({ isEditing: true });
        expect(findMarkdownEditor().props('value')).toBe('existing plan');
      });
    });
  });

  describe('templates dropdown', () => {
    beforeEach(async () => {
      createComponent({ canUpdate: true });
      await waitForPromises();
      await enterEditMode();
    });

    it('shows only ".plan" templates under the "Project Workplan Templates" group', () => {
      const groups = findTemplateDropdown().props('items');
      const optionTexts = groups.flatMap((g) => g.options.map((o) => o.text));
      expect(optionTexts).toEqual(['feature.plan']);
      expect(groups.map((g) => g.text)).toEqual(['Project Workplan Templates']);
    });

    it('loads the template content into the editor on select', async () => {
      findTemplateDropdown().vm.$emit(
        'select',
        JSON.stringify({ name: 'feature.plan', category: 'Project Templates', projectId: 1 }),
      );
      await waitForPromises();
      expect(findMarkdownEditor().props('value')).toBe('## Plan steps');
    });

    it('persists the template name on save', async () => {
      findTemplateDropdown().vm.$emit(
        'select',
        JSON.stringify({ name: 'feature.plan', category: 'Project Templates', projectId: 1 }),
      );
      await waitForPromises();
      await findSaveButton().vm.$emit('click');
      const saves = wrapper.emitted('save');
      expect(saves[saves.length - 1][0]).toEqual({
        content: '## Plan steps',
        templateName: 'feature.plan',
      });
    });
  });

  describe('URL state', () => {
    let updateHistorySpy;
    let originalSearch;

    const setSearch = (search) => {
      Object.defineProperty(window, 'location', {
        configurable: true,
        value: { ...window.location, search },
      });
    };

    beforeEach(() => {
      originalSearch = window.location.search;
      updateHistorySpy = jest.spyOn(urlUtility, 'updateHistory').mockImplementation(() => {});
    });

    afterEach(() => {
      setSearch(originalSearch);
      updateHistorySpy.mockRestore();
    });

    it('writes ?show=work-plan to history when open becomes true', async () => {
      createComponent({ open: false });
      updateHistorySpy.mockClear();
      await wrapper.setProps({ open: true });
      expect(updateHistorySpy).toHaveBeenCalledTimes(1);
      expect(updateHistorySpy.mock.calls[0][0].url).toMatch(/show=work-plan/);
    });

    it('strips ?show=work-plan when open becomes false and the value still matches', async () => {
      setSearch('?show=work-plan');
      createComponent({ open: true });
      updateHistorySpy.mockClear();
      await wrapper.setProps({ open: false });
      expect(updateHistorySpy).toHaveBeenCalledTimes(1);
      expect(updateHistorySpy.mock.calls[0][0].url).not.toMatch(/show=/);
    });

    it('does not strip ?show when another panel already overwrote the value', async () => {
      setSearch('?show=work-plan');
      createComponent({ open: true });
      setSearch('?show=eyJpaWQiOiI0NiJ9');
      updateHistorySpy.mockClear();
      await wrapper.setProps({ open: false });
      expect(updateHistorySpy).not.toHaveBeenCalled();
    });
  });

  describe('keyboard handling', () => {
    let addEventListenerSpy;
    let keydownHandler;

    beforeEach(() => {
      addEventListenerSpy = jest
        .spyOn(document, 'addEventListener')
        .mockImplementation((event, handler) => {
          if (event === 'keydown') keydownHandler = handler;
        });
    });

    afterEach(() => {
      addEventListenerSpy.mockRestore();
    });

    it('emits "close" when Escape is pressed while open', () => {
      createComponent({ open: true });
      keydownHandler({ key: 'Escape' });
      expect(wrapper.emitted('close')).toHaveLength(1);
    });

    it('does nothing when Escape is pressed while closed', () => {
      createComponent({ open: false });
      keydownHandler({ key: 'Escape' });
      expect(wrapper.emitted('close')).toBeUndefined();
    });

    it('does not emit close when a modal is open in the document', () => {
      createComponent({ open: true });
      document.body.classList.add('modal-open');
      keydownHandler({ key: 'Escape' });
      expect(wrapper.emitted('close')).toBeUndefined();
      document.body.classList.remove('modal-open');
    });
  });
});
