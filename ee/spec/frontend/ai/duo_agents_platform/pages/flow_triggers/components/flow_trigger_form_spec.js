import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlForm, GlFormTextarea, GlFormRadioGroup, GlFormInput } from '@gitlab/ui';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import UserSelect from '~/vue_shared/components/user_select/user_select.vue';
import ErrorsAlert from '~/vue_shared/components/errors_alert.vue';
import FormGroup from 'ee/ai/catalog/components/form_group.vue';
import { FOUNDATIONAL_FLOW_REFERENCE_CODE_REVIEW } from 'ee/ai/catalog/constants';
import FlowTriggerForm from 'ee/ai/duo_agents_platform/pages/flow_triggers/components/flow_trigger_form.vue';
import getCatalogConsumerItemsQuery from 'ee/ai/duo_agents_platform/graphql/queries/get_catalog_consumer_items.query.graphql';
import AiLegalDisclaimer from 'ee/ai/duo_agents_platform/components/common/ai_legal_disclaimer.vue';
import {
  FLOW_TRIGGER_TYPES,
  FLOW_TRIGGER_TYPE_PIPELINE_HOOKS,
} from 'ee/ai/duo_agents_platform/constants';
import FlowTriggerEventsField from 'ee/ai/duo_agents_platform/pages/flow_triggers/components/flow_trigger_events_field.vue';
import { mockCatalogFlowsResponse } from '../mocks';

Vue.use(VueApollo);

