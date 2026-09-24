import { nextTick } from 'vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import CiComponentDrawer from 'jh/ci/pipeline_editor/components/ci_component_drawer/ci_component_drawer.vue';
import CiComponent from 'jh/ci/pipeline_editor/components/ci_component_drawer/ci_component.vue';
import { mockCiYml } from 'jest/ci/pipeline_editor/mock_data';

const testComponent = [
  {
    component: 'test',
    inputs: [
      {
        key: 'test',
        value: 'val',
      },
    ],
  },
];

describe('CiComponentDrawer', () => {
  let wrapper;
  const createComponent = (props = {}) => {
    wrapper = mountExtended(CiComponentDrawer, {
      propsData: {
        ciFileContent: mockCiYml,
        ...props,
      },
    });
  };
  const findConfirmBtn = () => wrapper.findComponentByTestId('ci-component-confirm-button');
  const findCancelBtn = () => wrapper.findComponentByTestId('ci-component-cancel-button');
  const findCiComponent = () => wrapper.findComponent(CiComponent);

  beforeEach(() => {
    createComponent({
      isVisible: true,
    });
  });

  it('renders component correctly', () => {
    expect(findCiComponent().exists()).toBe(true);
  });

  it('updates the ci components', () => {
    const ciComponent = findCiComponent();
    ciComponent.vm.$emit('update', testComponent);

    expect(wrapper.vm.components).toEqual(testComponent);
  });

  it('should emit updateConfig when confirm button is clicked', async () => {
    const ciComponent = findCiComponent();
    ciComponent.vm.$emit('update', testComponent);
    findConfirmBtn().vm.$emit('click');
    await nextTick();

    expect(wrapper.emitted('updateCiConfig').at(0)).toHaveLength(1);
  });

  it('should clear the internal state when cancel button is clicked', async () => {
    const ciComponent = findCiComponent();
    ciComponent.vm.$emit('update', testComponent);
    findCancelBtn().vm.$emit('click');
    await nextTick();

    expect(wrapper.vm.components).toEqual([]);
  });
});
