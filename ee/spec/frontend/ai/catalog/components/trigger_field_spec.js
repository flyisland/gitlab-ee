import { shallowMount } from '@vue/test-utils';
import { GlToken, GlLink, GlSprintf } from '@gitlab/ui';
import TriggerField from 'ee/ai/catalog/components/trigger_field.vue';
import {
  FLOW_TRIGGERS_EDIT_ROUTE,
  FLOW_TRIGGERS_NEW_ROUTE,
} from 'ee/ai/duo_agents_platform/router/constants';
import { buildPipelineHooksFilter } from 'ee_jest/ai/duo_agents_platform/mock_data';
import { mockFlow, mockFlowConfigurationForProject } from '../mock_data';

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
  const findAllTokens = () => wrapper.findAllComponents(GlToken);

  describe('when flowTrigger is empty', () => {
    describe('when user can manage triggers', () => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockFlow,
              configurationForProject: {
                ...mockFlowConfigurationForProject,
                flowTrigger: null,
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
    });

    describe('when user cannot manage triggers', () => {
      beforeEach(() => {
        createComponent({
          props: {
            item: {
              ...mockFlow,
              configurationForProject: {
                ...mockFlowConfigurationForProject,
                flowTrigger: null,
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

  describe('when flowTrigger exists', () => {
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

      it('renders triggers', () => {
        const tokens = findAllTokens();

        expect(tokens).toHaveLength(1);
        expect(tokens.at(0).text()).toBe('Mention');
      });

      it('renders trigger edit link', () => {
        const editLink = findEditLink();

        expect(editLink.text()).toBe('Edit');
        expect(editLink.props('to')).toEqual({
          name: FLOW_TRIGGERS_EDIT_ROUTE,
          params: { id: 73 },
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

      it('renders triggers', () => {
        const tokens = findAllTokens();

        expect(tokens).toHaveLength(1);
        expect(tokens.at(0).text()).toBe('Mention');
      });

      it('does not render trigger edit link', () => {
        expect(findEditLink().exists()).toBe(false);
      });
    });
  });

  describe('when flowTrigger has pipeline event with filter', () => {
    const flowWithPipelineEventTrigger = (filter) => ({
      ...mockFlow,
      configurationForProject: {
        ...mockFlowConfigurationForProject,
        flowTrigger: {
          ...mockFlowConfigurationForProject.flowTrigger,
          eventTypes: [3],
          filter,
        },
      },
    });

    it('renders the configured statuses inside the pipeline events token', () => {
      createComponent({
        props: {
          item: flowWithPipelineEventTrigger(
            buildPipelineHooksFilter({ value: ['failed', 'canceled'] }),
          ),
        },
      });

      const tokens = findAllTokens();

      expect(tokens).toHaveLength(1);
      expect(tokens.at(0).text()).toBe('Pipeline events (Failed, Canceled)');
    });

    it('does not append statuses when the filter is not parseable by the field', () => {
      createComponent({
        props: {
          item: flowWithPipelineEventTrigger(
            buildPipelineHooksFilter({ operator: 'eq', value: 'failed' }),
          ),
        },
      });

      const tokens = findAllTokens();

      expect(tokens.at(0).text()).toBe('Pipeline events');
    });
  });

  describe('when flowTrigger has a merge_request event with an action filter', () => {
    it('renders the configured action inside the merge request token', () => {
      createComponent({
        props: {
          item: {
            ...mockFlow,
            configurationForProject: {
              ...mockFlowConfigurationForProject,
              flowTrigger: {
                ...mockFlowConfigurationForProject.flowTrigger,
                eventTypes: [6],
                filter: {
                  merge_request: {
                    rules: [{ field: 'action', operator: 'in', value: ['approved'] }],
                  },
                },
              },
            },
          },
        },
      });

      const tokens = findAllTokens();

      expect(tokens).toHaveLength(1);
      expect(tokens.at(0).text()).toBe('Merge request (Approved)');
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
