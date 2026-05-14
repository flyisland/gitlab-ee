import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlModal, GlFormRadioGroup, GlTooltip } from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { isLoggedIn } from '~/lib/utils/common_utils';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AiCatalogItemActions from 'ee/ai/catalog/components/ai_catalog_item_actions.vue';
import AiCatalogItemConsumerModal from 'ee/ai/catalog/components/ai_catalog_item_consumer_modal.vue';
import aiCatalogProjectUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_project_user_permissions.query.graphql';
import aiCatalogGroupUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_group_user_permissions.query.graphql';
import aiCatalogProjectsMaintainerQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_projects_maintainer.query.graphql';
import {
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
  TRACK_EVENT_ENABLE_AI_CATALOG_ITEM,
  TRACK_EVENT_DISABLE_AI_CATALOG_ITEM,
  TRACK_EVENT_DELETE_AI_CATALOG_ITEM,
  TRACK_EVENT_DUPLICATE_AI_CATALOG_ITEM,
  TRACK_EVENT_ITEM_TYPES,
  TRACK_EVENT_ORIGIN_EXPLORE,
  TRACK_EVENT_ORIGIN_PROJECT,
  TRACK_EVENT_ORIGIN_GROUP,
  TRACK_EVENT_PAGE_SHOW,
} from 'ee/ai/catalog/constants';
import {
  mockAgent,
  mockProjectsMaintainerResponse,
  mockProjectUserPermissionsResponse,
  mockProjectUserPermissionsNotAdminResponse,
  mockGroupUserPermissionsResponse,
  mockGroupUserPermissionsNotAdminResponse,
} from '../mock_data';

jest.mock('~/lib/utils/common_utils');
jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);

