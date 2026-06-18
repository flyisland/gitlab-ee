import { GlCollapsibleListbox } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import MergeRequestEventsConfiguration from 'ee/ai/duo_agents_platform/pages/flow_triggers/components/event_configurations/merge_request_events_configuration.vue';

describe('MergeRequestEventsConfiguration', () => {
  let wrapper;

  const mockMRApprovedFilter = {
    merge_request: { rules: [{ field: 'action', operator: 'in', value: ['approved'] }] },
  };

  const createWrapper = ({ props = {}, glFeatures = {} } = {}) => {
    wrapper = shallowMountExtended(MergeRequestEventsConfiguration, {
      propsData: props,
      provide: {
        glFeatures: {
          ...glFeatures,
        },
      },
    });
  };

  const findListbox = () => wrapper.findComponent(GlCollapsibleListbox);

  describe('action options', () => {
    it('renders every action when its feature flag is enabled', () => {
      createWrapper();

      expect(
        findListbox()
          .props('items')
          .map((item) => item.value),
      ).toEqual(['approved']);
    });
  });

  describe('toggle text', () => {
    it('shows the placeholder when nothing is selected', () => {
      createWrapper();

      expect(findListbox().props('toggleText')).toBe('Select a condition');
    });

    it('joins the selected action labels', () => {
      createWrapper({ props: { value: mockMRApprovedFilter } });

      expect(findListbox().props('toggleText')).toBe('Approved');
    });
  });

  describe('selection', () => {
    it('emits input with the merge_request action filter when an action is selected', async () => {
      createWrapper({ props: { value: {} } });

      await findListbox().vm.$emit('select', ['approved']);

      expect(wrapper.emitted('input')).toEqual([[mockMRApprovedFilter]]);
    });

    it('drops the merge_request scope when no action is selected', async () => {
      createWrapper({ props: { value: mockMRApprovedFilter } });

      await findListbox().vm.$emit('select', []);

      expect(wrapper.emitted('input')).toEqual([[{}]]);
    });
  });
});
