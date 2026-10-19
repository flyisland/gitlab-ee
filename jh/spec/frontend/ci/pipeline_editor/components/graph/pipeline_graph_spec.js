import { GlDisclosureDropdown, GlDisclosureDropdownItem, GlButton } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { mockCiYml } from 'jest/ci/pipeline_editor/mock_data';
import { pipelineData } from 'jest/ci/pipeline_editor/components/graph/mock_data';
import PipelineGraph from 'jh/ci/pipeline_editor/components/graph/pipeline_graph.vue';
import { mockCiYmlWithoutStages } from './mock_data';

describe('<PipelineGraph />', () => {
  let wrapper;
  const mockOpenModal = jest.fn();
  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(PipelineGraph, {
      propsData: {
        ciFileContent: mockCiYml,
        showHelpMsg: false,
        pipelineData,
        ...props,
      },
      stubs: {
        StageCreationModal: {
          methods: {
            open: mockOpenModal,
          },
          template: `<div></div>`,
        },
      },
    });
  };
  const findStages = () => wrapper.findAll('.jh-stage-list');

  beforeEach(() => {
    mockOpenModal.mockClear();
    createComponent();
  });

  describe('rendering correctly', () => {
    it('renders 2 stages by default', () => {
      const stages = findStages();

      expect(stages).toHaveLength(2);
    });

    it('should show help messages for users when showHelpMsg is true', () => {
      createComponent({ showHelpMsg: true });

      expect(wrapper.findByTestId('save-work-help-msg').exists()).toBe(true);
    });
  });

  describe('events', () => {
    const findActionItem = (stage = 0, position = 0) =>
      findStages().at(stage).findAllComponents(GlDisclosureDropdownItem).at(position);

    it('adds job', () => {
      const addJobButton = findStages().at(0).findComponent(GlButton);

      addJobButton.vm.$emit('click');

      expect(wrapper.vm.jobCreationDrawer).toBe(true);
      expect(wrapper.vm.targetStage).toBe(Object.keys(wrapper.vm.groupedPipeline)[0]);
    });

    it('adds stage before', () => {
      const addStageItem = findActionItem(0, 0);

      addStageItem.vm.$emit('action');

      expect(wrapper.vm.stageCreationPosition).toBe(0);
      expect(mockOpenModal).toHaveBeenCalledTimes(1);
    });

    it('adds stage after', () => {
      const addStageItem = findActionItem(0, 1);
      addStageItem.vm.$emit('action');

      expect(wrapper.vm.stageCreationPosition).toBe(1);
      expect(mockOpenModal).toHaveBeenCalledTimes(1);
    });

    it('deletes stage', () => {
      const deletesStageItem = findActionItem(0, 2);
      deletesStageItem.vm.$emit('action');

      expect(wrapper.emitted('delete-stage')).toHaveLength(1);
    });
  });

  describe('ci config without stages explicitly defined', () => {
    it('should render UI without stage manipulation parts', () => {
      createComponent({ ciFileContent: mockCiYmlWithoutStages });

      const stages = findStages();
      expect(stages).toHaveLength(2);
      const stageOne = stages.at(0);

      expect(stageOne.findComponent(GlDisclosureDropdown).exists()).toBe(false);
    });
  });
});