describe('AiCatalogItemActions', () => {
  let wrapper;
  let mockApollo;

  const defaultProps = {
    item: mockAgent,
    itemRoutes: {
      duplicate: '/items/:id/duplicate',
      edit: '/items/:id/edit',
      run: '/items/:id/run',
    },
    deleteFn: jest.fn(),
  };
  const routeParams = { id: '4' };

  const { bindInternalEventDocument } = useMockInternalEventsTracking();

  const mockProjectUserPermissionsQueryHandler = jest
    .fn()
    .mockResolvedValue(mockProjectUserPermissionsResponse);
  const mockProjectUserPermissionsNotAdminQueryHandler = jest
    .fn()
    .mockResolvedValue(mockProjectUserPermissionsNotAdminResponse);
  const mockGroupUserPermissionsQueryHandler = jest
    .fn()
    .mockResolvedValue(mockGroupUserPermissionsResponse);
  const mockGroupUserPermissionsNotAdminQueryHandler = jest
    .fn()
    .mockResolvedValue(mockGroupUserPermissionsNotAdminResponse);
  const mockProjectsMaintainerQueryHandler = jest
    .fn()
    .mockResolvedValue(mockProjectsMaintainerResponse);

  const defaultProvide = {
    isGlobalNamespace: false,
    isProjectNamespace: false,
    isGroupNamespace: false,
  };

  const createComponent = ({
    props = {},
    provide = {},
    projectUserPermissionsHandler = mockProjectUserPermissionsQueryHandler,
    glAbilities = {},
    glFeatures = {},
    groupUserPermissionsHandler = mockGroupUserPermissionsQueryHandler,
  } = {}) => {
    mockApollo = createMockApollo([
      [aiCatalogProjectUserPermissionsQuery, projectUserPermissionsHandler],
      [aiCatalogGroupUserPermissionsQuery, groupUserPermissionsHandler],
      [aiCatalogProjectsMaintainerQuery, mockProjectsMaintainerQueryHandler],
    ]);

    wrapper = shallowMountExtended(AiCatalogItemActions, {
      apolloProvider: mockApollo,
      propsData: {
        ...defaultProps,
        ...props,
      },
      provide: { ...defaultProvide, ...provide },
      mocks: {
        $route: {
          params: routeParams,
        },
        $router: {
          push: jest.fn(),
        },
        glAbilities,
        glFeatures,
      },
      stubs: { GlModal },
    });
  };

  const findEditButton = () => wrapper.findByTestId('edit-button');
  const findDisableButton = () => wrapper.findByTestId('disable-button');
  const findEnableButton = () => wrapper.findByTestId('enable-button');
  const findMoreActions = () => wrapper.findByTestId('more-actions-dropdown');
  const findDuplicateButton = () => wrapper.findByTestId('duplicate-button');
  const findReportButton = () => wrapper.findByTestId('report-button');
  const findDeleteButton = () => wrapper.findByTestId('delete-button');
  const findDeleteModal = () => wrapper.findByTestId('delete-item-modal');
  const findDropdownTooltip = () => wrapper.findComponent(GlTooltip);
  const findConsumerModal = () => wrapper.findComponent(AiCatalogItemConsumerModal);

  const openDeleteModal = async () => {
    findDeleteButton().vm.$emit('action');
    await nextTick();
  };

  describe('component rendering', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders "More actions" tooltip', () => {
      expect(findDropdownTooltip().text()).toBe('More actions');
    });
  });

  describe('report button visibility', () => {
    it('renders when user has reportAiCatalogItem permission and item is not foundational', () => {
      createComponent({
        props: {
          item: {
            ...mockAgent,
            foundational: false,
            userPermissions: { reportAiCatalogItem: true },
          },
        },
      });

      expect(findReportButton().exists()).toBe(true);
    });

    it('does not render when item is foundational', () => {
      createComponent({
        props: {
          item: {
            ...mockAgent,
            foundational: true,
            userPermissions: { reportAiCatalogItem: true },
          },
        },
      });

      expect(findReportButton().exists()).toBe(false);
    });

    it('does not render when user lacks reportAiCatalogItem permission', () => {
      createComponent({
        props: {
          item: {
            ...mockAgent,
            foundational: false,
            userPermissions: { reportAiCatalogItem: false },
          },
        },
      });

      expect(findReportButton().exists()).toBe(false);
    });
  });

  describe('at the Explore level', () => {
    beforeEach(async () => {
      createComponent({
        provide: { isGlobalNamespace: true },
      });
      await waitForPromises();
    });

    it('does not fetch project permissions', () => {
      expect(mockProjectUserPermissionsQueryHandler).not.toHaveBeenCalled();
    });

    it('checks if user is maintainer of at least one project', () => {
      expect(mockProjectsMaintainerQueryHandler).toHaveBeenCalled();
    });

    it('does not render AiCatalogItemConsumerModal', () => {
      expect(findConsumerModal().exists()).toBe(false);
    });

    describe('when user is logged in', () => {
      beforeEach(async () => {
        isLoggedIn.mockReturnValue(true);
        createComponent({
          provide: { isGlobalNamespace: true },
        });
        await waitForPromises();
      });

      it('renders AiCatalogItemConsumerModal', () => {
        expect(findConsumerModal().props('canEnable')).toBe(true);
      });
    });
  });

  describe('at the Project level', () => {
    beforeEach(async () => {
      isLoggedIn.mockReturnValue(true);
      createComponent({
        provide: {
          isGlobalNamespace: false,
          isProjectNamespace: true,
          projectPath: 'gitlab-duo/test',
        },
      });
      await waitForPromises();
    });

    it('fetched project permissions', () => {
      expect(mockProjectUserPermissionsQueryHandler).toHaveBeenCalled();
    });

    it('does not check if user is maintainer of at least one project', () => {
      expect(mockProjectsMaintainerQueryHandler).not.toHaveBeenCalled();
    });

    it('renders AiCatalogItemConsumerModal', () => {
      expect(findConsumerModal().props('canEnable')).toBe(true);
    });
  });

  describe.each`
    scenario                                      | canAdmin | canUse   | foundational | editBtn  | disableBtn | enableBtn | moreActions | duplicateBtn | deleteBtn | itemType
    ${'not logged in'}                            | ${false} | ${false} | ${false}     | ${false} | ${false}   | ${false}  | ${false}    | ${false}     | ${false}  | ${AI_CATALOG_TYPE_AGENT}
    ${'logged in, not admin of item'}             | ${false} | ${true}  | ${false}     | ${false} | ${false}   | ${true}   | ${true}     | ${true}      | ${false}  | ${AI_CATALOG_TYPE_AGENT}
    ${'logged in, admin of item'}                 | ${true}  | ${true}  | ${false}     | ${true}  | ${false}   | ${true}   | ${true}     | ${true}      | ${true}   | ${AI_CATALOG_TYPE_AGENT}
    ${'logged in, admin of flow item'}            | ${true}  | ${true}  | ${false}     | ${true}  | ${false}   | ${true}   | ${true}     | ${true}      | ${true}   | ${AI_CATALOG_TYPE_FLOW}
    ${'logged in, foundational agent'}            | ${false} | ${true}  | ${true}      | ${false} | ${false}   | ${false}  | ${true}     | ${true}      | ${false}  | ${AI_CATALOG_TYPE_AGENT}
    ${'logged in, admin foundational agent'}      | ${true}  | ${true}  | ${true}      | ${true}  | ${false}   | ${false}  | ${true}     | ${true}      | ${true}   | ${AI_CATALOG_TYPE_AGENT}
    ${'logged in, foundational flow'}             | ${false} | ${true}  | ${true}      | ${false} | ${false}   | ${false}  | ${false}    | ${false}     | ${false}  | ${AI_CATALOG_TYPE_FLOW}
    ${'logged in, admin foundational flow'}       | ${true}  | ${true}  | ${true}      | ${true}  | ${false}   | ${false}  | ${true}     | ${false}     | ${true}   | ${AI_CATALOG_TYPE_FLOW}
    ${'logged in, foundational third-party flow'} | ${false} | ${true}  | ${true}      | ${false} | ${false}   | ${true}   | ${false}    | ${false}     | ${false}  | ${AI_CATALOG_TYPE_THIRD_PARTY_FLOW}
  `(
    'at the Explore level, when $scenario',
    ({
      canAdmin,
      canUse,
      foundational,
      editBtn,
      disableBtn,
      enableBtn,
      moreActions,
      duplicateBtn,
      deleteBtn,
      itemType,
    }) => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockAgent,
              itemType,
              foundational,
              userPermissions: {
                adminAiCatalogItem: canAdmin,
              },
              configurationForProject: {
                id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
              },
            },
            itemRoutes: {
              ...defaultProps.itemRoutes,
            },
          },
          provide: {
            isGlobalNamespace: true,
          },
        });
        isLoggedIn.mockReturnValue(canUse);
      });

      it(`${editBtn ? 'renders' : 'does not render'} Edit button`, () => {
        expect(findEditButton().exists()).toBe(editBtn);
        if (editBtn) {
          expect(findEditButton().props('to')).toMatchObject({
            name: defaultProps.itemRoutes.edit,
            params: { id: routeParams.id },
          });
        }
      });

      it(`${disableBtn ? 'renders' : 'does not render'} "Disable" button`, () => {
        expect(findDisableButton().exists()).toBe(disableBtn);
      });

      it(`${enableBtn ? 'renders' : 'does not render'} "Enable" button`, () => {
        expect(findEnableButton().exists()).toBe(enableBtn);
      });

      it(`${moreActions ? 'renders' : 'does not render'} more actions`, () => {
        expect(findMoreActions().exists()).toBe(moreActions);
      });

      it(`${duplicateBtn ? 'renders' : 'does not render'} Duplicate button`, () => {
        expect(findDuplicateButton().exists()).toBe(duplicateBtn);
      });

      it(`${deleteBtn ? 'renders' : 'does not render'} Delete button`, () => {
        expect(findDeleteButton().exists()).toBe(deleteBtn);
      });
    },
  );

  describe.each`
    scenario                                         | canAdmin | canUse   | foundational | editBtn  | disableBtn | enableBtn | moreActions | duplicateBtn | deleteBtn | itemType                 | isGlobalNamespace | isEnabled
    ${'not logged in'}                               | ${false} | ${false} | ${false}     | ${false} | ${false}   | ${false}  | ${false}    | ${false}     | ${false}  | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${false}
    ${'logged in, not admin of item'}                | ${false} | ${true}  | ${false}     | ${false} | ${false}   | ${false}  | ${false}    | ${false}     | ${false}  | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${true}
    ${'logged in, admin of item'}                    | ${true}  | ${true}  | ${false}     | ${true}  | ${false}   | ${true}   | ${true}     | ${true}      | ${true}   | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${false}
    ${'logged in, admin of enabled item'}            | ${true}  | ${true}  | ${false}     | ${true}  | ${true}    | ${true}   | ${true}     | ${true}      | ${true}   | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${true}
    ${'logged in, admin of flow item'}               | ${true}  | ${true}  | ${false}     | ${true}  | ${true}    | ${true}   | ${true}     | ${true}      | ${true}   | ${AI_CATALOG_TYPE_FLOW}  | ${false}          | ${true}
    ${'logged in, foundational agent'}               | ${false} | ${true}  | ${true}      | ${false} | ${false}   | ${false}  | ${false}    | ${false}     | ${false}  | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${false}
    ${'logged in, admin of foundational agent'}      | ${true}  | ${true}  | ${true}      | ${true}  | ${false}   | ${false}  | ${true}     | ${true}      | ${true}   | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${true}
    ${'logged in, admin enabled foundational agent'} | ${true}  | ${true}  | ${true}      | ${true}  | ${false}   | ${false}  | ${true}     | ${true}      | ${true}   | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${true}
    ${'logged in, admin of foundational flow item'}  | ${true}  | ${true}  | ${true}      | ${true}  | ${true}    | ${true}   | ${true}     | ${false}     | ${true}   | ${AI_CATALOG_TYPE_FLOW}  | ${false}          | ${true}
  `(
    'at the Project level, when $scenario',
    ({
      canAdmin,
      canUse,
      foundational,
      editBtn,
      disableBtn,
      enableBtn,
      moreActions,
      duplicateBtn,
      deleteBtn,
      itemType,
      isEnabled,
    }) => {
      beforeEach(async () => {
        const permissionsHandler = canAdmin
          ? mockProjectUserPermissionsQueryHandler
          : mockProjectUserPermissionsNotAdminQueryHandler;
        createComponent({
          projectUserPermissionsHandler: permissionsHandler,
          props: {
            item: {
              ...mockAgent,
              itemType,
              foundational,
              userPermissions: {
                adminAiCatalogItem: canAdmin,
              },
              configurationForProject: {
                id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                enabled: isEnabled,
              },
            },
            itemRoutes: {
              ...defaultProps.itemRoutes,
            },
          },
          provide: {
            isGlobalNamespace: false,
            isProjectNamespace: true,
            projectPath: 'gitlab-duo/test',
          },
        });
        isLoggedIn.mockReturnValue(canUse);

        await waitForPromises();
      });

      it(`${editBtn ? 'renders' : 'does not render'} Edit button`, () => {
        expect(findEditButton().exists()).toBe(editBtn);
        if (editBtn) {
          expect(findEditButton().props('to')).toMatchObject({
            name: defaultProps.itemRoutes.edit,
            params: { id: routeParams.id },
          });
        }
      });

      it(`${disableBtn ? 'renders' : 'does not render'} "Disable" button`, () => {
        expect(findDisableButton().exists()).toBe(disableBtn);
      });

      it(`${enableBtn ? 'renders' : 'does not render'} "Enable" button`, () => {
        expect(findEnableButton().exists()).toBe(enableBtn);
      });

      it(`${moreActions ? 'renders' : 'does not render'} more actions`, () => {
        expect(findMoreActions().exists()).toBe(moreActions);
      });

      it(`${duplicateBtn ? 'renders' : 'does not render'} Duplicate button`, () => {
        expect(findDuplicateButton().exists()).toBe(duplicateBtn);
      });

      it(`${deleteBtn ? 'renders' : 'does not render'} Delete button`, () => {
        expect(findDeleteButton().exists()).toBe(deleteBtn);
      });
    },
  );

  describe('at the Group level', () => {
    it('fetches group permissions', async () => {
      createComponent({
        provide: { isGlobalNamespace: false, isGroupNamespace: true, groupPath: 'test-group' },
      });
      await waitForPromises();
      expect(mockGroupUserPermissionsQueryHandler).toHaveBeenCalled();
    });

    describe('when viewing an enabled item', () => {
      describe.each`
        scenario                              | canAdmin | canUse   | disableBtn | moreActions | itemType                 | isEnabled
        ${'not logged in'}                    | ${false} | ${false} | ${false}   | ${false}    | ${AI_CATALOG_TYPE_AGENT} | ${true}
        ${'logged in, not admin of item'}     | ${false} | ${true}  | ${false}   | ${false}    | ${AI_CATALOG_TYPE_AGENT} | ${true}
        ${'logged in, admin of enabled item'} | ${true}  | ${true}  | ${true}    | ${true}     | ${AI_CATALOG_TYPE_AGENT} | ${true}
      `('when $scenario', ({ canAdmin, canUse, disableBtn, moreActions, itemType, isEnabled }) => {
        beforeEach(async () => {
          const permissionsHandler = canAdmin
            ? mockGroupUserPermissionsQueryHandler
            : mockGroupUserPermissionsNotAdminQueryHandler;
          createComponent({
            groupUserPermissionsHandler: permissionsHandler,
            props: {
              item: {
                ...mockAgent,
                itemType,
                userPermissions: {
                  adminAiCatalogItem: false,
                },
                configurationForGroup: {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                  enabled: isEnabled,
                },
              },
              itemRoutes: {
                ...defaultProps.itemRoutes,
              },
            },
            provide: {
              isGlobalNamespace: false,
              isGroupNamespace: true,
              groupPath: 'test-group',
            },
          });
          isLoggedIn.mockReturnValue(canUse);

          await waitForPromises();
        });

        it('does not render Edit button', () => {
          expect(findEditButton().exists()).toBe(false);
        });

        it(`${disableBtn ? 'renders' : 'does not render'} "Disable" button`, () => {
          expect(findDisableButton().exists()).toBe(disableBtn);
        });

        it('does not render "Enable" button', () => {
          expect(findEnableButton().exists()).toBe(false);
        });

        it(`${moreActions ? 'renders' : 'does not render'} more actions`, () => {
          expect(findMoreActions().exists()).toBe(moreActions);
        });

        it('does not render Duplicate button', () => {
          expect(findDuplicateButton().exists()).toBe(false);
        });

        it('does not render Report button', () => {
          expect(findReportButton().exists()).toBe(false);
        });

        it('does not render Delete button', () => {
          expect(findDeleteButton().exists()).toBe(false);
        });
      });
    });

    describe('when viewing a disabled item', () => {
      describe.each`
        scenario                          | canAdmin | canUse   | itemType                 | isEnabled
        ${'not logged in'}                | ${false} | ${false} | ${AI_CATALOG_TYPE_AGENT} | ${false}
        ${'logged in, not admin of item'} | ${false} | ${true}  | ${AI_CATALOG_TYPE_AGENT} | ${false}
        ${'logged in, admin of item'}     | ${true}  | ${true}  | ${AI_CATALOG_TYPE_AGENT} | ${false}
      `('when $scenario', ({ canAdmin, canUse, itemType, isEnabled }) => {
        beforeEach(async () => {
          const permissionsHandler = canAdmin
            ? mockGroupUserPermissionsQueryHandler
            : mockGroupUserPermissionsNotAdminQueryHandler;
          createComponent({
            groupUserPermissionsHandler: permissionsHandler,
            props: {
              item: {
                ...mockAgent,
                itemType,
                userPermissions: {
                  adminAiCatalogItem: false,
                },
                configurationForGroup: {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                  enabled: isEnabled,
                },
              },
              itemRoutes: {
                ...defaultProps.itemRoutes,
              },
            },
            provide: {
              isGlobalNamespace: false,
              isGroupNamespace: true,
              groupPath: 'test-group',
            },
          });
          isLoggedIn.mockReturnValue(canUse);

          await waitForPromises();
        });

        it('does not render Edit button', () => {
          expect(findEditButton().exists()).toBe(false);
        });

        it('does not render "Enable" button', () => {
          expect(findEnableButton().exists()).toBe(false);
        });

        it('does not render "Disable" button', () => {
          expect(findDisableButton().exists()).toBe(false);
        });

        it('does not render more actions', () => {
          expect(findMoreActions().exists()).toBe(false);
        });

        it('does not render Duplicate button', () => {
          expect(findDuplicateButton().exists()).toBe(false);
        });

        it('does not render Report button', () => {
          expect(findReportButton().exists()).toBe(false);
        });

        it('does not render Delete button', () => {
          expect(findDeleteButton().exists()).toBe(false);
        });
      });
    });
  });

  describe('delete modal', () => {
    describe('when user can hard delete', () => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockAgent,
              userPermissions: {
                adminAiCatalogItem: true,
                forceHardDeleteAiCatalogItem: true,
              },
            },
          },
        });
      });

      it('displays deletion method radio buttons', async () => {
        await openDeleteModal();

        expect(findDeleteModal().exists()).toBe(true);
        expect(findDeleteModal().findComponent(GlFormRadioGroup).exists()).toBe(true);
      });

      it('displays deletion method radio buttons with hard delete option selected', async () => {
        await openDeleteModal();

        const radioGroup = findDeleteModal().findComponent(GlFormRadioGroup);
        expect(radioGroup.attributes('checked')).toBe('true');
      });

      it('calls deleteFn with forceHardDelete set to true if hard delete is selected', async () => {
        await openDeleteModal();

        const deleteModal = findDeleteModal();
        const radioGroup = deleteModal.findComponent(GlFormRadioGroup);
        radioGroup.vm.$emit('input', true);

        await nextTick();

        const actionFn = deleteModal.props('actionFn');
        await actionFn();

        expect(defaultProps.deleteFn).toHaveBeenCalledWith(true);
      });

      it('calls deleteFn with forceHardDelete set to false if soft delete is selected', async () => {
        await openDeleteModal();

        const deleteModal = findDeleteModal();
        const radioGroup = deleteModal.findComponent(GlFormRadioGroup);
        radioGroup.vm.$emit('input', false);

        await nextTick();

        const actionFn = deleteModal.props('actionFn');
        await actionFn();

        expect(defaultProps.deleteFn).toHaveBeenCalledWith(false);
      });
    });

    describe('when user cannot hard delete', () => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockAgent,
              userPermissions: {
                adminAiCatalogItem: true,
                forceHardDeleteAiCatalogItem: false,
              },
            },
          },
        });
      });

      it('does not display deletion method radio buttons', async () => {
        await openDeleteModal();

        expect(findDeleteModal().findComponent(GlFormRadioGroup).exists()).toBe(false);
      });

      it('calls deleteFn with forceHardDelete set to false', async () => {
        await openDeleteModal();

        const deleteModal = findDeleteModal();
        const actionFn = deleteModal.props('actionFn');
        await actionFn();

        expect(defaultProps.deleteFn).toHaveBeenCalledWith(false);
      });
    });
  });

  describe('tracking', () => {
    describe.each`
      scenario                           | itemType                 | isGlobalNamespace | isEnabled | buttonFinder        | expectedOrigin
      ${'Enable agent at Explore level'} | ${AI_CATALOG_TYPE_AGENT} | ${true}           | ${false}  | ${findEnableButton} | ${TRACK_EVENT_ORIGIN_EXPLORE}
      ${'Enable flow at Project level'}  | ${AI_CATALOG_TYPE_FLOW}  | ${false}          | ${false}  | ${findEnableButton} | ${TRACK_EVENT_ORIGIN_PROJECT}
    `(
      'when clicking $scenario',
      ({ itemType, isGlobalNamespace, isEnabled, buttonFinder, expectedOrigin }) => {
        beforeEach(async () => {
          isLoggedIn.mockReturnValue(true);
          createComponent({
            props: {
              item: {
                ...mockAgent,
                itemType,
                userPermissions: {
                  adminAiCatalogItem: true,
                },
                configurationForProject: {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                  enabled: isEnabled,
                },
              },
            },
            provide: {
              isGlobalNamespace,
              isProjectNamespace: !isGlobalNamespace,
              projectPath: 'gitlab-duo/test',
            },
          });
          await waitForPromises();
        });

        it(`tracks event  ${TRACK_EVENT_ENABLE_AI_CATALOG_ITEM} with correct properties`, async () => {
          const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

          await buttonFinder().vm.$emit('click');

          await nextTick();

          expect(trackEventSpy).toHaveBeenCalledWith(
            TRACK_EVENT_ENABLE_AI_CATALOG_ITEM,
            {
              label: TRACK_EVENT_ITEM_TYPES[itemType],
              origin: expectedOrigin,
              page: TRACK_EVENT_PAGE_SHOW,
            },
            undefined,
          );
        });
      },
    );

    describe.each`
      scenario                            | itemType                 | isGlobalNamespace | isEnabled | buttonFinder         | expectedOrigin                | projectPath          | groupPath
      ${'Disable agent at Project level'} | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${true}   | ${findDisableButton} | ${TRACK_EVENT_ORIGIN_PROJECT} | ${'gitlab-duo/test'} | ${undefined}
      ${'Disable flow at Project level'}  | ${AI_CATALOG_TYPE_FLOW}  | ${false}          | ${true}   | ${findDisableButton} | ${TRACK_EVENT_ORIGIN_PROJECT} | ${'gitlab-duo/test'} | ${undefined}
      ${'Disable agent at Group level'}   | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${true}   | ${findDisableButton} | ${TRACK_EVENT_ORIGIN_GROUP}   | ${undefined}         | ${'test-group'}
      ${'Disable flow at Group level'}    | ${AI_CATALOG_TYPE_FLOW}  | ${false}          | ${true}   | ${findDisableButton} | ${TRACK_EVENT_ORIGIN_GROUP}   | ${undefined}         | ${'test-group'}
    `(
      'when clicking $scenario',
      ({
        itemType,
        isGlobalNamespace,
        isEnabled,
        buttonFinder,
        expectedOrigin,
        projectPath,
        groupPath,
      }) => {
        beforeEach(async () => {
          isLoggedIn.mockReturnValue(true);
          createComponent({
            props: {
              item: {
                ...mockAgent,
                itemType,
                userPermissions: {
                  adminAiCatalogItem: true,
                },
                configurationForProject: {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                  enabled: isEnabled,
                },
                configurationForGroup: {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/2',
                  enabled: isEnabled,
                },
              },
              disableConfirmMessage: 'Are you sure you want to disable this agent?',
            },
            provide: {
              isGlobalNamespace,
              isProjectNamespace: Boolean(projectPath),
              isGroupNamespace: Boolean(groupPath),
              projectPath,
              groupPath,
            },
          });
          await waitForPromises();
        });

        it(`tracks event  ${TRACK_EVENT_DISABLE_AI_CATALOG_ITEM} with correct properties`, async () => {
          const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

          await buttonFinder().vm.$emit('action');

          await nextTick();

          expect(trackEventSpy).toHaveBeenCalledWith(
            TRACK_EVENT_DISABLE_AI_CATALOG_ITEM,
            {
              label: TRACK_EVENT_ITEM_TYPES[itemType],
              origin: expectedOrigin,
              page: TRACK_EVENT_PAGE_SHOW,
            },
            undefined,
          );
        });
      },
    );

    describe.each`
      scenario                           | itemType                 | isGlobalNamespace | isEnabled | buttonFinder        | expectedOrigin
      ${'Delete agent at Explore level'} | ${AI_CATALOG_TYPE_AGENT} | ${true}           | ${false}  | ${findDeleteButton} | ${TRACK_EVENT_ORIGIN_EXPLORE}
      ${'Delete flow at Project level'}  | ${AI_CATALOG_TYPE_FLOW}  | ${false}          | ${false}  | ${findDeleteButton} | ${TRACK_EVENT_ORIGIN_PROJECT}
      ${'Delete agent at Project level'} | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${false}  | ${findDeleteButton} | ${TRACK_EVENT_ORIGIN_PROJECT}
    `(
      'when clicking $scenario',
      ({ itemType, isGlobalNamespace, isEnabled, buttonFinder, expectedOrigin }) => {
        beforeEach(async () => {
          isLoggedIn.mockReturnValue(true);
          createComponent({
            props: {
              item: {
                ...mockAgent,
                itemType,
                userPermissions: {
                  adminAiCatalogItem: true,
                },
                configurationForProject: {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                  enabled: isEnabled,
                },
              },
            },
            provide: {
              isGlobalNamespace,
              isProjectNamespace: !isGlobalNamespace,
              projectPath: isGlobalNamespace ? undefined : 'gitlab-duo/test',
            },
          });
          await waitForPromises();
        });

        it(`tracks event  ${TRACK_EVENT_DELETE_AI_CATALOG_ITEM} with correct properties`, async () => {
          const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

          await buttonFinder().vm.$emit('action');

          await nextTick();

          expect(trackEventSpy).toHaveBeenCalledWith(
            TRACK_EVENT_DELETE_AI_CATALOG_ITEM,
            {
              label: TRACK_EVENT_ITEM_TYPES[itemType],
              origin: expectedOrigin,
              page: TRACK_EVENT_PAGE_SHOW,
            },
            undefined,
          );
        });
      },
    );

    describe.each`
      scenario                              | itemType                 | isGlobalNamespace | isEnabled | buttonFinder           | expectedOrigin
      ${'Duplicate agent at Explore level'} | ${AI_CATALOG_TYPE_AGENT} | ${true}           | ${false}  | ${findDuplicateButton} | ${TRACK_EVENT_ORIGIN_EXPLORE}
      ${'Duplicate flow at Project level'}  | ${AI_CATALOG_TYPE_FLOW}  | ${false}          | ${false}  | ${findDuplicateButton} | ${TRACK_EVENT_ORIGIN_PROJECT}
      ${'Duplicate agent at Project level'} | ${AI_CATALOG_TYPE_AGENT} | ${false}          | ${false}  | ${findDuplicateButton} | ${TRACK_EVENT_ORIGIN_PROJECT}
    `(
      'when clicking $scenario',
      ({ itemType, isGlobalNamespace, isEnabled, buttonFinder, expectedOrigin }) => {
        beforeEach(async () => {
          isLoggedIn.mockReturnValue(true);
          createComponent({
            props: {
              item: {
                ...mockAgent,
                itemType,
                userPermissions: {
                  adminAiCatalogItem: true,
                },
                configurationForProject: {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                  enabled: isEnabled,
                },
              },
            },
            provide: {
              isGlobalNamespace,
              isProjectNamespace: !isGlobalNamespace,
              projectPath: isGlobalNamespace ? undefined : 'gitlab-duo/test',
            },
          });
          await waitForPromises();
        });

        it(`tracks event  ${TRACK_EVENT_DUPLICATE_AI_CATALOG_ITEM} with correct properties`, async () => {
          const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

          await buttonFinder().vm.$emit('action');

          await nextTick();

          expect(trackEventSpy).toHaveBeenCalledWith(
            TRACK_EVENT_DUPLICATE_AI_CATALOG_ITEM,
            {
              label: TRACK_EVENT_ITEM_TYPES[itemType],
              origin: expectedOrigin,
              page: TRACK_EVENT_PAGE_SHOW,
            },
            undefined,
          );
        });
      },
    );
  });

  describe('third-party flow duplicate button visibility', () => {
    describe.each`
      scenario                                                 | itemType                            | glAbility | aiCatalogThirdPartyFlows | aiCatalogCreateThirdPartyFlows | shouldRender
      ${'THIRD_PARTY_FLOW with ability enabled'}               | ${AI_CATALOG_TYPE_THIRD_PARTY_FLOW} | ${true}   | ${false}                 | ${false}                       | ${true}
      ${'THIRD_PARTY_FLOW with feature flags enabled'}         | ${AI_CATALOG_TYPE_THIRD_PARTY_FLOW} | ${null}   | ${true}                  | ${true}                        | ${true}
      ${'THIRD_PARTY_FLOW with feature not available'}         | ${AI_CATALOG_TYPE_THIRD_PARTY_FLOW} | ${false}  | ${false}                 | ${false}                       | ${false}
      ${'THIRD_PARTY_FLOW with only one feature flag enabled'} | ${AI_CATALOG_TYPE_THIRD_PARTY_FLOW} | ${null}   | ${true}                  | ${false}                       | ${false}
      ${'non-THIRD_PARTY_FLOW with feature not available'}     | ${AI_CATALOG_TYPE_AGENT}            | ${false}  | ${false}                 | ${false}                       | ${true}
    `(
      'when $scenario',
      ({
        itemType,
        glAbility,
        aiCatalogThirdPartyFlows,
        aiCatalogCreateThirdPartyFlows,
        shouldRender,
      }) => {
        beforeEach(() => {
          isLoggedIn.mockReturnValue(true);
          createComponent({
            props: {
              item: {
                ...mockAgent,
                itemType,
                userPermissions: {
                  adminAiCatalogItem: true,
                },
              },
            },
            provide: {
              isGlobalNamespace: true,
              glAbilities: {
                createAiCatalogThirdPartyFlow: glAbility,
              },
              glFeatures: {
                aiCatalogThirdPartyFlows,
                aiCatalogCreateThirdPartyFlows,
              },
            },
          });
        });

        it(`${shouldRender ? 'renders' : 'does not render'} Duplicate button`, () => {
          expect(findDuplicateButton().exists()).toBe(shouldRender);
        });
      },
    );
  });

  describe('when Apollo permission queries fail', () => {
    const error = new Error('GraphQL error');

    it('reports projectUserPermissions query error to Sentry', async () => {
      createComponent({
        provide: { projectPath: 'group/project' },
        projectUserPermissionsHandler: jest.fn().mockRejectedValue(error),
      });
      await waitForPromises();

      expect(Sentry.captureException).toHaveBeenCalledWith(error);
    });

    it('reports groupUserPermissions query error to Sentry', async () => {
      createComponent({
        provide: { groupPath: 'group' },
        groupUserPermissionsHandler: jest.fn().mockRejectedValue(error),
      });
      await waitForPromises();

      expect(Sentry.captureException).toHaveBeenCalledWith(error);
    });
  });
});
