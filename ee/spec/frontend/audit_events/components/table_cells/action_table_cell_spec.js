import { shallowMount } from '@vue/test-utils';

import ActionTableCell from 'ee/audit_events/components/table_cells/action_table_cell.vue';

describe('ActionTableCell component', () => {
  it('renders the text prop as plain text', () => {
    const input =
      '<a href="https://magic.url/">Link</a> <i>Test</i> <h1>HTML</h1> <strong>Flex</strong>';
    const wrapper = shallowMount(ActionTableCell, {
      propsData: { text: input },
    });

    expect(wrapper.text()).toBe(input);
  });
});