describe('FlowTriggerForm', () => {
  let wrapper;

  const catalogFlowsHandler = jest.fn();

  const findErrorsAlert = () => wrapper.findComponent(ErrorsAlert);
  const findForm = () => wrapper.findComponent(GlForm);
  const findDescription = () => wrapper.findComponent(GlFormTextarea);
  const findEventsField = () => wrapper.findComponent(FlowTriggerEventsField);
  const findFlowGroup = () => wrapper.find('[data-testid="trigger-agent-group"]');
  const findFlowSelect = () => wrapper.find('[data-testid="trigger-agent-listbox"]');
  const findUserSelect = () => wrapper.findComponent(UserSelect);
  const findConfigModeRadio = () => wrapper.findComponent(GlFormRadioGroup);
  const findConfigPathInput = () => wrapper.findComponent(GlFormInput);
  const findSubmitButton = () => wrapper.findByTestId('trigger-submit-button');
  const findCancelButton = () => wrapper.findByTestId('trigger-cancel-button');
  const findAiLegalDisclaimer = () => wrapper.findComponent(AiLegalDisclaimer);

  const toStringValues = (valueInts) =>
    valueInts.map((vi) => FLOW_TRIGGER_TYPES.find((t) => t.valueInt === vi)?.value);

  const defaultProps = {
    mode: 'create',
    isLoading: false,
    errorMessages: [],
    projectPath: 'myProject',
    projectId: '123',
  };

  const buildInitialValues = (overrides = {}) => ({
    description: '',
    eventTypes: [],
    configPath: '',
    user: null,
    aiCatalogItemConsumer: {},
    filter: {},
    ...overrides,
  });

  const createWrapper = async (props = {}, provide = {}) => {
    const handlers = [[getCatalogConsumerItemsQuery, catalogFlowsHandler]];

    wrapper = shallowMountExtended(FlowTriggerForm, {
      apolloProvider: createMockApollo(handlers),
      propsData: { ...defaultProps, ...props },
      provide: {
        glAbilities: {
          readAiCatalogFlow: true,
          readAiCatalogThirdPartyFlow: true,
          createAiCatalogThirdPartyFlow: true,
        },
        glFeatures: {},
        ...provide,
      },
      stubs: {
        FormGroup,
      },
    });

    await waitForPromises();
    return wrapper;
  };

  beforeEach(() => {
    catalogFlowsHandler.mockResolvedValue(mockCatalogFlowsResponse);
  });

  describe('Default rendering', () => {
    beforeEach(async () => {
      await createWrapper();
    });

    it('renders errors alert component with no errors', () => {
      expect(findErrorsAlert().exists()).toBe(true);
      expect(findErrorsAlert().props('errors')).toEqual([]);
    });

    it('renders form components', () => {
      expect(findForm().exists()).toBe(true);
      expect(findDescription().exists()).toBe(true);
      expect(findEventsField().exists()).toBe(true);
      expect(findUserSelect().exists()).toBe(true);
      expect(findConfigModeRadio().exists()).toBe(true);
      expect(findSubmitButton().exists()).toBe(true);
      expect(findCancelButton().exists()).toBe(true);
      expect(findAiLegalDisclaimer().exists()).toBe(true);
    });
  });

  describe('Configuration Mode', () => {
    beforeEach(async () => {
      await createWrapper();
    });

    it('defaults to catalog mode', () => {
      expect(findFlowSelect().exists()).toBe(true);
      expect(findConfigPathInput().exists()).toBe(false);
      expect(findFlowGroup().attributes('label')).toBe('Agent or flow');
      expect(findFlowGroup().attributes('labeldescription')).toBe(
        'From the agents and flows configured for this project, select the one that this trigger will execute.',
      );
      expect(findFlowSelect().props('headerText')).toBe(
        'Select an agent or flow from the AI Catalog',
      );
    });

    describe('when switching to manual mode', () => {
      it('shows config path input and hides flow select', async () => {
        await findConfigModeRadio().vm.$emit('input', 'manual');

        expect(findConfigPathInput().exists()).toBe(true);
        expect(findFlowSelect().exists()).toBe(false);
      });
    });

    describe('configMode initialization', () => {
      describe('when aiCatalogItemConsumer has an id', () => {
        beforeEach(async () => {
          await createWrapper({
            initialValues: buildInitialValues({
              configPath: 'some/path',
              aiCatalogItemConsumer: { id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1' },
            }),
          });
        });

        it('defaults to catalog mode', () => {
          expect(findConfigModeRadio().attributes('checked')).toBe('catalog');
          expect(findFlowSelect().exists()).toBe(true);
          expect(findConfigPathInput().exists()).toBe(false);
        });
      });

      describe('when aiCatalogItemConsumer has no id', () => {
        describe('and configPath is empty', () => {
          beforeEach(async () => {
            await createWrapper({
              initialValues: buildInitialValues(),
            });
          });

          it('defaults to catalog mode', () => {
            expect(findConfigModeRadio().attributes('checked')).toBe('catalog');
            expect(findFlowSelect().exists()).toBe(true);
            expect(findConfigPathInput().exists()).toBe(false);
          });
        });

        describe('and configPath exists', () => {
          beforeEach(async () => {
            await createWrapper({
              initialValues: buildInitialValues({ configPath: 'existing/config/path.yml' }),
            });
          });

          it('defaults to manual mode', () => {
            expect(findConfigModeRadio().exists()).toBe(true);
            expect(findConfigModeRadio().attributes('checked')).toBe('manual');
            expect(findConfigPathInput().exists()).toBe(true);
            expect(findFlowSelect().exists()).toBe(false);
          });
        });
      });

      describe('when both readAiCatalogFlow and readAiCatalogThirdPartyFlow are false', () => {
        beforeEach(async () => {
          await createWrapper(
            {},
            {
              glAbilities: { readAiCatalogFlow: false, readAiCatalogThirdPartyFlow: false },
            },
          );
        });

        it('defaults to manual mode', () => {
          expect(findConfigModeRadio().exists()).toBe(false);
          expect(findFlowSelect().exists()).toBe(false);
          expect(findConfigPathInput().exists()).toBe(true);
        });
      });
    });
  });

  describe('Configuration source toggle', () => {
    describe('when readAiCatalogFlow, readAiCatalogThirdPartyFlow and createAiCatalogThirdPartyFlow are false', () => {
      beforeEach(async () => {
        await createWrapper(
          {},
          {
            glAbilities: {
              readAiCatalogFlow: false,
              readAiCatalogThirdPartyFlow: false,
              createAiCatalogThirdPartyFlow: false,
            },
          },
        );
      });

      it('does not show the configuration source controls', () => {
        expect(findConfigModeRadio().exists()).toBe(false);
      });
    });

    describe('when only readAiCatalogFlow is true', () => {
      beforeEach(async () => {
        await createWrapper(
          {},
          {
            glAbilities: {
              readAiCatalogFlow: true,
              readAiCatalogThirdPartyFlow: false,
              createAiCatalogThirdPartyFlow: false,
            },
          },
        );
      });

      it('does not show the configuration source controls', () => {
        expect(findConfigModeRadio().exists()).toBe(false);
      });
    });

    describe('when only readAiCatalogFlow and createAiCatalogThirdPartyFlow are true', () => {
      beforeEach(async () => {
        await createWrapper(
          {},
          {
            glAbilities: {
              readAiCatalogFlow: true,
              readAiCatalogThirdPartyFlow: false,
              createAiCatalogThirdPartyFlow: true,
            },
          },
        );
      });

      it('shows the configuration source controls', () => {
        expect(findConfigModeRadio().exists()).toBe(true);
      });
    });

    describe('when only readAiCatalogThirdPartyFlow is true', () => {
      beforeEach(async () => {
        await createWrapper(
          {},
          {
            glAbilities: {
              readAiCatalogFlow: false,
              readAiCatalogThirdPartyFlow: true,
              createAiCatalogThirdPartyFlow: false,
            },
          },
        );
      });

      it('does not show the configuration source controls', () => {
        expect(findConfigModeRadio().exists()).toBe(false);
      });
    });

    describe('when only readAiCatalogThirdPartyFlow and createAiCatalogThirdPartyFlow are true', () => {
      beforeEach(async () => {
        await createWrapper(
          {},
          {
            glAbilities: {
              readAiCatalogFlow: false,
              readAiCatalogThirdPartyFlow: true,
              createAiCatalogThirdPartyFlow: true,
            },
          },
        );
      });

      it('shows the configuration source controls', () => {
        expect(findConfigModeRadio().exists()).toBe(true);
      });
    });

    describe('when only createAiCatalogThirdPartyFlow is true', () => {
      beforeEach(async () => {
        await createWrapper(
          {},
          {
            glAbilities: {
              readAiCatalogFlow: false,
              readAiCatalogThirdPartyFlow: false,
              createAiCatalogThirdPartyFlow: true,
            },
          },
        );
      });

      it('does not show the configuration source controls', () => {
        expect(findConfigModeRadio().exists()).toBe(false);
      });
    });
  });

  describe('Flow Selection', () => {
    describe('when there is a default value selected', () => {
      beforeEach(async () => {
        await createWrapper({
          initialValues: buildInitialValues({
            description: 'Initial description',
            eventTypes: [FLOW_TRIGGER_TYPES[0].valueInt],
            configPath: 'initial/path',
            user: { id: 'gid://gitlab/User/1', name: 'Initial User' },
            aiCatalogItemConsumer: {
              id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
              name: 'Test Flow',
            },
          }),
        });
      });

      it('shows this value as selected', () => {
        expect(findFlowSelect().props().items).toHaveLength(2);
        expect(findFlowSelect().props().selected).toBe('gid://gitlab/Ai::Catalog::ItemConsumer/1');
      });
    });

    describe('when there are no default value selected', () => {
      beforeEach(async () => {
        await createWrapper();
      });

      it('shows default text', () => {
        expect(findFlowSelect().props('toggleText')).toBe(
          'Select an agent or flow from the AI Catalog',
        );

        expect(findFlowSelect().props().items).toHaveLength(2);
        expect(findFlowSelect().props().selected).toEqual([]);
      });

      describe('and user selects a flow', () => {
        const selectedValue = 'gid://gitlab/Ai::Catalog::ItemConsumer/1';

        beforeEach(async () => {
          await findFlowSelect().vm.$emit('select', selectedValue);
        });

        it('updates selected flow', () => {
          expect(findFlowSelect().props().items).toHaveLength(2);
          expect(findFlowSelect().props().selected).toBe(selectedValue);
        });

        it('shows correct toggle', async () => {
          expect(findFlowSelect().props('items')).toHaveLength(2);

          await findFlowSelect().vm.$emit('select', 'gid://gitlab/Ai::Catalog::ItemConsumer/1');

          expect(findFlowSelect().props('toggleText')).toBe('Test Flow');
        });
      });
    });
  });

  describe('Event Type Selection', () => {
    it('forwards initial event types to the field as string values', async () => {
      await createWrapper({
        initialValues: buildInitialValues({
          eventTypes: [FLOW_TRIGGER_TYPES[0].valueInt, FLOW_TRIGGER_TYPES[1].valueInt],
        }),
      });

      expect(findEventsField().props('eventTypes')).toEqual([
        FLOW_TRIGGER_TYPES[0].value,
        FLOW_TRIGGER_TYPES[1].value,
      ]);
    });

    it('converts field string values back to valueInt on submit', async () => {
      await createWrapper();
      await findDescription().vm.$emit('input', 'desc');
      await findEventsField().vm.$emit('update:event-types', [FLOW_TRIGGER_TYPES[0].value]);
      await findUserSelect().vm.$emit('input', [{ id: 'gid://gitlab/User/1' }]);
      await findFlowSelect().vm.$emit('select', 'gid://gitlab/Ai::Catalog::ItemConsumer/1');
      await findForm().vm.$emit('submit', { preventDefault: () => {} });

      expect(wrapper.emitted('submit')[0][0].eventTypes).toEqual([FLOW_TRIGGER_TYPES[0].valueInt]);
    });
  });

  describe('User Selection', () => {
    beforeEach(async () => {
      await createWrapper();
    });

    it('shows correct user name when user is selected', async () => {
      const mockUser = { id: 1, name: 'Test User' };
      await findUserSelect().vm.$emit('input', [mockUser]);

      expect(findUserSelect().props('text')).toBe('Test User');
    });

    it('shows default text when no user is selected', () => {
      expect(findUserSelect().props('text')).toBe('Select a service account');
    });

    it('handles user select error', async () => {
      await findUserSelect().vm.$emit('error');

      expect(findErrorsAlert().props('errors')).toEqual([
        'An error occurred while fetching users.',
      ]);
    });

    it('processes users data correctly', () => {
      const user1 = { id: 1, name: 'User 1' };
      const user2 = { id: 2, name: 'User 2' };
      const data = { project: { projectMembers: { nodes: [{ user: user1 }, { user: user2 }] } } };

      const processor = findUserSelect().props('customSearchUsersProcessor');
      const result = processor(data);

      expect(result).toEqual([user1, user2]);
    });

    it('handles empty users data', () => {
      const data = { project: { projectMembers: { nodes: [] } } };
      const processor = findUserSelect().props('customSearchUsersProcessor');
      const result = processor(data);

      expect(result).toEqual([]);
    });

    it('filters out the duo-code-review foundational flow service account', () => {
      const regularServiceAccount = { id: 1, name: 'Regular SA', username: 'ai-my-flow-acme' };
      const duoCodeReview = {
        id: 2,
        name: 'Duo Code Review',
        username: 'duo-code-review-acme',
      };
      const data = {
        project: {
          projectMembers: { nodes: [{ user: regularServiceAccount }, { user: duoCodeReview }] },
        },
      };

      const processor = findUserSelect().props('customSearchUsersProcessor');
      const result = processor(data);

      expect(result).toEqual([regularServiceAccount]);
    });
  });

  describe('Form Submit', () => {
    describe('when in catalog mode', () => {
      const description = 'My description';
      const eventTypes = [FLOW_TRIGGER_TYPES[0].valueInt];
      const selectedFlow = 'gid://gitlab/Ai::Catalog::ItemConsumer/1';
      const mockUser = { id: 'gid://gitlab/User/1', name: 'Test User' };

      beforeEach(async () => {
        await createWrapper();
      });

      it('submits the form with selected flow', async () => {
        expect(findFlowSelect().props('items')).toHaveLength(2);

        await findDescription().vm.$emit('input', description);
        await findEventsField().vm.$emit('update:event-types', toStringValues(eventTypes));
        await findUserSelect().vm.$emit('input', [mockUser]);
        await findFlowSelect().vm.$emit('select', selectedFlow);

        await findForm().vm.$emit('submit', { preventDefault: () => {} });

        expect(wrapper.emitted('submit')).toEqual([
          [
            {
              configPath: null,
              description,
              eventTypes,
              userId: 'gid://gitlab/User/1',
              aiCatalogItemConsumerId: selectedFlow,
              filter: {},
            },
          ],
        ]);
      });
    });

    describe('when in manual mode', () => {
      const description = 'My description';
      const eventTypes = [FLOW_TRIGGER_TYPES[0].valueInt];
      const configPath = 'path/to/config.yml';
      const mockUser = { id: 'gid://gitlab/User/1', name: 'Test User' };

      beforeEach(async () => {
        await createWrapper();
      });

      it('submits the form with config path', async () => {
        await findConfigModeRadio().vm.$emit('input', 'manual');

        await findDescription().vm.$emit('input', description);
        await findEventsField().vm.$emit('update:event-types', toStringValues(eventTypes));
        await findUserSelect().vm.$emit('input', [mockUser]);
        await findConfigPathInput().vm.$emit('input', configPath);

        await findForm().vm.$emit('submit', { preventDefault: () => {} });

        expect(wrapper.emitted('submit')).toEqual([
          [
            {
              configPath,
              description,
              eventTypes,
              userId: 'gid://gitlab/User/1',
              aiCatalogItemConsumerId: null,
              filter: {},
            },
          ],
        ]);
      });
    });

    describe('when no user is selected', () => {
      beforeEach(async () => {
        await createWrapper();
      });
      it('does not submit as userId is required', async () => {
        await findDescription().vm.$emit('input', 'Test description');
        await findEventsField().vm.$emit('update:event-types', [FLOW_TRIGGER_TYPES[0].value]);
        // Don't select any user

        await findForm().vm.$emit('submit', { preventDefault: () => {} });

        expect(wrapper.emitted('submit')).toBeUndefined();
      });
    });
  });

  describe('Form Cancel', () => {
    it('emits cancel event when clicked', async () => {
      await createWrapper();
      await findCancelButton().vm.$emit('click');

      expect(wrapper.emitted('cancel')).toHaveLength(1);
    });
  });

  describe('Initial Values', () => {
    beforeEach(async () => {
      await createWrapper({
        initialValues: buildInitialValues({
          description: 'Initial description',
          eventTypes: [FLOW_TRIGGER_TYPES[0].valueInt],
          configPath: 'initial/path',
          user: { id: 'gid://gitlab/User/1', name: 'Initial User' },
        }),
      });
    });

    it('sets initial values correctly', () => {
      expect(findDescription().props('value')).toBe('Initial description');
      expect(findEventsField().props('eventTypes')).toEqual([FLOW_TRIGGER_TYPES[0].value]);

      expect(findUserSelect().props('value')).toEqual([
        { id: 'gid://gitlab/User/1', name: 'Initial User' },
      ]);
    });
  });

  describe('FlowTriggerEventsField integration', () => {
    const description = 'My description';
    const mockUser = { id: 'gid://gitlab/User/1', name: 'Test User' };
    const filter = {
      pipeline_hooks: {
        rules: [{ field: 'object_attributes.status', operator: 'in', value: ['failed'] }],
      },
    };

    beforeEach(async () => {
      await createWrapper();
      await findConfigModeRadio().vm.$emit('input', 'manual');
      await findDescription().vm.$emit('input', description);
      await findUserSelect().vm.$emit('input', [mockUser]);
      await findConfigPathInput().vm.$emit('input', 'path/to.yml');
    });

    it('forwards the filter as a prop to the field', async () => {
      await findEventsField().vm.$emit('update:filter', filter);

      expect(findEventsField().props('filter')).toEqual(filter);
    });

    it('passes "agent or flow" as the item type label', () => {
      expect(findEventsField().props('itemTypeLabel')).toBe('agent or flow');
    });

    it('includes the filter in the submit payload when the field reports valid', async () => {
      await findEventsField().vm.$emit('update:event-types', [
        FLOW_TRIGGER_TYPE_PIPELINE_HOOKS.value,
      ]);
      await findEventsField().vm.$emit('update:filter', filter);
      await findEventsField().vm.$emit('update:filter-valid', true);

      await findForm().vm.$emit('submit', { preventDefault: () => {} });

      expect(wrapper.emitted('submit')[0][0].filter).toEqual(filter);
    });

    it('blocks submit and flips show-errors when the field reports invalid', async () => {
      await findEventsField().vm.$emit('update:event-types', [
        FLOW_TRIGGER_TYPE_PIPELINE_HOOKS.value,
      ]);
      await findEventsField().vm.$emit('update:filter-valid', false);

      expect(findEventsField().props('showErrors')).toBe(false);

      await findForm().vm.$emit('submit', { preventDefault: () => {} });

      expect(wrapper.emitted('submit')).toBeUndefined();
      expect(findEventsField().props('showErrors')).toBe(true);
    });
  });

  describe('Error handling', () => {
    beforeEach(async () => {
      await createWrapper();
    });

    describe('when errors are present', () => {
      beforeEach(async () => {
        await findUserSelect().vm.$emit('error');
      });

      it('shows errors in ErrorsAlert component', () => {
        expect(findErrorsAlert().props('errors')).toEqual([
          'An error occurred while fetching users.',
        ]);
      });

      describe('and errors are dismissed', () => {
        beforeEach(async () => {
          await findErrorsAlert().vm.$emit('dismiss');
        });

        it('clears the errors', () => {
          expect(findErrorsAlert().props('errors')).toEqual([]);
        });
      });
    });
  });

  describe('Apollo queries', () => {
    describe('catalog flows query', () => {
      beforeEach(async () => {
        await createWrapper();
      });

      it('fetches catalog flows on mount', () => {
        expect(catalogFlowsHandler).toHaveBeenCalledWith({
          projectId: 'gid://gitlab/Project/123',
          itemTypes: ['FLOW', 'THIRD_PARTY_FLOW'],
        });
      });

      it('handles catalog flows query error', async () => {
        catalogFlowsHandler.mockRejectedValue(new Error('Network error'));
        await createWrapper();

        expect(findErrorsAlert().props('errors')).toEqual([
          'An error occurred while fetching flows configured for this project.',
        ]);
      });

      it('filters out the Code Review foundational flow from the dropdown', async () => {
        catalogFlowsHandler.mockResolvedValue({
          data: {
            aiCatalogConfiguredItems: {
              nodes: [
                {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                  item: {
                    id: 'gid://gitlab/Ai::Catalog::Item/10',
                    name: 'Test Flow',
                    foundationalFlowReference: null,
                  },
                },
                {
                  id: 'gid://gitlab/Ai::Catalog::ItemConsumer/2',
                  item: {
                    id: 'gid://gitlab/Ai::Catalog::Item/20',
                    name: 'Code Review',
                    foundationalFlowReference: FOUNDATIONAL_FLOW_REFERENCE_CODE_REVIEW,
                  },
                },
              ],
            },
          },
        });
        await createWrapper();

        const items = findFlowSelect().props('items');
        expect(items.map((i) => i.text)).toEqual(['Test Flow']);
      });
    });
  });

  describe('catalogConfigModeTexts', () => {
    describe('when only readAiCatalogFlow is enabled', () => {
      beforeEach(async () => {
        await createWrapper(
          {},
          {
            glAbilities: { readAiCatalogFlow: true, readAiCatalogThirdPartyFlow: false },
          },
        );
      });

      it('renders the form group label with only "agent"', () => {
        expect(findFlowGroup().attributes('label')).toBe('Flow');
        expect(findFlowGroup().attributes('labeldescription')).toBe(
          'From the flows configured for this project, select the flow that this trigger will execute.',
        );
      });

      it('shows default text with only "flow"', () => {
        expect(findFlowSelect().props('toggleText')).toBe('Select a flow from the AI Catalog');
      });

      it('shows header text with only "flow"', () => {
        expect(findFlowSelect().props('headerText')).toBe('Select a flow from the AI Catalog');
      });
    });

    describe('when only readAiCatalogThirdPartyFlow is enabled', () => {
      beforeEach(async () => {
        await createWrapper(
          {},
          {
            glAbilities: { readAiCatalogFlow: false, readAiCatalogThirdPartyFlow: true },
          },
        );
      });

      it('renders the form group label with only "agent"', () => {
        expect(findFlowGroup().attributes('label')).toBe('Agent');
        expect(findFlowGroup().attributes('labeldescription')).toBe(
          'From the agents configured for this project, select the agent that this trigger will execute.',
        );
      });

      it('renders the placeholder text with only "agent"', () => {
        expect(findFlowSelect().props('toggleText')).toBe('Select an agent from the AI Catalog');
      });

      it('renders the header text with only "agent"', () => {
        expect(findFlowSelect().props('headerText')).toBe('Select an agent from the AI Catalog');
      });
    });
  });
});
