import { GlDrawer, GlSearchBoxByType } from '@gitlab/ui';
import { nextTick } from 'vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import QueryGqlSyntax from 'ee/orbit/dashboard/query_editor/query_gql_syntax.vue';
import QueryJsonExamples from 'ee/orbit/dashboard/query_editor/query_json_examples.vue';
import QueryReferenceDrawer from 'ee/orbit/dashboard/query_editor/query_reference_drawer.vue';
import { normalizeSchema } from 'ee/orbit/dashboard/schema/schema_graph';
import { mockExpandedSchema } from '../../mock_data';

describe('QueryReferenceDrawer', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = mountExtended(QueryReferenceDrawer, {
      propsData: { open: true, schema: normalizeSchema(mockExpandedSchema), isGql: true, ...props },
      attachTo: document.body,
    });
  };

  const findTabTitles = () => wrapper.findAllByRole('tab').wrappers.map((tab) => tab.text());
  const findEntityNames = () =>
    wrapper.findAllByTestId('query-reference-entity').wrappers.map((entity) => entity.text());
  const findInsertNames = () =>
    wrapper.findAllByTestId('query-reference-insert').wrappers.map((button) => button.text());
  const findRelationships = () =>
    wrapper
      .findAllByTestId('query-reference-relationship')
      .wrappers.map((row) => row.text().replace(/\s+/g, ' '));
  const selectEntity = async (name) => {
    const entity = wrapper
      .findAllByTestId('query-reference-entity')
      .wrappers.find((item) => item.text() === name);
    await entity.trigger('click');
  };
  const clickInsert = async (name) => {
    const button = wrapper
      .findAllByTestId('query-reference-insert')
      .wrappers.find((item) => item.text() === name);
    await button.trigger('click');
  };

  describe('with GQL on', () => {
    beforeEach(() => {
      createComponent();
    });

    it('keeps the drawer title and close button in view', () => {
      expect(wrapper.findComponent(GlDrawer).props('headerSticky')).toBe(true);
    });

    it('lists every entity and shows the Schema and GQL syntax tabs', () => {
      expect(findEntityNames()).toEqual(['User', 'Project', 'Job', 'Pipeline', 'Stage']);
      expect(findTabTitles()).toEqual(['Schema', 'GQL syntax']);
      expect(wrapper.findComponent(QueryGqlSyntax).exists()).toBe(true);
      expect(wrapper.findComponent(QueryJsonExamples).exists()).toBe(false);
    });

    describe('when the drawer closes', () => {
      beforeEach(() => {
        wrapper.findComponent(GlDrawer).vm.$emit('close');
      });

      it('emits close', () => {
        expect(wrapper.emitted('close')).toHaveLength(1);
      });
    });

    describe('when the user searches', () => {
      beforeEach(async () => {
        wrapper.findComponent(GlSearchBoxByType).vm.$emit('input', 'user');
        await nextTick();
      });

      it('lists only the matching entities', () => {
        expect(findEntityNames()).toEqual(['User']);
      });
    });

    describe('when the user selects an entity', () => {
      beforeEach(async () => {
        await selectEntity('User');
      });

      it('shows the entity name, its properties, and its relationships as names to insert', () => {
        expect(findEntityNames()).toEqual([]);
        expect(findInsertNames()).toEqual(['User', 'id', 'username', 'AUTHORED', 'AUTHORED']);
        expect(findRelationships()).toEqual(['→ To Pipeline AUTHORED', '→ To Job AUTHORED']);
      });

      it('moves focus to the back button', () => {
        expect(document.activeElement).toBe(wrapper.findByTestId('query-reference-back').element);
      });

      it('emits the entity or relationship name the user selects', async () => {
        await clickInsert('User');
        await clickInsert('AUTHORED');

        expect(wrapper.emitted('insert')).toEqual([['User'], ['AUTHORED']]);
      });

      it('emits the property the user selects with its entity', async () => {
        await clickInsert('username');

        expect(wrapper.emitted('insert-property')).toEqual([
          [{ entity: 'User', property: 'username' }],
        ]);
      });

      describe('and goes back', () => {
        beforeEach(async () => {
          await wrapper.findByTestId('query-reference-back').trigger('click');
        });

        it('lists every entity again', () => {
          expect(findEntityNames()).toEqual(['User', 'Project', 'Job', 'Pipeline', 'Stage']);
        });
      });
    });

    describe('when the user selects an entity with incoming relationships', () => {
      beforeEach(async () => {
        await selectEntity('Stage');
      });

      it('shows where they come from', () => {
        expect(findRelationships()).toEqual(['← From Pipeline CONTAINS']);
      });
    });
  });

  describe('when the drawer is closed', () => {
    beforeEach(() => {
      createComponent({ open: false });
    });

    it('measures the page header again on the next open', () => {
      expect(wrapper.findComponent(GlDrawer).props('headerHeight')).toBe('0');
    });
  });

  describe('with GQL off', () => {
    beforeEach(() => {
      createComponent({ isGql: false });
    });

    it('shows the Schema and JSON examples tabs', () => {
      expect(findTabTitles()).toEqual(['Schema', 'JSON examples']);
      expect(wrapper.findComponent(QueryJsonExamples).exists()).toBe(true);
      expect(wrapper.findComponent(QueryGqlSyntax).exists()).toBe(false);
    });
  });

  describe('with no schema', () => {
    beforeEach(() => {
      createComponent({ schema: normalizeSchema({}) });
    });

    it('says that the schema is not available', () => {
      expect(wrapper.text()).toContain('The schema is not available. Try again later.');
      expect(findEntityNames()).toEqual([]);
    });
  });
});
