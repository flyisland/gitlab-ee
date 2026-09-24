import { shallowMount } from '@vue/test-utils';
import { GlLink, GlSprintf } from '@gitlab/ui';
import TriggerField from 'ee/ai/catalog/components/trigger_field.vue';
import FlowTriggerEventTokens from 'ee/ai/duo_agents_platform/components/common/flow_trigger_event_tokens.vue';
import {
  FLOW_TRIGGERS_EDIT_ROUTE,
  FLOW_TRIGGERS_NEW_ROUTE,
} from 'ee/ai/duo_agents_platform/router/constants';
import {
  mockFlow,
  mockFlowConfigurationForProject,
  mockFlowTrigger,
  mockFlowTriggerSecond,
} from '../mock_data';

const emptyFlowTriggers = [];

describe('TriggerFieldSpec', () => {
  let wrapper;

  const defaultProps = {
    item: mockFlow,
  };

  const createComponent = ({ props = {}, provide = {} } = {}) => {
    wrapper = shallowMount(TriggerField, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      provide,
      stubs: {
        GlSprintf,
      },
    });
  };

  const findEditLink = () => wrapper.findComponent(GlLink);
  const findAllLinks = () => wrapper.findAllComponents(GlLink);
  const findEventTokens = () => wrapper.findComponent(FlowTriggerEventTokens);
  const findAllEventTokens = () => wrapper.findAllComponents(FlowTriggerEventTokens);

  describe('when flowTriggers is empty', () => {
    describe('when user can manage triggers', () => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockFlow,
              configurationForProject: {
                ...mockFlowConfigurationForProject,
                flowTriggers: emptyFlowTriggers,
              },
            },
          },
          provide: {
            glAbilities: { manageAiFlowTriggers: true },
          },
        });
      });

      it('renders "Add a trigger" message with link', () => {
        const link = wrapper.findComponent(GlLink);

        expect(wrapper.text()).toBe(
          'No triggers configured. Add a trigger to make this flow available.',
        );
        expect(link.props('to')).toEqual({ name: FLOW_TRIGGERS_NEW_ROUTE });
      });

      it('does not render the trigger event tokens', () => {
        expect(findEventTokens().exists()).toBe(false);
      });
    });

    describe('when user cannot manage triggers', () => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockFlow,
              configurationForProject: {
                ...mockFlowConfigurationForProject,
                flowTriggers: emptyFlowTriggers,
              },
            },
          },
          provide: {
            glAbilities: { manageAiFlowTriggers: false },
          },
        });
      });

      it('renders "No triggers configured" without a link', () => {
        expect(wrapper.text()).toBe('No triggers configured.');
        expect(findAllLinks()).toHaveLength(0);
      });
    });
  });

  describe('when flowTriggers exist', () => {
    describe('when user can manage triggers', () => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockFlow,
              configurationForProject: mockFlowConfigurationForProject,
            },
          },
          provide: {
            glAbilities: { manageAiFlowTriggers: true },
          },
        });
      });

      it('renders a token group and edit link for every stored trigger', () => {
        const eventTokens = findAllEventTokens();

        expect(eventTokens).toHaveLength(2);
        expect(eventTokens.at(0).props('flowTrigger')).toEqual(mockFlowTrigger);
        expect(eventTokens.at(1).props('flowTrigger')).toEqual(mockFlowTriggerSecond);
      });

      it('renders an edit link per trigger pointing at each trigger', () => {
        const editLinks = findAllLinks();

        expect(editLinks).toHaveLength(2);
        expect(editLinks.at(0).text()).toBe('Edit');
        expect(editLinks.at(0).props('to')).toEqual({
          name: FLOW_TRIGGERS_EDIT_ROUTE,
          params: { id: 73 },
        });
        expect(editLinks.at(1).props('to')).toEqual({
          name: FLOW_TRIGGERS_EDIT_ROUTE,
          params: { id: 74 },
        });
      });
    });

    describe('when user cannot manage triggers', () => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockFlow,
              configurationForProject: mockFlowConfigurationForProject,
            },
          },
          provide: {
            glAbilities: { manageAiFlowTriggers: false },
          },
        });
      });

      it('renders the trigger event tokens', () => {
        expect(findEventTokens().exists()).toBe(true);
      });

      it('does not render trigger edit link', () => {
        expect(findEditLink().exists()).toBe(false);
      });
    });
  });

  describe('when item is foundational', () => {
    beforeEach(() => {
      createComponent({
        props: {
          item: {
            ...mockFlow,
            foundational: true,
            configurationForProject: mockFlowConfigurationForProject,
          },
        },
        provide: {
          glAbilities: { manageAiFlowTriggers: true },
        },
      });
    });

    it('does not render trigger edit link', () => {
      expect(findEditLink().exists()).toBe(false);
    });
  });
});
