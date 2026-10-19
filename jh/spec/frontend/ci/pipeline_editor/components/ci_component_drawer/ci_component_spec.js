import { nextTick } from 'vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import CiComponent from 'jh/ci/pipeline_editor/components/ci_component_drawer/ci_component.vue';

describe('CiComponent', () => {
  let wrapper;
  const createComponent = () => {
    wrapper = shallowMountExtended(CiComponent);
  };

  const findAllCiComponents = () => wrapper.findAllByTestId('ci-component');
  const findCiComponent = (idx) => findAllCiComponents().at(idx);
  const findAddComponentBtn = () => wrapper.findComponentByTestId('add-ci-component-btn');
  const findDeleteComponentBtn = (idx) =>
    findCiComponent(idx).findComponent('[data-testid="ci-component-delete-component-btn"]');
  const findAddInputButton = (idx) =>
    findCiComponent(idx).findComponent('[data-testid="add-ci-component-input-btn"]');
  const findDeleteInputButton = (idx) =>
    findCiComponent(idx).findComponent('[data-testid="ci-component-delete-input-btn"]');
  const findCiInputs = (idx) => findCiComponent(idx).findAll('[data-testid="ci-component-input"]');

  beforeEach(() => {
    createComponent();
  });

  it('renders component no ci component', () => {
    expect(findAllCiComponents()).toHaveLength(0);
  });

  describe('ci component events', () => {
    it('should create a component when add button is clicked', async () => {
      const addComponentBtn = findAddComponentBtn();

      addComponentBtn.vm.$emit('click');
      await nextTick();
      expect(findAllCiComponents()).toHaveLength(1);
    });

    it('should be able to delete component when delete component button is clicked', async () => {
      const addComponentBtn = findAddComponentBtn();

      addComponentBtn.vm.$emit('click');
      await nextTick();
      expect(findAllCiComponents()).toHaveLength(1);

      findDeleteComponentBtn(0).vm.$emit('click');
      await nextTick();
      expect(findAllCiComponents()).toHaveLength(0);
    });

    it('should create a input section for inputting variables', async () => {
      const addComponentBtn = findAddComponentBtn();

      addComponentBtn.vm.$emit('click');
      await nextTick();
      expect(findCiInputs(0)).toHaveLength(1);
      const addInputBtn = findAddInputButton(0);

      addInputBtn.vm.$emit('click');
      await nextTick();
      expect(findCiInputs(0)).toHaveLength(2);
    });

    it('cannot delete input items when there is only one input item', async () => {
      const addComponentBtn = findAddComponentBtn();

      addComponentBtn.vm.$emit('click');
      await nextTick();
      expect(findCiInputs(0)).toHaveLength(1);
      expect(findDeleteInputButton(0).exists()).toBe(false);
    });

    it('should be able to delete input section for inputting variables', async () => {
      const addComponentBtn = findAddComponentBtn();

      addComponentBtn.vm.$emit('click');
      await nextTick();
      expect(findCiInputs(0)).toHaveLength(1);
      const addInputBtn = findAddInputButton(0);

      addInputBtn.vm.$emit('click');
      await nextTick();
      expect(findCiInputs(0)).toHaveLength(2);
      const deleteInputBtn = findDeleteInputButton(0);
      deleteInputBtn.vm.$emit('click');
      await nextTick();
      expect(findCiInputs(0)).toHaveLength(1);
    });
  });
});
