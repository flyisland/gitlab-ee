import { GlCollapsibleListbox } from '@gitlab/ui';
import { nextTick } from 'vue';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SchemaEntityPicker from 'ee/orbit/dashboard/schema/schema_entity_picker.vue';
import { schemaDomains } from 'ee/orbit/dashboard/schema/schema_graph';
import { mockExpandedSchema } from '../../mock_data';

describe('SchemaEntityPicker', () => {
  let wrapper;

  const createComponent = ({ mountFn = shallowMountExtended, props = {} } = {}) => {
    wrapper = mountFn(SchemaEntityPicker, {
      propsData: {
        domains: schemaDomains(mockExpandedSchema),
        selectedEntity: 'Pipeline',
        itemCounts: { pipeline: 1200 },
        ...props,
      },
    });
  };

  const findListbox = () => wrapper.findComponent(GlCollapsibleListbox);
  const groupedNames = () =>
    findListbox()
      .props('items')
      .map((group) => [group.text, group.options.map((option) => option.value)]);

  describe('when closed', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows the selected entity on a searchable listbox', () => {
      expect(findListbox().props()).toMatchObject({
        selected: 'Pipeline',
        toggleText: 'Pipeline',
        searchable: true,
        searchPlaceholder: 'Search entities',
        noResultsText: 'No entities match your search.',
      });
    });

    it('groups the entities by domain', () => {
      expect(groupedNames()).toEqual([
        ['Projects', ['User', 'Project']],
        ['Pipelines', ['Job', 'Pipeline', 'Stage']],
      ]);
    });

    it('emits select with the picked entity', () => {
      findListbox().vm.$emit('select', 'Stage');

      expect(wrapper.emitted('select')).toEqual([['Stage']]);
    });
  });

  describe('with no entity selected', () => {
    beforeEach(() => {
      createComponent({ props: { selectedEntity: null } });
    });

    it('asks the user to select an entity', () => {
      expect(findListbox().props()).toMatchObject({
        selected: null,
        toggleText: 'Select an entity',
      });
    });
  });

  describe('with a search', () => {
    beforeEach(async () => {
      createComponent();
      findListbox().vm.$emit('search', 'stage');
      await nextTick();
    });

    it('keeps only the matching entities', () => {
      expect(groupedNames()).toEqual([['Pipelines', ['Stage']]]);
    });
  });

  describe('when rendered in full', () => {
    beforeEach(() => {
      createComponent({ mountFn: mountExtended });
    });

    it('shows each entity with its count in the graph', () => {
      const rows = wrapper.findAll('[role="option"]').wrappers.map((row) => row.text());

      expect(rows).toEqual(['User', 'Project', 'Job', 'Pipeline 1,200', 'Stage']);
    });
  });
});
