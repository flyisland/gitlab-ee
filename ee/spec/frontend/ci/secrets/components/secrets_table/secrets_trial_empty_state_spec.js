import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlEmptyState } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import * as urlUtils from '~/lib/utils/url_utility';
import SecretsTrialEmptyState from 'ee/ci/secrets/components/secrets_table/secrets_trial_empty_state.vue';
import startTrialMutation from 'ee/ci/secrets/graphql/mutations/start_secrets_manager_trial.mutation.graphql';
import { startTrialSuccessResponse, startTrialErrorResponse } from '../../mock_data';

jest.mock('~/alert');

Vue.use(VueApollo);

describe('SecretsTrialEmptyState component', () => {
  let wrapper;
  let mockStartTrial;

  const mockToastShow = jest.fn();

  const createComponent = ({ isOpenbaoHealthy = true, isSaas = false } = {}) => {
    const apolloProvider = createMockApollo([[startTrialMutation, mockStartTrial]]);

    wrapper = shallowMountExtended(SecretsTrialEmptyState, {
      apolloProvider,
      provide: {
        enrollmentSettingsPath: '/group/-/edit#js-permissions-settings',
        isOpenbaoHealthy,
        isSaas,
        topLevelGroupFullPath: 'top-level-group',
      },
      mocks: {
        $toast: { show: mockToastShow },
      },
    });
  };

  const findEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findStartTrialButton = () => wrapper.findByTestId('start-trial-button');
  const findEnableAddonButton = () => wrapper.findByTestId('enable-addon-button');
  const findConfigureOpenbaoLink = () => wrapper.findByTestId('configure-openbao-link');

  const itRendersTrialButtons = () => {
    it('renders the start trial and enable add-on buttons', () => {
      expect(findStartTrialButton().exists()).toBe(true);

      expect(findEnableAddonButton().exists()).toBe(true);
      expect(findEnableAddonButton().attributes('href')).toBe(
        '/group/-/edit#js-permissions-settings',
      );
    });

    it('does not render the configure openbao link', () => {
      expect(findConfigureOpenbaoLink().exists()).toBe(false);
    });
  };

  beforeEach(() => {
    mockStartTrial = jest.fn();
    mockStartTrial.mockResolvedValue(startTrialSuccessResponse());

    jest.spyOn(urlUtils, 'refreshCurrentPage').mockImplementation(() => '');
  });

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders title and description', () => {
      expect(findEmptyState().props('title')).toBe('Introducing GitLab Secrets Manager');
      expect(findEmptyState().props('description')).toBe(
        'Use the GitLab Secrets Manager to securely store and manage secrets and credentials for your projects and groups.',
      );
    });
  });

  describe('when OpenBao is healthy', () => {
    beforeEach(() => {
      createComponent({ isOpenbaoHealthy: true });
    });

    itRendersTrialButtons();
  });

  describe('when OpenBao is unhealthy', () => {
    describe('if on SaaS', () => {
      beforeEach(() => {
        createComponent({ isOpenbaoHealthy: false, isSaas: true });
      });

      itRendersTrialButtons();
    });

    describe('if on self-managed', () => {
      beforeEach(() => {
        createComponent({ isOpenbaoHealthy: false, isSaas: false });
      });

      it('renders the configure openbao link', () => {
        expect(findConfigureOpenbaoLink().attributes('href')).toBe(
          '/help/administration/secrets_manager/_index',
        );
      });

      it('does not render the start trial and enable add-on buttons', () => {
        expect(findStartTrialButton().exists()).toBe(false);
        expect(findEnableAddonButton().exists()).toBe(false);
      });
    });
  });

  describe('startTrial mutation', () => {
    describe('when mutation is loading', () => {
      beforeEach(() => {
        createComponent();
      });

      it('shows loading state while mutation is in progress', async () => {
        expect(findStartTrialButton().props('loading')).toBe(false);

        findStartTrialButton().vm.$emit('click');
        await nextTick();

        expect(findStartTrialButton().props('loading')).toBe(true);

        await waitForPromises();

        expect(findStartTrialButton().props('loading')).toBe(false);
      });
    });

    describe('when mutation succeeds', () => {
      beforeEach(async () => {
        createComponent();

        findStartTrialButton().vm.$emit('click');
        await waitForPromises();
      });

      it('calls the mutation with the correct variables', () => {
        expect(mockStartTrial).toHaveBeenCalledWith({ groupPath: 'top-level-group' });
      });

      it('shows a toast message', () => {
        expect(mockToastShow).toHaveBeenCalledWith(
          'Trial enabled. Redirecting to secrets manager...',
        );
      });

      it('refreshes the page', () => {
        expect(urlUtils.refreshCurrentPage).toHaveBeenCalled();
      });
    });

    describe('when mutation returns errors', () => {
      beforeEach(async () => {
        mockStartTrial.mockResolvedValue(startTrialErrorResponse(['This group is not eligible']));
        createComponent();

        findStartTrialButton().vm.$emit('click');
        await waitForPromises();
      });

      it('shows an alert with the error message', () => {
        expect(createAlert).toHaveBeenCalledWith({
          message: 'This group is not eligible',
        });
      });

      it('does not refresh the page', () => {
        expect(urlUtils.refreshCurrentPage).not.toHaveBeenCalled();
      });
    });

    describe('when mutation throws a network error', () => {
      beforeEach(async () => {
        mockStartTrial.mockRejectedValue(new Error('Network error'));
        createComponent();

        findStartTrialButton().vm.$emit('click');
        await waitForPromises();
      });

      it('shows a generic error alert', () => {
        expect(createAlert).toHaveBeenCalledWith({
          message: 'An error occurred while starting the trial.',
          captureError: true,
          error: expect.any(Error),
        });
      });

      it('does not refresh the page', () => {
        expect(urlUtils.refreshCurrentPage).not.toHaveBeenCalled();
      });
    });
  });
});
