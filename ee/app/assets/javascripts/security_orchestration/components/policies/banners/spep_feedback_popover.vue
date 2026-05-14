<script>
import { uniqueId } from 'lodash-es';
import { GlPopover, GlLink, GlBadge, GlButton, GlIcon } from '@gitlab/ui';
import { s__, __ } from '~/locale';

const SURVEY_URL = 'https://gitlab.fra1.qualtrics.com/jfe/form/SV_0iJvyxIEQxV4trU';

export default {
  name: 'SpepFeedbackPopover',
  components: {
    GlPopover,
    GlLink,
    GlBadge,
    GlButton,
    GlIcon,
  },
  surveyUrl: SURVEY_URL,
  i18n: {
    title: s__('SecurityOrchestration|Share your feedback'),
    feedbackText: s__(
      'SecurityOrchestration|Help us improve scheduled pipeline execution policies by sharing your thoughts and suggestions.',
    ),
    linkText: s__('SecurityOrchestration|Give feedback'),
    experiment: __('Experiment'),
  },
  data() {
    return {
      popoverTargetId: uniqueId('spep-feedback-badge-'),
    };
  },
};
</script>

<template>
  <span class="gl-inline-block gl-pt-2">
    <gl-button
      :id="popoverTargetId"
      variant="link"
      class="gl-align-middle"
      data-testid="spep-feedback-button"
    >
      <gl-badge variant="neutral" data-testid="spep-experiment-badge">
        <span class="gl-p-1">
          {{ $options.i18n.experiment }}
        </span>
      </gl-badge>
    </gl-button>
    <gl-popover
      :target="popoverTargetId"
      triggers="hover focus click"
      placement="top"
      boundary="viewport"
      data-testid="spep-feedback-popover"
    >
      <template #title>{{ $options.i18n.title }}</template>
      <p class="gl-mb-2 gl-text-sm">{{ $options.i18n.feedbackText }}</p>
      <gl-link
        :href="$options.surveyUrl"
        target="_blank"
        rel="noopener noreferrer"
        data-testid="feedback-survey-link"
      >
        <gl-icon name="comment" class="gl-mr-2" />
        {{ $options.i18n.linkText }}
      </gl-link>
    </gl-popover>
  </span>
</template>
