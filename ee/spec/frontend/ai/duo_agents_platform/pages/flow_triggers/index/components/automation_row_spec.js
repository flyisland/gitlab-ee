import { GlDisclosureDropdown, GlIcon, GlToggle, GlTruncate } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AutomationRow from 'ee/ai/duo_agents_platform/pages/flow_triggers/index/components/automation_row.vue';
import {
  FLOW_TRIGGER_MODE_SCHEDULE,
  SCHEDULE_FREQUENCY_DAILY,
} from 'ee/ai/duo_agents_platform/constants';
import { FLOW_TRIGGERS_EDIT_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import { mockFlowTriggerFactory, mockTrigger } from '../../mocks';

describe('AutomationRow', () => {
  let wrapper;

  const findDescription = () => wrapper.findByTestId('automation-description');
  const findConditions = () => wrapper.findByTestId('automation-conditions');
  const findToggle = () => wrapper.findComponent(GlToggle);
  const findDropdown = () => wrapper.findComponent(GlDisclosureDropdown);

  const createComponent = ({ automation = mockTrigger, isToggling = false } = {}) => {
    wrapper = shallowMountExtended(AutomationRow, {
      propsData: { automation, isToggling },
    });
  };

  it('renders the description', () => {
    createComponent();

    expect(findDescription().text()).toBe('Test trigger');
  });

  it.each`
    case                  | filter                                                                                                                | icon                | text
    ${'event conditions'} | ${{}}                                                                                                                 | ${'trigger-source'} | ${'Mention, Assign'}
    ${'schedule summary'} | ${{ [FLOW_TRIGGER_MODE_SCHEDULE]: { frequency: SCHEDULE_FREQUENCY_DAILY, minute: 0, hour: 9, timezone: 'Etc/UTC' } }} | ${'clock'}          | ${'Daily at 09:00 Etc/UTC'}
  `('renders the $case', ({ filter, icon, text }) => {
    createComponent({ automation: mockFlowTriggerFactory({ filter }) });

    expect(findConditions().findComponent(GlIcon).props('name')).toBe(icon);
    expect(findConditions().findComponent(GlTruncate).props('text')).toBe(text);
  });

  it('renders the toggle with a stable label and emits toggle on change', () => {
    createComponent({ isToggling: true });

    expect(findToggle().props()).toMatchObject({
      value: true,
      isLoading: true,
      label: 'Turn automation on or off: Test trigger',
    });

    findToggle().vm.$emit('change', false);

    expect(wrapper.emitted('toggle')).toEqual([[{ id: mockTrigger.id, active: false }]]);
  });

  it('renders the edit and delete actions', () => {
    createComponent();

    const [edit, remove] = findDropdown().props('items');

    expect(edit).toMatchObject({
      text: 'Edit automation',
      to: { name: FLOW_TRIGGERS_EDIT_ROUTE, params: { id: 1 } },
    });
    expect(remove.text).toBe('Delete automation');

    remove.action();

    expect(wrapper.emitted('delete')).toEqual([[mockTrigger.id]]);
  });
});
