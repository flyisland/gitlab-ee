import waitForPromises from 'helpers/wait_for_promises';
import { ignoreConsoleMessages } from 'helpers/console_watcher';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import AiCatalogFlowsNew from 'ee/ai/catalog/pages/ai_catalog_flows_new.vue';
import AiCatalogFlowsEdit from 'ee/ai/catalog/pages/ai_catalog_flows_edit.vue';
import AiCatalogFlowsDuplicate from 'ee/ai/catalog/pages/ai_catalog_flows_duplicate.vue';
import createAiCatalogFlowMutation from 'ee/ai/catalog/graphql/mutations/create_ai_catalog_flow.mutation.graphql';
import updateAiCatalogFlowMutation from 'ee/ai/catalog/graphql/mutations/update_ai_catalog_flow.mutation.graphql';
import {
  mockFlow,
  mockFlowVersion,
  mockVersionProp,
  mockCreateAiCatalogFlowSuccessMutation,
  mockUpdateAiCatalogFlowSuccessMutation,
  mockUpdateAiCatalogFlowNoChangeMutation,
} from '../mock_data';
import {
  createIntegrationWrapper,
  createMockRouter,
  PROJECT_PROVIDE,
  ROUTE_PRESETS,
  SourceEditorStub,
} from './helpers';

jest.mock('~/lib/utils/common_utils', () => ({
  ...jest.requireActual('~/lib/utils/common_utils'),
  // isLoggedIn() evaluates Boolean(window.gon?.current_user_id), which is undefined in jsdom
  isLoggedIn: jest.fn().mockReturnValue(true),
}));

// GlExperimentBadge (used in page headings) triggers this Vue 3 warning on mount
// Suppressed as it originates in @gitlab/ui
ignoreConsoleMessages([/Runtime directive used on component with non-element root node/]);

const { name, description, project, latestVersion } = mockFlow;
const mockFormValues = {
  name,
  description,
  projectId: project.id,
  public: true,
  definition: latestVersion.definition,
};

const submitFlowForm = async (wrapper, formValues) => {
  await wrapper.findByTestId('flow-form-input-name').setValue(formValues.name);
  await wrapper.findByTestId('flow-form-textarea-description').setValue(formValues.description);
  await wrapper
    .findByTestId('flow-form-definition')
    .find('textarea')
    .setValue(formValues.definition);
  return wrapper.find('form').trigger('submit');
};

describe('Flow — create page integration', () => {
  const mountFlowNew = (mutationHandler) =>
    createIntegrationWrapper(AiCatalogFlowsNew, {
      provide: {
        ...PROJECT_PROVIDE,
        glAbilities: { adminAiCatalogItem: true },
      },
      apolloHandlers: [[createAiCatalogFlowMutation, mutationHandler]],
      route: ROUTE_PRESETS.flowNew,
      stubs: { SourceEditor: SourceEditorStub },
    });

  describe('on create submit', () => {
    it('fires create mutation, shows toast, and redirects to the show page', async () => {
      const handler = jest.fn().mockResolvedValue(mockCreateAiCatalogFlowSuccessMutation);
      const { wrapper, router, toast } = mountFlowNew(handler);

      await submitFlowForm(wrapper, mockFormValues);
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith({
        input: {
          name,
          description,
          projectId: project.id,
          public: false,
          definition: latestVersion.definition,
        },
      });
      expect(toast.show).toHaveBeenCalledWith('Flow created.');
      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.flowShow.name);
      expect(String(router.currentRoute.params.id)).toBe(String(getIdFromGraphQLId(mockFlow.id)));
    });
  });
});

