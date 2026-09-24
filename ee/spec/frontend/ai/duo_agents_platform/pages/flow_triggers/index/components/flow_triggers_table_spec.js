import { GlToken, GlAvatar, GlToggle } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import FlowTriggersTable from 'ee/ai/duo_agents_platform/pages/flow_triggers/index/components/flow_triggers_table.vue';
import { FLOW_TRIGGERS_EDIT_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import {
  mockFlowTriggerFactory,
  mockTriggers,
  mockTriggersWithoutUser,
  mockInactiveTriggers,
} from '../../mocks';

describe('FlowTriggersTable', () => {
  let wrapper;

  const findAvatar = () => wrapper.findComponent(GlAvatar);
  const findTokens = () => wrapper.findAllComponents(GlToken);
  const findConfigPath = () => wrapper.findByTestId('flow-trigger-config-path');
  const findCatalogItem = () => wrapper.findByTestId('flow-trigger-catalog-item');
  const findConfigPathFallback = () => wrapper.findByTestId('flow-trigger-config-path-fallback');
  const findEditButton = () => wrapper.findComponentByTestId('flow-trigger-edit-action');
  const findDeleteButton = () => wrapper.findComponentByTestId('flow-trigger-delete-action');
  const findToggle = () => wrapper.findComponent(GlToggle);

  const createComponent = (props = {}) => {
    wrapper = mountExtended(FlowTriggersTable, {
      propsData: {
        aiFlowTriggers: mockTriggers,
        ...props,
      },
    });
  };

  describe('Rendering', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays correct event type tokens', () => {
      const tokens = findTokens();

      expect(tokens).toHaveLength(2);
      expect(tokens.at(0).text()).toBe('Mention');
      expect(tokens.at(1).text()).toBe('Assign');
    });

    describe('when a trigger uses merge request lifecycle event types', () => {
      beforeEach(() => {
        createComponent({
          aiFlowTriggers: [mockFlowTriggerFactory({ eventTypes: [4, 5], filter: {} })],
        });
      });

      it('folds them into a single merge request token instead of rendering blanks', () => {
        const tokens = findTokens();

        expect(tokens).toHaveLength(1);
        expect(tokens.at(0).text()).toBe('Merge request (Merge conflict, Marked ready)');
      });
    });

    it('sets a link to edit the item', () => {
      expect(findEditButton().props('to')).toEqual({
        name: FLOW_TRIGGERS_EDIT_ROUTE,
        params: { id: 1 },
      });
    });

    describe('when there is a config path', () => {
      it('displays the config path link', () => {
        expect(findConfigPath().exists()).toBe(true);
      });

      it('displays only the basename of the config path', () => {
        // configPath is '/config/test.yml'; only the last segment should be shown
        expect(findConfigPath().text()).toBe('test.yml');
      });

      it('does not display the fallback string', () => {
        expect(findConfigPathFallback().exists()).toBe(false);
      });
    });

    describe('when there is a catalog item and no config path', () => {
      beforeEach(() => {
        createComponent({
          aiFlowTriggers: [mockFlowTriggerFactory({ configPath: '', configUrl: '' })],
        });
      });

      it('displays the catalog item name', () => {
        expect(findCatalogItem().text()).toBe('Test Flow');
      });

      it('does not display the config path', () => {
        expect(findConfigPath().exists()).toBe(false);
      });

      it('does not display the fallback string', () => {
        expect(findConfigPathFallback().exists()).toBe(false);
      });
    });

    describe('when there is no config path', () => {
      beforeEach(() => {
        createComponent({
          aiFlowTriggers: [
            mockFlowTriggerFactory({
              configPath: '',
              configUrl: '',
              aiCatalogItemConsumer: null,
            }),
          ],
        });
      });

      it('displays the fallback string', () => {
        expect(findConfigPathFallback().exists()).toBe(true);
      });

      it('does not display the config path', () => {
        expect(findConfigPath().exists()).toBe(false);
      });
    });

    describe('the active toggle', () => {
      it('is on for an active trigger', () => {
        expect(findToggle().props('value')).toBe(true);
      });

      it('is not in a loading state by default', () => {
        expect(findToggle().props('isLoading')).toBe(false);
      });

      describe('when the trigger is inactive', () => {
        beforeEach(() => {
          createComponent({ aiFlowTriggers: mockInactiveTriggers });
        });

        it('is off', () => {
          expect(findToggle().props('value')).toBe(false);
        });
      });

      describe('when the trigger id is in togglingIds', () => {
        beforeEach(() => {
          createComponent({ togglingIds: [mockTriggers[0].id] });
        });

        it('shows a loading state', () => {
          expect(findToggle().props('isLoading')).toBe(true);
        });
      });
    });

    describe('when there is user information', () => {
      it('displays the user avatar', () => {
        expect(findAvatar().exists()).toBe(true);
      });
    });

    describe('when there is no user information', () => {
      beforeEach(() => {
        createComponent({ aiFlowTriggers: mockTriggersWithoutUser });
      });

      it('does not display the user avatar', () => {
        expect(findAvatar().exists()).toBe(false);
      });
    });
  });

  describe('Interactions', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('when user flips the active toggle', () => {
      beforeEach(() => {
        findToggle().vm.$emit('change', false);
      });

      it('emits the trigger id and the requested state', () => {
        expect(wrapper.emitted('toggle-trigger')).toEqual([
          [{ id: mockTriggers[0].id, active: false }],
        ]);
      });
    });

    describe('when user clicks on delete button', () => {
      beforeEach(() => {
        findDeleteButton().vm.$emit('click');
      });

      it('emits the event', () => {
        expect(wrapper.emitted('delete-trigger')).toHaveLength(1);
      });
    });
  });
});
