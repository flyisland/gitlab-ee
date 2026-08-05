import { GlSprintf } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import VueRouter from 'vue-router';
import Vue, { nextTick } from 'vue';
import { createAlert } from '~/alert';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createRouter from 'ee/ci/secrets/router';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import SecretsApp from 'ee/ci/secrets/components/secrets_app.vue';
import { SECRETS_MANAGER_CONTEXT_CONFIG } from 'ee/ci/secrets/context_config';
import getOpenbaoHealthQuery from 'ee/ci/secrets/graphql/queries/get_openbao_health.query.graphql';
import getEntitlementQuery from 'ee/ci/secrets/graphql/queries/get_secrets_manager_entitlement.graphql';
import {
  POLL_INTERVAL,
  ENTITY_GROUP,
  ENTITY_PROJECT,
  SECRET_MANAGER_STATUS_ACTIVE,
  SECRET_MANAGER_STATUS_PROVISIONING,
} from 'ee/ci/secrets/constants';
import {
  entitlementResponse,
  openbaoHealthResponse,
  secretManagerStatusResponse,
} from '../mock_data';

jest.mock('~/alert');

describe('SecretsApp', () => {
  let wrapper;
  let apolloProvider;
  let mockSecretManagerStatus;
  let mockOpenbaoHealth;
  let mockEntitlementQuery;

  Vue.use(VueRouter);
  Vue.use(VueApollo);
  const mockToastShow = jest.fn();

  const findRouterView = () => wrapper.findComponent({ ref: 'router-view' });

  const defaultProvide = {
    fullPath: '/path/to/entity',
    topLevelGroupFullPath: '',
  };

  const createComponent = async ({
    stubs,
    router,
    provide,
    isLoading = false,
    context = ENTITY_PROJECT,
  } = {}) => {
    const contextConfig = SECRETS_MANAGER_CONTEXT_CONFIG[context];
    const handlers = [
      [contextConfig.getStatus.query, mockSecretManagerStatus],
      [getOpenbaoHealthQuery, mockOpenbaoHealth],
      [getEntitlementQuery, mockEntitlementQuery],
      [
        contextConfig.getSecrets.query,
        jest.fn().mockResolvedValue({ data: { secretsList: { edges: [] } } }),
      ],
      [
        contextConfig.getSecretsNeedingRotation.query,
        jest.fn().mockResolvedValue({ data: { secretsNeedingRotation: { nodes: [] } } }),
      ],
    ];

    apolloProvider = createMockApollo(handlers);

    wrapper = mountExtended(SecretsApp, {
      router,
      provide: {
        contextConfig,
        ...defaultProvide,
        ...provide,
      },
      stubs,
      apolloProvider,
      mocks: {
        $toast: { show: mockToastShow },
      },
    });

    if (!isLoading) {
      await waitForPromises();
      await nextTick();
    }
  };

  const createPaidExperienceComponent = async (provide = {}) => {
    await createComponent({
      provide: {
        glFeatures: {
          secretsManagerPaidExperience: true,
        },
        topLevelGroupFullPath: 'top-level-group',
        ...provide,
      },
      stubs: {
        GlSprintf,
        RouterView: true,
      },
    });
  };

  const findEmptyStateNewSecretBtn = () => wrapper.findByTestId('empty-state-new-secret-button');
  const findLoadingIcon = () => wrapper.findByTestId('secrets-manager-loading-status');
  const findProvisioningText = () => wrapper.findByTestId('secrets-manager-provisioning-text');

  const advanceToNextFetch = (milliseconds) => {
    jest.advanceTimersByTime(milliseconds);
  };

  const pollNextStatus = async (status, context = 'project') => {
    mockSecretManagerStatus.mockResolvedValue(secretManagerStatusResponse(status, context));
    advanceToNextFetch(POLL_INTERVAL);

    await waitForPromises();
    await nextTick();
  };

  beforeEach(() => {
    mockSecretManagerStatus = jest.fn();
    mockOpenbaoHealth = jest.fn();
    mockEntitlementQuery = jest.fn().mockResolvedValue(entitlementResponse({ state: 'TRIAL' }));

    mockSecretManagerStatus.mockResolvedValue(
      secretManagerStatusResponse(SECRET_MANAGER_STATUS_ACTIVE),
    );
    mockOpenbaoHealth.mockResolvedValue(openbaoHealthResponse(true));
  });

  const createRouterForTest = () => createRouter('/-/secrets');

  describe.each`
    context
    ${ENTITY_PROJECT}
    ${ENTITY_GROUP}
  `('SecretsApp in $context context', ({ context }) => {
    beforeEach(() => {
      mockSecretManagerStatus.mockClear();
      mockSecretManagerStatus.mockResolvedValue(
        secretManagerStatusResponse(SECRET_MANAGER_STATUS_ACTIVE, context),
      );
    });

    describe('skipping secrets manager status query', () => {
      it('skips status query while entitlement is loading', async () => {
        mockEntitlementQuery.mockReturnValue(new Promise(() => {}));
        await createComponent({
          provide: {
            glFeatures: { secretsManagerPaidExperience: true },
            topLevelGroupFullPath: 'top-level-group',
          },
          stubs: { RouterView: true },
          isLoading: true,
        });

        expect(mockSecretManagerStatus).not.toHaveBeenCalled();
        expect(findLoadingIcon().exists()).toBe(true);
      });

      it('skips status query when trial eligible', async () => {
        mockEntitlementQuery.mockResolvedValue(entitlementResponse({ state: 'TRIAL_ELIGIBLE' }));
        await createComponent({
          provide: {
            glFeatures: { secretsManagerPaidExperience: true },
            topLevelGroupFullPath: 'top-level-group',
          },
          stubs: { GlSprintf, RouterView: true },
        });

        expect(mockSecretManagerStatus).not.toHaveBeenCalled();
        expect(findLoadingIcon().exists()).toBe(false);
      });

      it('runs status query after entitlement resolves as non-trial-eligible', async () => {
        mockEntitlementQuery.mockResolvedValue(entitlementResponse({ state: 'TRIAL' }));
        await createComponent({
          provide: {
            glFeatures: { secretsManagerPaidExperience: true },
            topLevelGroupFullPath: 'top-level-group',
          },
          stubs: { RouterView: true },
        });

        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(1);
        expect(findLoadingIcon().exists()).toBe(false);
        expect(findRouterView().exists()).toBe(true);
      });

      it('does not show loading icon when status query returns null', async () => {
        mockEntitlementQuery.mockResolvedValue(entitlementResponse({ state: 'TRIAL' }));
        mockSecretManagerStatus.mockResolvedValue({ data: { secretsManager: null } });
        await createComponent({
          provide: {
            glFeatures: { secretsManagerPaidExperience: true },
            topLevelGroupFullPath: 'top-level-group',
          },
          stubs: { RouterView: true },
        });

        expect(findLoadingIcon().exists()).toBe(false);
        expect(findRouterView().exists()).toBe(true);
      });
    });

    describe('when secrets manager status is being fetched', () => {
      beforeEach(() => {
        createComponent({ stubs: { RouterView: true }, isLoading: true, context });
      });

      it('renders the loading state', () => {
        expect(findLoadingIcon().exists()).toBe(true);
      });

      it('does not render the provisioning state or the router view', () => {
        expect(findProvisioningText().exists()).toBe(false);
        expect(findRouterView().exists()).toBe(false);
      });
    });

    describe('when secrets manager is being provisioned', () => {
      beforeEach(async () => {
        mockSecretManagerStatus.mockResolvedValue(
          secretManagerStatusResponse(SECRET_MANAGER_STATUS_PROVISIONING, context),
        );
        await createComponent({ stubs: { RouterView: true }, context });
      });

      it('renders the provisioning state', () => {
        expect(findProvisioningText().exists()).toBe(true);
      });

      it('does not render the loading state or router view', () => {
        expect(findLoadingIcon().exists()).toBe(false);
        expect(findRouterView().exists()).toBe(false);
      });

      it('polls for updated status while provisioning', async () => {
        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(1);

        await pollNextStatus(SECRET_MANAGER_STATUS_PROVISIONING, context);

        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(2);
      });

      it('renders router view when provisioned', async () => {
        expect(findRouterView().exists()).toBe(false);
        expect(findProvisioningText().exists()).toBe(true);

        await pollNextStatus(SECRET_MANAGER_STATUS_ACTIVE, context);

        expect(findProvisioningText().exists()).toBe(false);
        expect(findRouterView().exists()).toBe(true);
      });

      it('stops polling when provisioned', async () => {
        await pollNextStatus(SECRET_MANAGER_STATUS_ACTIVE, context);

        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(2);

        await pollNextStatus(SECRET_MANAGER_STATUS_ACTIVE, context);
        await pollNextStatus(SECRET_MANAGER_STATUS_ACTIVE, context);
        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(2);
      });
    });

    describe('when secrets manager has been provisioned', () => {
      beforeEach(async () => {
        await createComponent({ stubs: { RouterView: true }, context });
      });

      it('renders the router view', () => {
        expect(findRouterView().exists()).toBe(true);
      });

      it('stops polling for status', async () => {
        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(1);

        await pollNextStatus(SECRET_MANAGER_STATUS_ACTIVE, context);

        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(1);
      });
    });

    describe('when secrets manager is not provisioned', () => {
      beforeEach(async () => {
        mockSecretManagerStatus.mockResolvedValue({ data: { secretsManager: null } });
        await createComponent({ stubs: { RouterView: true }, context });
      });

      it('stops polling', async () => {
        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(1);

        await pollNextStatus(null, context);

        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(1);
      });
    });

    describe('when there is an error with fetching the secrets manager status', () => {
      const error = new Error('GraphQL error: API error');

      beforeEach(async () => {
        mockSecretManagerStatus.mockRejectedValue(error);
        await createComponent({ stubs: { RouterView: true }, context });
      });

      it('renders an error message', () => {
        expect(createAlert).toHaveBeenCalledWith({
          message: 'API error',
          captureError: true,
          error,
        });
      });

      it('stops polling', async () => {
        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(1);

        advanceToNextFetch(POLL_INTERVAL);

        await waitForPromises();
        await nextTick();

        expect(mockSecretManagerStatus).toHaveBeenCalledTimes(1);
      });

      it('does not render the loading state or router view', () => {
        expect(findLoadingIcon().exists()).toBe(false);
        expect(findRouterView().exists()).toBe(false);
      });
    });

    describe('when entity is not archived or marked for deletion', () => {
      beforeEach(async () => {
        mockSecretManagerStatus.mockResolvedValue(
          secretManagerStatusResponse(SECRET_MANAGER_STATUS_ACTIVE, context, {
            archived: false,
            markedForDeletion: false,
          }),
        );

        await createComponent({
          context,
          router: createRouterForTest(context),
        });
      });

      it('shows action buttons', () => {
        expect(findEmptyStateNewSecretBtn().exists()).toBe(true);
      });
    });

    describe('when entity is archived', () => {
      beforeEach(async () => {
        mockSecretManagerStatus.mockResolvedValue(
          secretManagerStatusResponse(SECRET_MANAGER_STATUS_ACTIVE, context, {
            archived: true,
            markedForDeletion: false,
          }),
        );

        await createComponent({
          context,
          router: createRouterForTest(context),
        });
      });

      it('sets secrets manager to read-only mode by hiding action buttons', () => {
        expect(findEmptyStateNewSecretBtn().exists()).toBe(false);
      });
    });

    describe('when entity is marked for deletion', () => {
      beforeEach(async () => {
        mockSecretManagerStatus.mockResolvedValue(
          secretManagerStatusResponse(SECRET_MANAGER_STATUS_ACTIVE, context, {
            archived: false,
            markedForDeletion: true,
          }),
        );

        await createComponent({
          context,
          router: createRouterForTest(context),
        });
      });

      it('sets secrets manager to read-only mode by hiding action buttons', () => {
        expect(findEmptyStateNewSecretBtn().exists()).toBe(false);
      });
    });
  });

  describe('toast message', () => {
    beforeEach(async () => {
      await createComponent({
        router: createRouterForTest(ENTITY_PROJECT),
      });
    });

    it('renders toast message when show-secrets-toast is emitted', async () => {
      findRouterView().vm.$emit('show-secrets-toast', 'This is a toast message.');
      await nextTick();

      expect(mockToastShow).toHaveBeenCalledWith('This is a toast message.');
    });
  });

  describe('when OpenBao is unhealthy', () => {
    beforeEach(async () => {
      mockOpenbaoHealth.mockResolvedValue(openbaoHealthResponse(false));
      await createComponent({
        router: createRouterForTest(ENTITY_PROJECT),
      });
    });

    it('shows an alert with unhealthy message', () => {
      expect(createAlert).toHaveBeenCalledWith({
        title: 'Cannot connect to OpenBao',
        message:
          'Failed to connect with OpenBao. Secrets are currently unavailable, please try again later.',
      });
    });

    it('renders the router view', () => {
      expect(findRouterView().exists()).toBe(true);
    });

    it('redirects to index route when on a different route', async () => {
      const router = createRouterForTest(ENTITY_PROJECT);
      await router.push({ name: 'new' }).catch(() => {});

      mockOpenbaoHealth.mockResolvedValue(openbaoHealthResponse(false));
      await createComponent({ router });

      expect(router.currentRoute.name).toBe('index');
    });
  });

  describe('when OpenBao health query fails', () => {
    beforeEach(async () => {
      mockOpenbaoHealth.mockRejectedValue(new Error('Network error'));
      await createComponent({
        router: createRouter('/-/secrets'),
      });
    });

    it('shows an alert with unhealthy message', () => {
      expect(createAlert).toHaveBeenCalledWith({
        title: 'Cannot connect to OpenBao',
        message:
          'Failed to connect with OpenBao. Secrets are currently unavailable, please try again later.',
      });
    });

    it('renders the router view', () => {
      expect(findRouterView().exists()).toBe(true);
    });
  });

  describe('entitlement query', () => {
    it('calls the entitlement query with the correct variables', async () => {
      await createPaidExperienceComponent();

      expect(mockEntitlementQuery).toHaveBeenCalledWith({ fullPath: 'top-level-group' });
    });

    it('renders an error when entitlement query fails', async () => {
      const error = new Error('GraphQL error: Entitlement error');
      mockEntitlementQuery.mockRejectedValue(error);
      await createPaidExperienceComponent();

      expect(createAlert).toHaveBeenCalledWith({
        message: 'Entitlement error',
        captureError: true,
        error,
      });
    });

    it('skips the entitlement query when feature flag is disabled', async () => {
      await createPaidExperienceComponent({
        glFeatures: { secretsManagerPaidExperience: false },
      });

      expect(mockEntitlementQuery).not.toHaveBeenCalled();
    });

    it('skips the entitlement query when topLevelGroupFullPath is empty', async () => {
      await createPaidExperienceComponent({ topLevelGroupFullPath: '' });

      expect(mockEntitlementQuery).not.toHaveBeenCalled();
    });

    it('shows loading state when entitlement query is skipped but status is still loading', async () => {
      mockSecretManagerStatus.mockReturnValue(new Promise(() => {}));
      await createPaidExperienceComponent({ topLevelGroupFullPath: '' });

      expect(findLoadingIcon().exists()).toBe(true);
      expect(findRouterView().exists()).toBe(false);
    });

    it('sets read-only mode when entitlement state is blocked', async () => {
      mockEntitlementQuery.mockResolvedValue(
        entitlementResponse({ state: 'BLOCKED', blockedReason: 'TRIAL_EXPIRED' }),
      );
      await createPaidExperienceComponent();

      expect(findEmptyStateNewSecretBtn().exists()).toBe(false);
    });
  });
});
