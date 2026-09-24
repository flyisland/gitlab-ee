<script>
import { GlLink } from '@gitlab/ui';
import CiIcon from '~/vue_shared/components/ci_icon/ci_icon.vue';
import PipelineArtifacts from '~/ci/pipelines_page/components/pipelines_artifacts.vue';
import PipelineMiniGraph from '~/ci/pipeline_mini_graph/pipeline_mini_graph.vue';
import { keepLatestDownstreamPipelines } from '~/ci/pipeline_details/utils/parsing_utils';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  name: 'MonorepoMRPipeline',
  components: {
    CiIcon,
    TimeAgoTooltip,
    PipelineMiniGraph,
    GlLink,
    PipelineArtifacts,
  },
  props: {
    pipeline: {
      type: Object,
      default: null,
      required: false,
    },
  },
  computed: {
    status() {
      return this.pipeline.details && this.pipeline.details.status
        ? this.pipeline.details.status
        : {};
    },
    artifacts() {
      return this.pipeline?.details?.artifacts;
    },
    // The following is used by upstream component, we are simply overriding it
    // eslint-disable-next-line vue/no-unused-properties
    hasStages() {
      return this.pipeline?.details?.stages?.length > 0;
    },
    finishedAt() {
      return this.pipeline?.details?.finished_at;
    },
    downstreamPipelines() {
      const downstream = this.pipeline.triggered;
      return keepLatestDownstreamPipelines(downstream);
    },
    isMergeTrain() {
      return Boolean(this.pipeline.flags?.merge_train_pipeline);
    },
  },
};
</script>
<template>
  <div
    v-if="pipeline"
    class="ci-widget media gl-border-t-1 gl-border-t-gray-100 gl-px-5 gl-py-4 gl-border-t-solid"
  >
    <a :href="pipeline.path" class="gl-mr-3 gl-mt-2 gl-self-start">
      <ci-icon :status="status" :size="24" class="gl-flex" />
    </a>
    <div class="ci-widget-container d-flex">
      <div class="ci-widget-content">
        <div class="media-body">
          <div
            data-testid="pipeline-info-container"
            data-qa-selector="merge_request_pipeline_info_content"
            class="gl-flex gl-flex-wrap gl-items-center gl-justify-between"
          >
            <p class="mr-pipeline-title !gl-m-0 !gl-mr-3 gl-font-bold gl-text-gray-900">
              {{ pipeline.details.event_type_name }}
              <gl-link
                :href="pipeline.path"
                class="pipeline-id"
                data-testid="pipeline-id"
                data-qa-selector="pipeline_link"
                >#{{ pipeline.id }}</gl-link
              >
              {{ pipeline.details.status.label }}

              <template v-if="finishedAt">
                <time-ago-tooltip
                  :time="finishedAt"
                  tooltip-placement="bottom"
                  data-testid="finished-at"
                />
              </template>
            </p>
            <div class="gl-inline-flex gl-grow gl-items-center gl-justify-between">
              <pipeline-mini-graph
                v-if="pipeline.details.stages"
                :downstream-pipelines="downstreamPipelines"
                :is-merge-train="isMergeTrain"
                :pipeline-path="pipeline.path"
                :pipeline-stages="pipeline.details.stages"
                :upstream-pipeline="pipeline.triggered_by"
              />
              <pipeline-artifacts
                :pipeline-id="pipeline.id"
                :artifacts="artifacts"
                class="gl-ml-3"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
