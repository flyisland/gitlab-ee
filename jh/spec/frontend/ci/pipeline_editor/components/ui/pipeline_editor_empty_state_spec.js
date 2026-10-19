import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import PipelineEditorEmptyState from 'jh/ci/pipeline_editor/components/ui/pipeline_editor_empty_state.vue';

describe('JH pipeline editor empty state', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMountExtended(PipelineEditorEmptyState, {
      provide: { usesExternalConfig: false, newPipelinePath: '' },
    });
  });

  it('links to the CI/CD catalog', () => {
    expect(wrapper.findByTestId('browse-catalog-button').attributes('href')).toBe(
      '/explore/catalog',
    );
  });

  it('starts a new CI configuration', async () => {
    await wrapper.findComponentByTestId('create-new-ci-button').vm.$emit('click');

    expect(wrapper.emitted('create-empty-config-file')).toHaveLength(1);
  });
});
