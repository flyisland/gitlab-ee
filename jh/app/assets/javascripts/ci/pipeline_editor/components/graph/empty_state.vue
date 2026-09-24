<script>
import { GlEmptyState, GlSprintf } from '@gitlab/ui';
import pipelineEmptySvgPath from '@gitlab/svgs/dist/illustrations/empty-state/empty-pipeline-md.svg?url';
import { s__ } from '~/locale';

export default {
  components: {
    GlEmptyState,
    GlSprintf,
  },
  pipelineEmptySvgPath,
  i18n: {
    title: s__('JH|Pipelines|No configuration found'),
    description: s__(
      'JH|Pipelines|It seems like you do not have any configurations, please proceed at %{boldStart}Edit%{boldEnd} tab for further information.',
    ),
  },
};
</script>

<template>
  <gl-empty-state :svg-path="$options.pipelineEmptySvgPath" :title="$options.i18n.title">
    <template #description>
      <gl-sprintf :message="$options.i18n.description">
        <template #bold="{ content }">
          <strong>{{ content }}</strong>
        </template>
      </gl-sprintf>
    </template>
  </gl-empty-state>
</template>
