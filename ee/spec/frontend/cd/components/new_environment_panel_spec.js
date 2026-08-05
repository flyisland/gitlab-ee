import { GlAlert, GlCollapsibleListbox } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { stubComponent } from 'helpers/stub_component';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import NewEnvironmentPanel from 'ee/cd/components/new_environment_panel.vue';
import PanelFormField from 'ee/cd/components/shared/panel_form_field.vue';
import PanelFormGroup from 'ee/cd/components/shared/panel_form_group.vue';
import cdEnvironmentCreateMutation from 'ee/cd/graphql/cd_environment_create.mutation.graphql';
import cdEnvironmentTiersQuery from 'ee/cd/graphql/cd_environment_tiers.query.graphql';
import cdEnvironmentsQuery from 'ee/cd/graphql/cd_environments.query.graphql';
import { buildQueryResponse, buildEnvironmentsQueryResponse } from './mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);

describe('NewEnvironmentPanel', () => {
  let apolloProvider;
  let wrapper;

  const organizationId = 'gid://gitlab/Organizations::Organization/1';
  const tiers = ['DEVELOPMENT', 'STAGING', 'PRODUCTION'];

  const buildResponse = (errors = []) => ({
    data: {
      cdEnvironmentCreate: {
        __typename: 'CdEnvironmentCreatePayload',
        environment: errors.length
          ? null
          : {
              __typename: 'CdEnvironment',
              id: 'gid://gitlab/Cd::Environment/1',
              name: 'eu-west-1-prod',
              tier: 'PRODUCTION',
            },
        errors,
      },
    },
  });

  const defaultMutationHandler = jest.fn().mockResolvedValue(buildResponse());
  const defaultTiersHandler = jest.fn().mockResolvedValue(buildQueryResponse(tiers));

  const findMountingPortal = () => wrapper.findComponent(MountingPortal);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findPanelFormGroup = () => wrapper.findComponent(PanelFormGroup);
  const findPanelFormFields = () => wrapper.findAllComponents(PanelFormField);
  const findNameField = () => findPanelFormFields().at(0);
  const findNameInput = () => wrapper.find('#environment-name');
  const findTierListbox = () => wrapper.findComponent(GlCollapsibleListbox);
  const findCancelButton = () => wrapper.findByTestId('cancel-button');
  const findSubmitButton = () => wrapper.findByTestId('submit-environment-button');

  const createComponent = ({
    open = true,
    mutationHandler = defaultMutationHandler,
    tiersHandler = defaultTiersHandler,
  } = {}) => {
    apolloProvider = createMockApollo([
      [cdEnvironmentCreateMutation, mutationHandler],
      [cdEnvironmentTiersQuery, tiersHandler],
    ]);
    apolloProvider.defaultClient.cache.writeQuery({
      query: cdEnvironmentsQuery,
      data: buildEnvironmentsQueryResponse().data,
    });

    wrapper = shallowMountExtended(NewEnvironmentPanel, {
      apolloProvider,
      propsData: { open },
      stubs: {
        DynamicPanel,
        MountingPortal: stubComponent(MountingPortal, { name: 'MountingPortal' }),
      },
    });
  };

  const submit = async (name = 'eu-west-1-prod') => {
    findNameInput().vm.$emit('input', name);
    findSubmitButton().vm.$emit('click');
    await waitForPromises();
  };

  describe('when open is false', () => {
    beforeEach(() => {
      createComponent({ open: false });
    });

    it('does not render the panel', () => {
      expect(findMountingPortal().exists()).toBe(false);
    });
  });

  describe('when open is true', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the header text', () => {
      expect(wrapper.text()).toContain('Register environment');
    });

    it('renders the form group with its step, title, and description', () => {
      expect(findPanelFormGroup().props()).toEqual({
        step: '1',
        title: 'Environment identity',
        description: 'A short name and the tier it represents.',
      });
    });

    it('renders the name field with its placeholder', () => {
      expect(findNameField().props('label')).toBe('Environment name');
      expect(findNameInput().attributes('placeholder')).toBe('e.g. eu-west-1-prod');
    });

    it('renders the tier options and selects the first tier by default', () => {
      expect(findTierListbox().props('items')).toEqual([
        { value: 'DEVELOPMENT', text: 'Development' },
        { value: 'STAGING', text: 'Staging' },
        { value: 'PRODUCTION', text: 'Production' },
      ]);
      expect(findTierListbox().props('selected')).toBe('DEVELOPMENT');
    });

    it('enables the submit button', () => {
      expect(findSubmitButton().props('disabled')).toBe(false);
    });
  });

  describe('name validation', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('does not flag the field as invalid by default', () => {
      expect(findNameField().props('state')).toBe(null);
    });

    it('flags a blank name and does not call the mutation on submit', async () => {
      await submit('');

      expect(findNameField().props('state')).toBe(false);
      expect(findNameField().props('invalidFeedback')).toBe('Name is required.');
      expect(defaultMutationHandler).not.toHaveBeenCalled();
    });

    it('flags a name that exceeds the max length', async () => {
      findNameInput().vm.$emit('input', 'a'.repeat(256));
      await waitForPromises();

      expect(findNameField().props('state')).toBe(false);
      expect(findNameField().props('invalidFeedback')).toBe('Name cannot exceed 255 characters.');
    });
  });

  describe('on successful submission', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      await submit();
    });

    it('calls the mutation with the name, tier, and organization id', () => {
      expect(defaultMutationHandler).toHaveBeenCalledWith({
        input: { name: 'eu-west-1-prod', tier: 'DEVELOPMENT', organizationId },
      });
    });

    it('adds the created environment to the environments query cache', () => {
      const cache = apolloProvider.defaultClient.cache.readQuery({ query: cdEnvironmentsQuery });

      expect(cache.organization.cdEnvironments.nodes).toHaveLength(1);
      expect(cache.organization.cdEnvironments.nodes.at(-1)).toMatchObject({
        id: 'gid://gitlab/Cd::Environment/1',
        name: 'eu-west-1-prod',
        tier: 'PRODUCTION',
      });
    });

    it('emits close', () => {
      expect(wrapper.emitted('close')).toEqual([[]]);
    });
  });

  describe('when the mutation returns errors', () => {
    beforeEach(async () => {
      createComponent({ mutationHandler: jest.fn().mockResolvedValue(buildResponse(['Taken'])) });
      await waitForPromises();
      await submit();
    });

    it('renders the errors and does not emit close', () => {
      expect(findAlert().text()).toBe('Taken');
      expect(wrapper.emitted('close')).toBeUndefined();
    });

    it('does not add anything to the environments query cache', () => {
      const cache = apolloProvider.defaultClient.cache.readQuery({ query: cdEnvironmentsQuery });

      expect(cache.organization.cdEnvironments.nodes).toHaveLength(0);
    });
  });

  describe('when the mutation throws', () => {
    beforeEach(async () => {
      createComponent({ mutationHandler: jest.fn().mockRejectedValue(new Error('network error')) });
      await waitForPromises();
      await submit();
    });

    it('renders a generic error and reports to Sentry', () => {
      expect(findAlert().text()).toBe('An error occurred. Please try again.');
      expect(Sentry.captureException).toHaveBeenCalledWith(new Error('network error'));
    });
  });

  describe('when the tiers query has not resolved yet', () => {
    beforeEach(() => {
      createComponent();
    });

    it('disables the submit button', () => {
      expect(findSubmitButton().props('disabled')).toBe(true);
    });

    it('does not call the mutation on submit', async () => {
      await submit();

      expect(defaultMutationHandler).not.toHaveBeenCalled();
    });
  });

  describe('when the tiers query fails', () => {
    beforeEach(async () => {
      createComponent({ tiersHandler: jest.fn().mockRejectedValue(new Error('tiers error')) });
      await waitForPromises();
    });

    it('reports the exception to Sentry', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(new Error('tiers error'));
    });

    it('keeps the submit button disabled', () => {
      expect(findSubmitButton().props('disabled')).toBe(true);
    });

    it('does not call the mutation on submit', async () => {
      await submit();

      expect(defaultMutationHandler).not.toHaveBeenCalled();
    });
  });

  describe('when the Cancel button is clicked', () => {
    beforeEach(() => {
      createComponent();
      findCancelButton().vm.$emit('click');
    });

    it('emits close', () => {
      expect(wrapper.emitted('close')).toEqual([[]]);
    });
  });
});
