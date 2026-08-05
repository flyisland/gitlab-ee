import { GlAlert } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { stubComponent } from 'helpers/stub_component';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import NewApplicationPanel from 'ee/cd/components/new_application_panel.vue';
import PanelFormField from 'ee/cd/components/shared/panel_form_field.vue';
import PanelFormGroup from 'ee/cd/components/shared/panel_form_group.vue';
import cdApplicationCreateMutation from 'ee/cd/graphql/cd_application_create.mutation.graphql';
import cdApplicationsQuery from 'ee/cd/graphql/cd_applications.query.graphql';

jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);

describe('NewApplicationPanel', () => {
  let apolloProvider;
  let wrapper;

  const organizationId = 'gid://gitlab/Organizations::Organization/1';

  const initialData = {
    organization: {
      __typename: 'Organization',
      id: organizationId,
      cdApplications: {
        __typename: 'CdApplicationConnection',
        nodes: [
          {
            __typename: 'CdApplication',
            id: 'gid://gitlab/Cd::Application/1',
            name: 'app-1',
            description: 'existing description',
            updatedAt: '2024-01-01T00:00:00Z',
          },
        ],
      },
    },
  };

  const successResponse = {
    data: {
      cdApplicationCreate: {
        __typename: 'CdApplicationCreatePayload',
        application: {
          __typename: 'CdApplication',
          id: 'gid://gitlab/Cd::Application/2',
          name: 'acme-platform',
          description: 'A new app',
          updatedAt: '2024-02-01T00:00:00Z',
        },
        errors: [],
      },
    },
  };

  const errorResponse = {
    data: {
      cdApplicationCreate: {
        __typename: 'CdApplicationCreatePayload',
        application: null,
        errors: ['Name has already been taken'],
      },
    },
  };

  const defaultMutationHandler = jest.fn().mockResolvedValue(successResponse);

  const findMountingPortal = () => wrapper.findComponent(MountingPortal);
  const findDynamicPanel = () => wrapper.findComponent(DynamicPanel);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findPanelFormFields = () => wrapper.findAllComponents(PanelFormField);
  const findNameInput = () => wrapper.find('#application-name');
  const findDescriptionInput = () => wrapper.find('#application-description');
  const findCancelButton = () => wrapper.findByTestId('cancel-button');
  const findSubmitButton = () => wrapper.findByTestId('register-button');
  const findAddServiceHeaderButton = () => wrapper.findByTestId('add-service-header');
  const findServiceEmptyState = () => wrapper.findByTestId('service-empty-state');
  const findServicesList = () => wrapper.findByTestId('services-list');
  const findServiceForm = () => wrapper.findByTestId('service-form');
  const findServiceNameInput = () => wrapper.find('#service-name');
  const findServiceDescriptionInput = () => wrapper.find('#service-description');
  const findCancelServiceButton = () => wrapper.findByTestId('cancel-service');
  const findAddServiceButton = () => wrapper.findByTestId('add-service');
  const findEditServiceButtons = () => wrapper.findAllByTestId('edit-service');
  const findRemoveServiceButtons = () => wrapper.findAllByTestId('remove-service');
  const findAddAnotherServiceButton = () => wrapper.findByTestId('add-another-service');

  const createComponent = ({ open = true, mutationHandler = defaultMutationHandler } = {}) => {
    apolloProvider = createMockApollo([[cdApplicationCreateMutation, mutationHandler]]);
    apolloProvider.defaultClient.cache.writeQuery({
      query: cdApplicationsQuery,
      data: initialData,
    });

    wrapper = shallowMountExtended(NewApplicationPanel, {
      apolloProvider,
      propsData: {
        open,
        organizationId,
      },
      stubs: {
        DynamicPanel,
        MountingPortal: stubComponent(MountingPortal, { name: 'MountingPortal' }),
        PanelFormGroup,
      },
    });
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
    beforeEach(() => {
      createComponent({ open: true });
    });

    it('renders into the contextual panel portal', () => {
      expect(findMountingPortal().attributes('mount-to')).toBe('#contextual-panel-portal');
    });

    it('renders the panel', () => {
      expect(findDynamicPanel().exists()).toBe(true);
    });

    it('renders the header text', () => {
      expect(wrapper.text()).toContain('Add application');
      expect(wrapper.text()).toContain('Register application');
    });

    it('renders the explanatory text', () => {
      expect(wrapper.text()).toContain(
        'Declare the topology of your application — services, environments, integrations — and Deploy will orchestrate rollouts for it.',
      );
    });

    it('does not render an error alert by default', () => {
      expect(findAlert().exists()).toBe(false);
    });
  });

  describe('close', () => {
    beforeEach(() => {
      createComponent();
    });

    it('emits close when the dynamic panel emits close', () => {
      findDynamicPanel().vm.$emit('close');

      expect(wrapper.emitted('close')).toEqual([[]]);
    });

    it('emits close when the Cancel button is clicked', () => {
      findCancelButton().vm.$emit('click');

      expect(wrapper.emitted('close')).toEqual([[]]);
    });
  });

  describe('form fields', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the name field with its label and placeholder', () => {
      expect(findPanelFormFields().at(0).props('label')).toBe('Application name');
      expect(findNameInput().attributes('placeholder')).toBe('e.g. acme-platform');
    });

    it('renders the description field with its label and placeholder', () => {
      expect(findPanelFormFields().at(1).props('label')).toBe('Description');
      expect(findDescriptionInput().attributes('placeholder')).toBe('Brief description');
    });
  });

  describe('form submission', () => {
    describe('on success', () => {
      beforeEach(async () => {
        createComponent();

        findNameInput().vm.$emit('input', 'acme-platform');
        findDescriptionInput().vm.$emit('input', 'A new app');
        findSubmitButton().vm.$emit('click');
        await waitForPromises();
      });

      it('calls the mutation with the form values, organization id, and services', () => {
        expect(defaultMutationHandler).toHaveBeenCalledWith({
          input: {
            name: 'acme-platform',
            description: 'A new app',
            organizationId,
            services: [],
          },
        });
      });

      it('clears the form fields', () => {
        expect(findNameInput().props('value')).toBe('');
        expect(findDescriptionInput().props('value')).toBe('');
      });

      it('emits close', () => {
        expect(wrapper.emitted('close')).toEqual([[]]);
      });

      it('does not render an error alert', () => {
        expect(findAlert().exists()).toBe(false);
      });

      it('adds the created application to the applications query cache', () => {
        const cache = apolloProvider.defaultClient.cache.readQuery({ query: cdApplicationsQuery });

        expect(cache.organization.cdApplications.nodes).toHaveLength(2);
        expect(cache.organization.cdApplications.nodes.at(-1)).toMatchObject({
          id: 'gid://gitlab/Cd::Application/2',
        });
      });
    });

    describe('when the mutation returns errors', () => {
      beforeEach(async () => {
        createComponent({ mutationHandler: jest.fn().mockResolvedValue(errorResponse) });

        findNameInput().vm.$emit('input', 'acme-platform');
        findDescriptionInput().vm.$emit('input', 'A new app');
        findSubmitButton().vm.$emit('click');
        await waitForPromises();
      });

      it('renders the returned errors in an alert', () => {
        expect(findAlert().text()).toBe('Name has already been taken');
      });

      it('does not clear the form fields', () => {
        expect(findNameInput().props('value')).toBe('acme-platform');
        expect(findDescriptionInput().props('value')).toBe('A new app');
      });

      it('does not emit close', () => {
        expect(wrapper.emitted('close')).toBeUndefined();
      });

      it('dismisses the alert when it emits dismiss', async () => {
        await findAlert().vm.$emit('dismiss');

        expect(findAlert().exists()).toBe(false);
      });
    });

    describe('when the mutation throws', () => {
      beforeEach(async () => {
        createComponent({
          mutationHandler: jest.fn().mockRejectedValue(new Error('network error')),
        });

        findNameInput().vm.$emit('input', 'acme-platform');
        findDescriptionInput().vm.$emit('input', 'A new app');
        findSubmitButton().vm.$emit('click');
        await waitForPromises();
      });

      it('renders the returned errors in an alert', () => {
        expect(findAlert().text()).toBe('An error occurred. Please try again.');
      });

      it('reports the exception to Sentry', () => {
        expect(Sentry.captureException).toHaveBeenCalledWith(new Error('network error'));
      });

      it('does not emit close', () => {
        expect(wrapper.emitted('close')).toBeUndefined();
      });
    });
  });

  describe('services section', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('default state', () => {
      it('shows the empty state', () => {
        expect(findServiceEmptyState().exists()).toBe(true);
      });

      it('does not show the service list', () => {
        expect(findServicesList().exists()).toBe(false);
      });

      it('does not show the service form', () => {
        expect(findServiceForm().exists()).toBe(false);
      });

      it('shows the "Add another service" button', () => {
        expect(findAddAnotherServiceButton().exists()).toBe(true);
      });

      it('renders the "Add service" header button', () => {
        expect(findAddServiceHeaderButton().exists()).toBe(true);
      });
    });

    describe('when the "Add service" header button is clicked', () => {
      beforeEach(() => {
        findAddServiceHeaderButton().vm.$emit('click');
      });

      it('shows the service form', () => {
        expect(findServiceForm().exists()).toBe(true);
      });

      it('hides the empty state', () => {
        expect(findServiceEmptyState().exists()).toBe(false);
      });

      it('disables the "Add service" header button', () => {
        expect(findAddServiceHeaderButton().props('disabled')).toBe(true);
      });

      describe('when Cancel is clicked', () => {
        beforeEach(() => {
          findCancelServiceButton().vm.$emit('click');
        });

        it('hides the service form', () => {
          expect(findServiceForm().exists()).toBe(false);
        });

        it('shows the empty state', () => {
          expect(findServiceEmptyState().exists()).toBe(true);
        });
      });

      describe('when a service is added', () => {
        beforeEach(() => {
          findServiceNameInput().vm.$emit('input', 'api-gateway');
          findServiceDescriptionInput().vm.$emit('input', 'API service');
          findAddServiceButton().vm.$emit('click');
        });

        it('hides the service form', () => {
          expect(findServiceForm().exists()).toBe(false);
        });

        it('shows the service name in the list', () => {
          expect(findServicesList().text()).toContain('api-gateway');
        });

        it('shows the "Add another service" button', () => {
          expect(findAddAnotherServiceButton().exists()).toBe(true);
        });

        it('does not show the empty state', () => {
          expect(findServiceEmptyState().exists()).toBe(false);
        });

        it('"Add service" header button is not disabled', () => {
          expect(findAddServiceHeaderButton().props('disabled')).toBe(false);
        });

        describe('when the "Add another service" button is clicked', () => {
          beforeEach(async () => {
            await findAddAnotherServiceButton().trigger('click');
          });

          it('shows the service form', () => {
            expect(findServiceForm().exists()).toBe(true);
          });
        });

        describe('when "Edit" is clicked on a service', () => {
          beforeEach(() => {
            findEditServiceButtons().at(0).vm.$emit('click');
          });

          it('shows the service form', () => {
            expect(findServiceForm().exists()).toBe(true);
          });

          it('pre-populates the service name and description inputs', () => {
            expect(findServiceNameInput().props('value')).toBe('api-gateway');
            expect(findServiceDescriptionInput().props('value')).toBe('API service');
          });

          it('shows "Save service" as the form button label', () => {
            expect(findAddServiceButton().text()).toBe('Save service');
          });

          describe('when the service is saved', () => {
            beforeEach(() => {
              findServiceNameInput().vm.$emit('input', 'payment-service');
              findAddServiceButton().vm.$emit('click');
            });

            it('updates the service name in the list', () => {
              expect(findServicesList().text()).toContain('payment-service');
            });

            it('does not show the old service name', () => {
              expect(findServicesList().text()).not.toContain('api-gateway');
            });

            it('hides the service form', () => {
              expect(findServiceForm().exists()).toBe(false);
            });

            describe('when "Register application" is clicked to submit the form', () => {
              beforeEach(() => {
                findSubmitButton().vm.$emit('click');
              });

              it('calls the mutation with the form values, organization id, and services', () => {
                expect(defaultMutationHandler).toHaveBeenCalledWith({
                  input: {
                    name: '',
                    description: '',
                    organizationId,
                    services: [
                      {
                        name: 'payment-service',
                        description: 'API service',
                      },
                    ],
                  },
                });
              });

              it('clears the form fields', async () => {
                await findAddServiceHeaderButton().vm.$emit('click');

                expect(findServiceNameInput().props('value')).toBe('');
                expect(findServiceDescriptionInput().props('value')).toBe('');
              });
            });
          });
        });

        describe('when "Remove" is clicked on a service', () => {
          beforeEach(() => {
            findRemoveServiceButtons().at(0).vm.$emit('click');
          });

          it('removes the service from the list', () => {
            expect(findServicesList().exists()).toBe(false);
          });

          it('shows the empty state', () => {
            expect(findServiceEmptyState().exists()).toBe(true);
          });
        });
      });
    });
  });
});
