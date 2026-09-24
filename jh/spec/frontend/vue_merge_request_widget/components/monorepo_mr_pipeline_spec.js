import { shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import MonorepoMrPipeline from 'jh/vue_merge_request_widget/components/monorepo_mr_pipeline.vue';
import PipelineMiniGraph from '~/ci/pipeline_mini_graph/pipeline_mini_graph.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import CiIcon from '~/vue_shared/components/ci_icon/ci_icon.vue';
import { mockCentralPipeline } from '../mock_data';

describe('MonorepoMrPipeline', () => {
  let wrapper;

  const createComponent = (pipeline) => {
    wrapper = shallowMount(MonorepoMrPipeline, {
      propsData: {
        pipeline: {
          ...mockCentralPipeline,
          ...pipeline,
        },
      },
    });
  };

  const findCiIcon = () => wrapper.findComponent(CiIcon);
  const findGraph = () => wrapper.findComponent(PipelineMiniGraph);
  const findTimestamp = () => wrapper.findComponent(TimeAgoTooltip);

  it('renders pipeline component correctly', () => {
    createComponent();

    expect(wrapper.findComponent(GlLink).attributes('href')).toBe(mockCentralPipeline.path);
    expect(findTimestamp().exists()).toBe(true);
    expect(findGraph().exists()).toBe(true);
    expect(findCiIcon().props('status')).toEqual(mockCentralPipeline.details.status);
  });

  it('renders given status icon', () => {
    const icon = 'status_failed';
    createComponent({
      details: {
        ...mockCentralPipeline.details,
        status: {
          ...mockCentralPipeline.details.status,
          icon,
        },
      },
    });

    expect(findCiIcon().props('status')).toEqual({
      ...mockCentralPipeline.details.status,
      icon,
    });
  });

  it('renders no timestamp not finished', () => {
    createComponent({
      details: {
        ...mockCentralPipeline.details,
        finished_at: null,
      },
    });

    expect(findTimestamp().exists()).toBe(false);
  });

  it('renders no stage graphs when none provided', () => {
    createComponent({
      details: {
        ...mockCentralPipeline.details,
        stages: null,
      },
    });

    expect(findGraph().exists()).toBe(false);
  });
});
