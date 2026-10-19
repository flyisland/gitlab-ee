import { GlTruncate } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import SchemaEntityDetails from 'ee/orbit/dashboard/schema/schema_entity_details.vue';

describe('SchemaEntityDetails', () => {
  let wrapper;

  const node = {
    name: 'MergeRequest',
    description: 'A merge request',
    properties: [
      { name: 'state', data_type: 'Enum', nullable: false, enum_values: ['opened', 'merged'] },
      { name: 'iid', data_type: 'Int', nullable: true, enum_values: [] },
      { name: 'title', data_type: 'String', nullable: false, enum_values: [] },
    ],
  };
  const relationships = {
    outgoing: [{ edge: 'HAS_LABEL', description: 'Entity has a label applied', entity: 'Label' }],
    incoming: [
      { edge: 'AUTHORED', description: 'a', entity: 'User' },
      { edge: 'MERGED', description: 'm', entity: 'User' },
    ],
  };

  const createComponent = (props = {}) => {
    wrapper = mountExtended(SchemaEntityDetails, {
      propsData: {
        entity: { name: 'MergeRequest', icon: 'merge-request', color: '#ff9900' },
        node,
        relationships,
        ...props,
      },
    });
  };

  const findOutgoing = () => wrapper.findByTestId('schema-outgoing');
  const findExplore = () => wrapper.findByTestId('schema-explore');

  describe('with relationships and properties', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows outgoing relationships with their target and a truncated description', () => {
      expect(findOutgoing().text()).toContain('From MergeRequest');
      expect(findOutgoing().text()).toContain('HAS_LABEL');
      expect(findOutgoing().findComponent(GlTruncate).props()).toMatchObject({
        text: 'Entity has a label applied',
        withTooltip: true,
      });
    });

    it('groups incoming relationships by entity, each with its description', () => {
      const incoming = wrapper.findByTestId('schema-incoming');

      expect(
        incoming.findAll('li li').wrappers.map((row) => row.text().replace(/\s+/g, ' ')),
      ).toEqual(['AUTHORED a', 'MERGED m']);
      expect(incoming.find('li').text()).toMatch(/^User/);
      expect(
        incoming.findAllComponents(GlTruncate).wrappers.map((truncate) => truncate.props('text')),
      ).toEqual(['a', 'm']);
    });

    it('lays the properties out in a fixed table that wraps long names and values', () => {
      const table = wrapper.findByTestId('schema-properties');

      expect(table.classes()).toContain('b-table-fixed');
      expect(
        table
          .findAll('tbody code, tbody td:last-child span')
          .wrappers.every((cell) => cell.classes().includes('gl-break-words')),
      ).toBe(true);
    });

    it('lists properties with their type, enum values, and whether they can be empty', () => {
      const rows = wrapper.findByTestId('schema-properties').findAll('tbody tr');

      expect(rows.wrappers.map((row) => row.findAll('td').wrappers.map((td) => td.text()))).toEqual(
        [
          ['state', 'Enum', 'opened, merged'],
          ['iid', 'Int', 'Can be empty'],
          ['title', 'String', ''],
        ],
      );
    });

    it('gives screen readers the count of each tab', () => {
      expect(wrapper.text()).toContain('3 relationships');
      expect(wrapper.text()).toContain('3 properties');
    });

    it('emits show-instances with the entity type from Explore', async () => {
      await findExplore().trigger('click');

      expect(wrapper.emitted('show-instances')).toEqual([[{ entityType: 'MergeRequest' }]]);
    });

    it('emits select with a related entity', async () => {
      await findOutgoing().find('button').trigger('click');

      expect(wrapper.emitted('select')).toEqual([['Label']]);
    });

    it('emits select with an entity from the incoming list', async () => {
      await wrapper.findByTestId('schema-incoming').find('button').trigger('click');

      expect(wrapper.emitted('select')).toEqual([['User']]);
    });

    it('emits close from the close button', async () => {
      await wrapper.findByTestId('schema-details-close').trigger('click');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });

  describe('with a known item count', () => {
    beforeEach(() => {
      createComponent({ itemCount: 4200 });
    });

    it('shows the count and Explore', () => {
      expect(wrapper.text()).toContain('4,200 in your graph');
      expect(findExplore().exists()).toBe(true);
    });
  });

  describe('with an unknown item count', () => {
    beforeEach(() => {
      createComponent({ itemCount: null });
    });

    it('shows Explore but no count', () => {
      expect(wrapper.text()).not.toContain('in your graph');
      expect(findExplore().exists()).toBe(true);
    });
  });

  describe('with no items in the graph', () => {
    beforeEach(() => {
      createComponent({ itemCount: 0 });
    });

    it('shows the count but no Explore', () => {
      expect(wrapper.text()).toContain('0 in your graph');
      expect(findExplore().exists()).toBe(false);
    });
  });
});