describe('Flow — edit page integration', () => {
  const mountFlowEdit = ({
    flow = mockFlow,
    version = mockVersionProp,
    mutationHandler = jest.fn().mockResolvedValue(mockUpdateAiCatalogFlowSuccessMutation),
    router,
  } = {}) =>
    createIntegrationWrapper(AiCatalogFlowsEdit, {
      provide: {
        ...PROJECT_PROVIDE,
        glAbilities: { adminAiCatalogItem: true },
      },
      props: {
        aiCatalogFlow: flow,
        version,
      },
      apolloHandlers: [[updateAiCatalogFlowMutation, mutationHandler]],
      route: ROUTE_PRESETS.flowEdit,
      stubs: { SourceEditor: SourceEditorStub },
      router,
    });

  it('pre-populates form with current flow values including definition YAML', () => {
    const { wrapper } = mountFlowEdit();

    expect(wrapper.findByTestId('flow-form-input-name').element.value).toBe(mockFlow.name);
    expect(wrapper.findByTestId('flow-form-textarea-description').element.value).toBe(
      mockFlow.description,
    );
    expect(wrapper.findByTestId('flow-form-definition').find('textarea').element.value).toBe(
      mockFlowVersion.definition,
    );
  });

  describe('on edit submit', () => {
    it('fires update mutation, shows toast, and redirects to show page', async () => {
      const handler = jest.fn().mockResolvedValue(mockUpdateAiCatalogFlowSuccessMutation);
      const { wrapper, router, toast } = mountFlowEdit({ mutationHandler: handler });

      // In Vue Router 4 (Vue 3) router.push() is async
      // Await promises so $route.params.id is populated before handleSubmit reads it
      await waitForPromises(); // initial router navigation
      await submitFlowForm(wrapper, mockFormValues);
      await waitForPromises(); // mutation + redirect

      expect(handler).toHaveBeenCalledWith({
        input: { id: mockFlow.id, ...mockFormValues, projectId: undefined },
      });
      expect(toast.show).toHaveBeenCalledWith('Flow updated.');
      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.flowShow.name);
      expect(router.currentRoute.params.id).toBe(ROUTE_PRESETS.flowEdit.params.id);
    });

    it('redirects to show page without showing toast when there are no changes', async () => {
      const handler = jest.fn().mockResolvedValue(mockUpdateAiCatalogFlowNoChangeMutation);
      const { wrapper, router, toast } = mountFlowEdit({ mutationHandler: handler });

      await waitForPromises(); // initial router navigation
      await submitFlowForm(wrapper, mockFormValues);
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith({
        input: { id: mockFlow.id, ...mockFormValues, projectId: undefined },
      });
      expect(toast.show).not.toHaveBeenCalled();
      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.flowShow.name);
    });
  });

  describe('permissions-based redirections', () => {
    it('redirects to show page when user lacks edit permission', async () => {
      // Pre-navigate before mounting so $route.params.id is set when created() runs
      // Vue Router 4 (Vue 3) navigation is async; awaiting ensures params are populated at mount time
      const router = createMockRouter(ROUTE_PRESETS.flowEdit);
      await waitForPromises();

      mountFlowEdit({
        flow: { ...mockFlow, userPermissions: { adminAiCatalogItem: false } },
        router,
      });
      await waitForPromises();

      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.flowShow.name);
    });

    it('does not redirect when user has edit permission', async () => {
      const { router } = mountFlowEdit();
      await waitForPromises();

      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.flowEdit.name);
    });
  });
});

describe('Flow — duplicate page integration', () => {
  const mockDuplicateFormValues = {
    name: `Copy of ${mockFlow.name}`,
    public: false,
    description: mockFlow.description,
    definition: mockFlowVersion.definition,
    projectId: project.id,
  };

  const mountFlowDuplicate = ({
    flow = mockFlow,
    mutationHandler = jest.fn().mockResolvedValue(mockCreateAiCatalogFlowSuccessMutation),
    router,
  } = {}) =>
    createIntegrationWrapper(AiCatalogFlowsDuplicate, {
      provide: {
        ...PROJECT_PROVIDE,
        glAbilities: { adminAiCatalogItem: true },
      },
      props: {
        aiCatalogFlow: flow,
      },
      apolloHandlers: [[createAiCatalogFlowMutation, mutationHandler]],
      route: ROUTE_PRESETS.flowDuplicate,
      stubs: { SourceEditor: SourceEditorStub },
      router,
    });

  describe('on duplicate submit', () => {
    it('fires create mutation, shows toast, and redirects to new flow show page', async () => {
      const handler = jest.fn().mockResolvedValue(mockCreateAiCatalogFlowSuccessMutation);
      const { wrapper, router, toast } = mountFlowDuplicate({ mutationHandler: handler });

      await submitFlowForm(wrapper, mockDuplicateFormValues);
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith({ input: mockDuplicateFormValues });
      expect(toast.show).toHaveBeenCalledWith('Flow created.');
      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.flowShow.name);
      expect(String(router.currentRoute.params.id)).toBe(
        String(
          getIdFromGraphQLId(
            mockCreateAiCatalogFlowSuccessMutation.data.aiCatalogFlowCreate.item.id,
          ),
        ),
      );
    });
  });

  describe('permissions-based redirections', () => {
    it('redirects to show page when user lacks duplicate permission', async () => {
      // Pre-navigate before mounting so $route.params.id is set when created() runs
      // Vue Router 4 (Vue 3) navigation is async; awaiting ensures params are populated at mount time
      const router = createMockRouter(ROUTE_PRESETS.flowDuplicate);
      await waitForPromises();

      mountFlowDuplicate({
        flow: { ...mockFlow, userPermissions: { adminAiCatalogItem: false } },
        router,
      });
      await waitForPromises();

      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.flowShow.name);
    });

    it('does not redirect when user has duplicate permission', async () => {
      const { router } = mountFlowDuplicate();
      await waitForPromises();

      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.flowDuplicate.name);
    });
  });
});
