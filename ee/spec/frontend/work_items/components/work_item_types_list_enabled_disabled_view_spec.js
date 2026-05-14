import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlLoadingIcon, GlAlert } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import WorkItemTypesListEnabledDisabledView from 'ee/work_items/components/work_item_types_list_enabled_disabled_view.vue';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import WorkItemTypeIcon from '~/work_items/components/work_item_type_icon.vue';
import workItemTypesConfigurationQuery from '~/work_items/graphql/work_item_types_configuration.query.graphql';
import { mockWorkItemTypesConfigurationResponse } from 'ee_else_ce_jest/work_items/mock_data';

Vue.use(VueApollo);

describe('WorkItemTypesListEnabledDisabledView', () => {
  let wrapper;

  const baseTypes = mockWorkItemTypesConfigurationResponse.data.namespace.workItemTypes.nodes;
  const fullPath = 'test-group';

  const createMockResponse = (types) => ({
    data: {
      namespace: {
        ...mockWorkItemTypesConfigurationResponse.data.namespace,
        workItemTypes: {
          nodes: types,
          __typename: 'WorkItemTypeConnection',
        },
      },
    },
  });

  const defaultHandler = jest.fn().mockResolvedValue(createMockResponse(baseTypes));

  const createWrapper = ({ queryHandler = defaultHandler } = {}) => {
    wrapper = shallowMountExtended(WorkItemTypesListEnabledDisabledView, {
      apolloProvider: createMockApollo([[workItemTypesConfigurationQuery, queryHandler]]),
      propsData: { fullPath },
    });
  };

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findAllCrudComponents = () => wrapper.findAllComponents(CrudComponent);
  const findEnabledCrudComponent = () => findAllCrudComponents().at(0);
  const findDisabledCrudComponent = () => findAllCrudComponents().at(1);
  const findEnabledTypesTable = () => wrapper.findByTestId('enabled-work-item-types-table');
  const findEnabledTypeRows = () => {
    const table = findEnabledTypesTable();
    return table.exists() ? table.findAll('[data-testid^="work-item-type-row"]') : [];
  };
  const findDisabledTypesToggleButton = () => wrapper.findByTestId('disabled-types-toggle-button');

  describe('loading state', () => {
    it('shows loading icon while query is in flight', () => {
      createWrapper();

      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('hides content while loading', () => {
      createWrapper();

      expect(findEnabledTypesTable().exists()).toBe(false);
    });
  });

  describe('after query resolves', () => {
    beforeEach(async () => {
      createWrapper();
      await waitForPromises();
    });

    it('calls the query with correct variables', () => {
      expect(defaultHandler).toHaveBeenCalledWith({ fullPath });
    });

    it('hides loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('renders enabled types section with correct title', () => {
      expect(findEnabledCrudComponent().exists()).toBe(true);
      expect(findEnabledCrudComponent().props('title')).toBe('Enabled types');
    });

    it('renders enabled work item types table', () => {
      expect(findEnabledTypesTable().exists()).toBe(true);
    });

    it('does not show error alert', () => {
      expect(findAlert().exists()).toBe(false);
    });
  });

  describe('with mixed enabled/disabled types', () => {
    beforeEach(async () => {
      createWrapper();
      await waitForPromises();
    });

    it('renders only enabled types in the enabled section', () => {
      const enabledTypes = baseTypes.filter((t) => t.enabled !== false);
      expect(findEnabledTypeRows()).toHaveLength(enabledTypes.length);
    });

    it('renders correct enabled type name', () => {
      const icons = findEnabledTypesTable().findAllComponents(WorkItemTypeIcon);
      expect(icons.at(0).props('workItemType')).toBe(baseTypes[0].name);
    });

    it('shows the disabled types toggle button', () => {
      expect(findDisabledTypesToggleButton().exists()).toBe(true);
    });

    it('displays correct disabled types count label', () => {
      expect(findDisabledTypesToggleButton().text()).toContain('1 disabled type');
    });

    it('does not render disabled crud component by default', () => {
      expect(findAllCrudComponents()).toHaveLength(1);
    });

    it('renders disabled crud component when toggle button is clicked', async () => {
      findDisabledTypesToggleButton().vm.$emit('click');
      await nextTick();

      expect(findDisabledCrudComponent().exists()).toBe(true);
      expect(findDisabledCrudComponent().props('title')).toBe('Disabled types');
    });

    it('renders correct disabled type names after toggle', async () => {
      findDisabledTypesToggleButton().vm.$emit('click');
      await nextTick();

      const icons = findDisabledCrudComponent().findAllComponents(WorkItemTypeIcon);
      expect(icons).toHaveLength(1);
      expect(icons.at(0).props('workItemType')).toBe(baseTypes[1].name);
    });

    it('hides disabled crud component when toggled again', async () => {
      findDisabledTypesToggleButton().vm.$emit('click');
      await nextTick();
      findDisabledTypesToggleButton().vm.$emit('click');
      await nextTick();

      expect(findAllCrudComponents()).toHaveLength(1);
    });
  });

  describe('when all types are enabled', () => {
    beforeEach(async () => {
      const allEnabled = baseTypes.map((t) => ({ ...t, enabled: true }));
      const handler = jest.fn().mockResolvedValue(createMockResponse(allEnabled));
      createWrapper({ queryHandler: handler });
      await waitForPromises();
    });

    it('does not render disabled types toggle button', () => {
      expect(findDisabledTypesToggleButton().exists()).toBe(false);
    });

    it('renders all types in enabled section', () => {
      expect(findEnabledTypeRows()).toHaveLength(baseTypes.length);
    });
  });

  describe('when all types are disabled', () => {
    beforeEach(async () => {
      const allDisabled = baseTypes.map((t) => ({ ...t, enabled: false }));
      const handler = jest.fn().mockResolvedValue(createMockResponse(allDisabled));
      createWrapper({ queryHandler: handler });
      await waitForPromises();
    });

    it('renders enabled types table with no rows', () => {
      expect(findEnabledTypesTable().exists()).toBe(true);
      expect(findEnabledTypeRows()).toHaveLength(0);
    });

    it('shows disabled types toggle button', () => {
      expect(findDisabledTypesToggleButton().exists()).toBe(true);
    });

    it('displays correct plural label for multiple disabled types', () => {
      expect(findDisabledTypesToggleButton().text()).toContain('2 disabled types');
    });
  });

  describe('when query returns empty nodes', () => {
    beforeEach(async () => {
      const handler = jest.fn().mockResolvedValue(createMockResponse([]));
      createWrapper({ queryHandler: handler });
      await waitForPromises();
    });

    it('renders enabled types section with no rows', () => {
      expect(findEnabledCrudComponent().exists()).toBe(true);
      expect(findEnabledTypeRows()).toHaveLength(0);
    });

    it('does not render disabled types toggle', () => {
      expect(findDisabledTypesToggleButton().exists()).toBe(false);
    });
  });

  describe('error handling', () => {
    beforeEach(async () => {
      const handler = jest.fn().mockRejectedValue(new Error('GraphQL error'));
      createWrapper({ queryHandler: handler });
      await waitForPromises();
    });

    it('shows error alert with correct message', () => {
      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toBe('Failed to fetch work item types.');
    });

    it('hides loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });
  });
});
