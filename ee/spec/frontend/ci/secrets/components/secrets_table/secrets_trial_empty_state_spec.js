import { GlEmptyState } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SecretsTrialEmptyState from 'ee/ci/secrets/components/secrets_table/secrets_trial_empty_state.vue';

describe('SecretsTrialEmptyState component', () => {
  let wrapper;

  const createComponent = ({ isOpenbaoHealthy = true, isSaas = false } = {}) => {
    wrapper = shallowMountExtended(SecretsTrialEmptyState, {
      provide: {
        enrollmentSettingsPath: '/group/-/edit#js-permissions-settings',
        isOpenbaoHealthy,
        isSaas,
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
});
