import { GlToggle } from '@gitlab/ui';
import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import SecretsManagerInstanceEnrollmentToggle from 'ee/admin/application_settings/general/secrets_manager_instance_enrollment/components/secrets_manager_instance_enrollment_toggle.vue';
import getInstanceSecretsManagerEnrollmentQuery from 'ee/admin/application_settings/general/secrets_manager_instance_enrollment/graphql/queries/get_instance_secrets_manager_enrollment.query.graphql';
import enrollInstanceSecretsManagerMutation from 'ee/admin/application_settings/general/secrets_manager_instance_enrollment/graphql/mutations/enroll_instance_secrets_manager.mutation.graphql';
import unenrollInstanceSecretsManagerMutation from 'ee/admin/application_settings/general/secrets_manager_instance_enrollment/graphql/mutations/unenroll_instance_secrets_manager.mutation.graphql';

Vue.use(VueApollo);
jest.mock('~/lib/logger');

describe('SecretsManagerInstanceEnrollmentToggle', () => {
  let wrapper;
  let mockEnrollmentQuery;
  let mockEnrollMutation;
  let mockUnenrollMutation;
  const mockToastShow = jest.fn();

  const enrollmentResponse = (enrolled) => ({
    data: { instanceSecretsManagerEnrollment: enrolled },
  });
  const enrollMutationResponse = (errors = []) => ({
    data: { instanceSecretsManagerEnroll: { errors } },
  });
  const unenrollMutationResponse = (errors = []) => ({
    data: { instanceSecretsManagerUnenroll: { errors } },
  });

  const findToggle = () => wrapper.findComponent(GlToggle);
  const findErrorAlert = () => wrapper.findByTestId('enrollment-error-alert');

  const flipToggle = async (value) => {
    findToggle().vm.$emit('change', value);
    await waitForPromises();
  };

  const createComponent = () => {
    const apolloProvider = createMockApollo([
      [getInstanceSecretsManagerEnrollmentQuery, mockEnrollmentQuery],
      [enrollInstanceSecretsManagerMutation, mockEnrollMutation],
      [unenrollInstanceSecretsManagerMutation, mockUnenrollMutation],
    ]);

    wrapper = shallowMountExtended(SecretsManagerInstanceEnrollmentToggle, {
      apolloProvider,
      mocks: {
        $toast: { show: mockToastShow },
      },
    });
  };

  beforeEach(() => {
    mockEnrollmentQuery = jest.fn().mockResolvedValue(enrollmentResponse(false));
    mockEnrollMutation = jest.fn().mockResolvedValue(enrollMutationResponse());
    mockUnenrollMutation = jest.fn().mockResolvedValue(unenrollMutationResponse());
    mockToastShow.mockClear();
  });

  describe('on mount', () => {
    it('queries the enrollment state', async () => {
      createComponent();
      await waitForPromises();

      expect(mockEnrollmentQuery).toHaveBeenCalledTimes(1);
      expect(findToggle().props('value')).toBe(false);
    });

    it('reflects an enrolled state', async () => {
      mockEnrollmentQuery.mockResolvedValueOnce(enrollmentResponse(true));
      createComponent();
      await waitForPromises();

      expect(findToggle().props('value')).toBe(true);
    });

    it('does not render the error alert initially', async () => {
      createComponent();
      await waitForPromises();

      expect(findErrorAlert().exists()).toBe(false);
    });

    it('renders an inline error when the query fails', async () => {
      mockEnrollmentQuery.mockRejectedValueOnce(new Error('boom'));
      createComponent();
      await waitForPromises();

      expect(findErrorAlert().exists()).toBe(true);
      expect(findErrorAlert().text()).not.toBe('');
    });
  });

  describe('toggling on', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('calls the enroll mutation and reflects the new state', async () => {
      await flipToggle(true);

      expect(mockEnrollMutation).toHaveBeenCalledTimes(1);
      expect(mockUnenrollMutation).not.toHaveBeenCalled();
      expect(findToggle().props('value')).toBe(true);
      expect(findErrorAlert().exists()).toBe(false);
    });

    it('disables the toggle while the mutation is in flight', async () => {
      expect(findToggle().props('disabled')).toBe(false);
      expect(findToggle().props('isLoading')).toBe(false);

      flipToggle(true);
      await nextTick();

      expect(findToggle().props('disabled')).toBe(true);
      expect(findToggle().props('isLoading')).toBe(true);
    });

    it('re-enables the toggle after the mutation resolves', async () => {
      await flipToggle(true);

      expect(findToggle().props('disabled')).toBe(false);
      expect(findToggle().props('isLoading')).toBe(false);
    });

    it('shows the enroll-specific success toast', async () => {
      await flipToggle(true);

      expect(mockToastShow).toHaveBeenCalledTimes(1);
      expect(mockToastShow).toHaveBeenCalledWith('Secrets Manager is enabled.');
    });

    it('renders an inline error when the mutation returns errors', async () => {
      mockEnrollMutation.mockResolvedValueOnce(enrollMutationResponse(['nope']));

      await flipToggle(true);

      expect(findErrorAlert().exists()).toBe(true);
      expect(findToggle().props('value')).toBe(false);
      expect(mockToastShow).not.toHaveBeenCalled();
    });

    it('renders an inline error when the mutation throws', async () => {
      mockEnrollMutation.mockRejectedValueOnce(new Error('boom'));

      await flipToggle(true);

      expect(findErrorAlert().exists()).toBe(true);
      expect(findToggle().props('value')).toBe(false);
      expect(mockToastShow).not.toHaveBeenCalled();
    });

    it('clears a previous error before the next mutation attempt', async () => {
      mockEnrollMutation.mockRejectedValueOnce(new Error('boom'));
      await flipToggle(true);
      expect(findErrorAlert().exists()).toBe(true);

      mockEnrollMutation.mockResolvedValueOnce(enrollMutationResponse());
      await flipToggle(true);

      expect(findErrorAlert().exists()).toBe(false);
    });
  });

  describe('toggling off', () => {
    beforeEach(async () => {
      mockEnrollmentQuery.mockResolvedValueOnce(enrollmentResponse(true));
      createComponent();
      await waitForPromises();
    });

    it('calls the unenroll mutation and reflects the new state', async () => {
      await flipToggle(false);

      expect(mockUnenrollMutation).toHaveBeenCalledTimes(1);
      expect(mockEnrollMutation).not.toHaveBeenCalled();
      expect(findToggle().props('value')).toBe(false);
      expect(findErrorAlert().exists()).toBe(false);
    });

    it('shows the unenroll-specific success toast', async () => {
      await flipToggle(false);

      expect(mockToastShow).toHaveBeenCalledTimes(1);
      expect(mockToastShow).toHaveBeenCalledWith('Secrets Manager is disabled.');
    });

    it('renders an inline error when the mutation returns errors', async () => {
      mockUnenrollMutation.mockResolvedValueOnce(unenrollMutationResponse(['nope']));

      await flipToggle(false);

      expect(findErrorAlert().exists()).toBe(true);
      expect(findToggle().props('value')).toBe(true);
    });
  });

  describe('dismissing the error alert', () => {
    beforeEach(async () => {
      mockEnrollMutation.mockRejectedValueOnce(new Error('boom'));
      createComponent();
      await waitForPromises();
      await flipToggle(true);
    });

    it('hides the alert when dismissed', async () => {
      expect(findErrorAlert().exists()).toBe(true);

      findErrorAlert().vm.$emit('dismiss');
      await nextTick();

      expect(findErrorAlert().exists()).toBe(false);
    });
  });
});
