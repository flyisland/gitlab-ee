import { shallowMount } from '@vue/test-utils';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { visitUrl, visitUrlWithAlerts } from '~/lib/utils/url_utility';
import App from 'ee/policy_store/components/editor/app.vue';
import StepWizard from 'ee/policy_store/components/editor/step_wizard.vue';
import { createAlert } from '~/alert';
import { fetchPolicy, createPolicy, updatePolicy } from 'ee/policy_store/policies';
import { PolicyStoreMutationError } from 'ee/policy_store/utils';
import { mockWizardState, mockPolicyParams } from '../../mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');
jest.mock('~/alert');
jest.mock('~/lib/utils/url_utility', () => ({
  ...jest.requireActual('~/lib/utils/url_utility'),
  visitUrl: jest.fn(),
  visitUrlWithAlerts: jest.fn(),
}));
jest.mock('ee/policy_store/policies', () => ({
  fetchPolicy: jest.fn(),
  createPolicy: jest.fn(),
  updatePolicy: jest.fn(),
}));

describe('PolicyStoreEditorRoot', () => {
  let wrapper;

  const policy = { id: 2, name: 'Merge gate', trigger_type: 'merge_request', status: 'active' };

  const findWizard = () => wrapper.findComponent(StepWizard);

  // Returns the settle promise so most tests `await createComponent()`; the
  // loading test skips the await to observe the in-flight state.
  const createComponent = (provide = {}) => {
    wrapper = shallowMount(App, {
      provide: { organizationId: '1', ...provide },
    });

    return waitForPromises();
  };

  beforeEach(() => {
    fetchPolicy.mockResolvedValue(policy);
    createPolicy.mockResolvedValue(policy);
    updatePolicy.mockResolvedValue(policy);
  });

  it('resolves the edited policy through the single-policy endpoint', async () => {
    await createComponent({ policyId: '2' });

    expect(fetchPolicy).toHaveBeenCalledWith('1', '2');
    expect(findWizard().props('policy')).toEqual(policy);
  });

  // The wizard reads its policy prop once, on mount, so it must not mount
  // until the fetch settles.
  it('shows a loading icon instead of the wizard while the policy loads', () => {
    fetchPolicy.mockReturnValue(new Promise(() => {}));

    createComponent({ policyId: '2' });

    expect(wrapper.find('[data-testid="policy-loading"]').exists()).toBe(true);
    expect(findWizard().exists()).toBe(false);
  });

  it('shows an error instead of a blank editor when the policy fails to load', async () => {
    const error = new Error('not found');
    fetchPolicy.mockRejectedValue(error);

    await createComponent({ policyId: '2' });

    expect(wrapper.find('[data-testid="policy-error"]').text()).toContain(
      'The policy could not be loaded from the Policy Store API.',
    );
    expect(findWizard().exists()).toBe(false);
    expect(Sentry.captureException).toHaveBeenCalledWith(error);
  });

  it('does not fetch and renders a blank wizard when there is no policy id', async () => {
    await createComponent();

    expect(fetchPolicy).not.toHaveBeenCalled();
    expect(findWizard().props('policy')).toBe(null);
  });

  it('returns to the list when a new policy is cancelled', async () => {
    await createComponent({ listPath: '/-/security/policy_store' });

    findWizard().vm.$emit('cancel');

    expect(visitUrl).toHaveBeenCalledWith('/-/security/policy_store');
  });

  it('returns to the detail view when an edit is cancelled', async () => {
    await createComponent({ policyId: '2', listPath: '/-/security/policy_store' });

    findWizard().vm.$emit('cancel');

    expect(visitUrl).toHaveBeenCalledWith('/-/security/policy_store/2');
  });

  describe('saving the policy', () => {
    const requestSave = async () => {
      findWizard().vm.$emit('save', mockWizardState);
      await waitForPromises();
    };

    it('creates a new policy and returns to the list with a success confirmation', async () => {
      await createComponent({ listPath: '/-/security/policy_store' });

      await requestSave();

      expect(createPolicy).toHaveBeenCalledWith('1', mockPolicyParams);
      expect(updatePolicy).not.toHaveBeenCalled();
      expect(visitUrlWithAlerts).toHaveBeenCalledWith('/-/security/policy_store', [
        {
          id: 'policy-store-policy-created',
          message: 'Policy Prod gate was created.',
          variant: 'success',
        },
      ]);
    });

    it('updates the edited policy and returns to its detail view with a success confirmation', async () => {
      await createComponent({ policyId: '2', listPath: '/-/security/policy_store' });

      await requestSave();

      expect(updatePolicy).toHaveBeenCalledWith('1', '2', mockPolicyParams);
      expect(createPolicy).not.toHaveBeenCalled();
      expect(visitUrlWithAlerts).toHaveBeenCalledWith('/-/security/policy_store/2', [
        {
          id: 'policy-store-policy-updated',
          message: 'Policy Prod gate was updated.',
          variant: 'success',
        },
      ]);
    });

    it('does not overwrite the stored scope when the Scope step was not touched', async () => {
      await createComponent({ policyId: '2' });

      findWizard().vm.$emit('save', { ...mockWizardState, scopeChanged: false });
      await waitForPromises();

      const { policy_scope: policyScope, ...paramsWithoutScope } = mockPolicyParams;
      expect(updatePolicy).toHaveBeenCalledWith('1', '2', paramsWithoutScope);
    });

    it('sends an untouched scope on create, where there is nothing to overwrite', async () => {
      await createComponent();

      findWizard().vm.$emit('save', { ...mockWizardState, scopeChanged: false });
      await waitForPromises();

      expect(createPolicy).toHaveBeenCalledWith('1', mockPolicyParams);
    });

    it('marks the wizard as saving while the request is in flight', async () => {
      createPolicy.mockReturnValue(new Promise(() => {}));
      await createComponent();

      await requestSave();

      expect(findWizard().props('saving')).toBe(true);
    });

    it('stays on the editor and alerts generically when the save fails', async () => {
      const error = new Error('API is down');
      createPolicy.mockRejectedValue(error);
      await createComponent();

      await requestSave();

      expect(createAlert).toHaveBeenCalledWith({
        message: 'The policy could not be saved. Try again.',
      });
      expect(visitUrl).not.toHaveBeenCalled();
      expect(findWizard().props('saving')).toBe(false);
      expect(Sentry.captureException).toHaveBeenCalledWith(error);
    });

    it("surfaces the store's validation message when the mutation rejects the save", async () => {
      createPolicy.mockRejectedValue(
        new PolicyStoreMutationError('rule 0: unsupported rule type "calendar"'),
      );
      await createComponent();

      await requestSave();

      expect(createAlert).toHaveBeenCalledWith({
        message: 'rule 0: unsupported rule type "calendar"',
      });
    });

    it("surfaces Grape's param validation error on update, which arrives under `error`", async () => {
      const error = new Error('bad request');
      error.response = { data: { error: 'rules is invalid' } };
      updatePolicy.mockRejectedValue(error);
      await createComponent({ policyId: '2' });

      await requestSave();

      expect(createAlert).toHaveBeenCalledWith({ message: 'rules is invalid' });
    });

    describe('when the save is rejected because the name is taken', () => {
      beforeEach(async () => {
        createPolicy.mockRejectedValue(new PolicyStoreMutationError('Name has already been taken'));
        await createComponent();

        await requestSave();
      });

      it('puts the rejection on the name field instead of a page alert', () => {
        expect(createAlert).not.toHaveBeenCalled();
        expect(findWizard().props('nameError')).toBe(
          'A policy with this name already exists. Choose a different name.',
        );
        expect(findWizard().props('saving')).toBe(false);
      });

      it('does not report the rejection to Sentry, since it is ordinary user input', () => {
        expect(Sentry.captureException).not.toHaveBeenCalled();
      });

      it('clears the name error once the name is not a duplicate', async () => {
        await findWizard().vm.$emit('name-update');

        expect(findWizard().props('nameError')).toBe('');
      });

      it('clears the name error as soon as another save attempt starts', async () => {
        createPolicy.mockReturnValue(new Promise(() => {}));

        await requestSave();

        expect(findWizard().props('nameError')).toBe('');
      });
    });

    it('routes a duplicate-name rejection to the name field on the edit page too', async () => {
      const error = new Error('bad request');
      error.response = { data: { message: 'Name has already been taken' } };
      updatePolicy.mockRejectedValue(error);
      await createComponent({ policyId: '2' });

      await requestSave();

      expect(createAlert).not.toHaveBeenCalled();
      expect(findWizard().props('nameError')).toBe(
        'A policy with this name already exists. Choose a different name.',
      );
    });
  });
});
