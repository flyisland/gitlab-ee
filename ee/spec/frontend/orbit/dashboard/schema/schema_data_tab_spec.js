import { nextTick } from 'vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import SchemaDataTab from 'ee/orbit/dashboard/schema/schema_data_tab.vue';
import SchemaEntityPicker from 'ee/orbit/dashboard/schema/schema_entity_picker.vue';
import { normalizeSchema } from 'ee/orbit/dashboard/schema/schema_graph';
import { mockExpandedSchema } from '../../mock_data';

describe('SchemaDataTab', () => {
  let wrapper;
  let trackEventSpy;
  const { bindInternalEventDocument } = useMockInternalEventsTracking();
  const schema = normalizeSchema(mockExpandedSchema);

  const createComponent = async (props = {}) => {
    wrapper = mountExtended(SchemaDataTab, {
      propsData: { schema, graphStats: { pipeline: 1200 }, ...props },
      attachTo: document.body,
    });
    await nextTick();
    ({ trackEventSpy } = bindInternalEventDocument(wrapper.element));
  };

  const findByText = (testId, text) =>
    wrapper.findAllByTestId(testId).wrappers.find((item) => item.text().includes(text));
  const findMapView = () => wrapper.findByTestId('schema-map-view');
  const findPicker = () => wrapper.findComponent(SchemaEntityPicker);
  const findDetails = () => wrapper.findByTestId('schema-entity-details');
  const findBreadcrumbCurrent = () => wrapper.findByTestId('schema-breadcrumb-current');
  const findNeighborNames = () =>
    wrapper.findAllByTestId('schema-neighbor').wrappers.map((neighbor) => neighbor.text());
  const expectTracked = (label) =>
    expect(trackEventSpy).toHaveBeenCalledWith('click_orbit_schema_item', { label }, undefined);

  describe('when no entity is selected', () => {
    beforeEach(async () => {
      await createComponent();
    });

    it('shows the title and how to start', () => {
      expect(wrapper.find('h2').text()).toBe('How your data connects');
      expect(wrapper.text()).toContain('Select an entity to see how it connects.');
    });

    it('shows the picker with no entity and the domain map, with no breadcrumb or details', () => {
      expect(findPicker().props()).toMatchObject({
        selectedEntity: null,
        itemCounts: { pipeline: 1200 },
      });
      expect(findMapView().exists()).toBe(true);
      expect(wrapper.findByTestId('schema-breadcrumb-root').exists()).toBe(false);
      expect(findDetails().exists()).toBe(false);
    });

    describe('and the user selects the Pipelines domain', () => {
      beforeEach(async () => {
        await findByText('schema-domain', 'Pipelines').trigger('click');
        await nextTick();
      });

      it('opens the entity the domain points to', () => {
        expect(findDetails().text()).toContain('A CI/CD pipeline');
      });

      it('focuses the entity name', () => {
        expect(document.activeElement).toBe(findBreadcrumbCurrent().element);
      });

      it('tracks the selection from the map', () => {
        expectTracked('map');
      });
    });

    describe('and the user picks Pipeline in the picker', () => {
      beforeEach(async () => {
        findPicker().vm.$emit('select', 'Pipeline');
        await nextTick();
      });

      it('opens the entity and shows it in the picker', () => {
        expect(findDetails().text()).toContain('A CI/CD pipeline');
        expect(findPicker().props('selectedEntity')).toBe('Pipeline');
      });

      it('tracks the selection from the picker', () => {
        expectTracked('picker');
      });
    });
  });

  describe('when an entity is selected', () => {
    beforeEach(async () => {
      await createComponent({ initialEntity: 'Pipeline' });
    });

    it('keeps the title, and shows the entity in the picker and in the graph with its neighbors', () => {
      expect(wrapper.find('h2').text()).toBe('How your data connects');
      expect(findMapView().exists()).toBe(false);
      expect(findPicker().props()).toMatchObject({
        selectedEntity: 'Pipeline',
        itemCounts: { pipeline: 1200 },
      });
      expect(findNeighborNames()).toEqual(['User', 'Stage']);
    });

    it('shows its domain in the breadcrumb, its details, and its count in the graph', () => {
      expect(wrapper.text()).toMatch(/Schema\s+\/\s+Pipelines\s+\/\s+Pipeline/);
      expect(findDetails().text()).toContain('A CI/CD pipeline');
      expect(findDetails().text()).toContain('1,200 in your graph');
    });

    it('does not track the selection from the URL', () => {
      expect(trackEventSpy).not.toHaveBeenCalled();
    });

    describe('and the user picks Job in the picker', () => {
      beforeEach(async () => {
        findPicker().vm.$emit('select', 'Job');
        await nextTick();
      });

      it('moves to Job', () => {
        expect(findDetails().text()).toContain('A CI/CD job');
      });

      it('tracks the selection from the picker', () => {
        expectTracked('picker');
      });
    });

    describe('and the user picks the same entity again', () => {
      beforeEach(async () => {
        findPicker().vm.$emit('select', 'Pipeline');
        await nextTick();
      });

      it('tracks nothing', () => {
        expect(trackEventSpy).not.toHaveBeenCalled();
      });
    });

    describe('and the user selects the Stage neighbor', () => {
      beforeEach(async () => {
        await findByText('schema-neighbor', 'Stage').trigger('click');
        await nextTick();
      });

      it('moves to Stage', () => {
        expect(findDetails().text()).toContain('A pipeline stage');
      });

      it('focuses the entity name', () => {
        expect(document.activeElement).toBe(findBreadcrumbCurrent().element);
      });

      it('tracks the selection from the neighbor', () => {
        expectTracked('neighbor');
      });
    });

    describe('and the user selects a related entity in the details', () => {
      beforeEach(async () => {
        await wrapper.findByTestId('schema-outgoing').find('button').trigger('click');
      });

      it('moves to the related entity', () => {
        expect(findDetails().text()).toContain('A pipeline stage');
      });

      it('tracks the selection from the details', () => {
        expectTracked('details');
      });
    });

    describe.each(['schema-breadcrumb-root', 'schema-details-close'])(
      'and the user selects %s',
      (testId) => {
        beforeEach(async () => {
          await wrapper.findByTestId(testId).trigger('click');
          await nextTick();
        });

        it('goes back to the map and focuses it', () => {
          expect(findDetails().exists()).toBe(false);
          expect(document.activeElement).toBe(findMapView().element);
        });
      },
    );

    describe('and the user selects Explore', () => {
      beforeEach(async () => {
        await wrapper.findByTestId('schema-explore').trigger('click');
      });

      it('emits show-instances for the entity', () => {
        expect(wrapper.emitted('show-instances')).toEqual([[{ entityType: 'Pipeline' }]]);
      });
    });

    describe('and the initial entity changes to Job', () => {
      beforeEach(async () => {
        await wrapper.setProps({ initialEntity: 'Job' });
      });

      it('opens Job', () => {
        expect(findDetails().text()).toContain('A CI/CD job');
      });
    });
  });

  describe('with an entity that relates to itself', () => {
    let selfLink;
    const selfEdge = {
      name: 'CHILD_OF',
      description: 'Child pipeline',
      variants: [{ source_type: 'Pipeline', target_type: 'Pipeline' }],
    };

    beforeEach(async () => {
      await createComponent({
        schema: normalizeSchema({ ...mockExpandedSchema, edges: [...schema.edges, selfEdge] }),
        initialEntity: 'Pipeline',
      });
      selfLink = findByText('schema-outgoing', 'CHILD_OF')
        .findAll('button')
        .wrappers.find((button) => button.text() === 'Pipeline');
      selfLink.element.focus();
      await selfLink.trigger('click');
      await nextTick();
    });

    it('keeps focus on the link to itself and tracks nothing', () => {
      expect(document.activeElement).toBe(selfLink.element);
      expect(trackEventSpy).not.toHaveBeenCalled();
    });
  });

  describe('with an initial entity in another case', () => {
    beforeEach(async () => {
      await createComponent({ initialEntity: 'pipeline' });
    });

    it('selects the matching entity', () => {
      expect(findDetails().text()).toContain('A CI/CD pipeline');
    });
  });

  describe('with an initial entity that does not exist', () => {
    beforeEach(async () => {
      await createComponent({ initialEntity: 'doesnotexist' });
    });

    it('shows the map', () => {
      expect(findMapView().exists()).toBe(true);
      expect(findDetails().exists()).toBe(false);
    });
  });
});
