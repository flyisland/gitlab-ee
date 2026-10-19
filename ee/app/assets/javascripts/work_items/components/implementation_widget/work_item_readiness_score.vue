<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';
import { InternalEvents } from '~/tracking';
import HelpPopover from '~/vue_shared/components/help_popover.vue';
import { helpPagePath } from '~/helpers/help_page_helper';
import ImplementationWidgetSegment from 'ee/vue_shared/components/work_items/implementation_widget_segment.vue';
import ReadinessBar from './readiness_bar.vue';
import {
  PLAN_READINESS_LEVELS,
  READINESS_SCORE_MEDIUM_THRESHOLD,
  READINESS_SCORE_HIGH_THRESHOLD,
} from './constants';

export default {
  name: 'WorkItemReadinessScore',
  components: {
    ImplementationWidgetSegment,
    ReadinessBar,
    GlLink,
    GlSprintf,
    HelpPopover,
  },
  mixins: [InternalEvents.mixin()],
  props: {
    score: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      hasTrackedScoreView: false,
    };
  },
  computed: {
    readinessLevel() {
      if (this.score < READINESS_SCORE_MEDIUM_THRESHOLD) return PLAN_READINESS_LEVELS.LOW;
      if (this.score < READINESS_SCORE_HIGH_THRESHOLD) return PLAN_READINESS_LEVELS.MEDIUM;
      return PLAN_READINESS_LEVELS.HIGH;
    },
    readinessLevelText() {
      return this.$options.readinessLevelText[this.readinessLevel.value];
    },
    ariaLabel() {
      return sprintf(s__('AgentPlan|Readiness: %{level}'), {
        level: this.readinessLevelText,
      });
    },
    scoreText() {
      return sprintf(s__('AgentPlan|Score: %{score} / 100'), {
        score: this.score,
      });
    },
  },
  methods: {
    trackScoreViewed() {
      if (this.hasTrackedScoreView) return;

      this.hasTrackedScoreView = true;
      this.trackEvent('view_work_item_agent_plan_readiness_score', { value: this.score });
    },
  },
  readinessLevelText: {
    [PLAN_READINESS_LEVELS.LOW.value]: s__('AgentPlan|Low'),
    [PLAN_READINESS_LEVELS.MEDIUM.value]: s__('AgentPlan|Medium'),
    [PLAN_READINESS_LEVELS.HIGH.value]: s__('AgentPlan|High'),
  },
  popoverTitle: s__('AgentPlan|What is the readiness score?'),
  readinessHelpPath: helpPagePath('user/work_items/workplan.md', { anchor: 'readiness-score' }),
  helpPopoverOptions: {
    content: s__(
      'AgentPlan|Shows how ready this work item is for an agent to run. To raise the score, add more detail to the work item description and to the workplan steps. %{linkStart}Learn more%{linkEnd}.',
    ),
  },
};
</script>
<template>
  <implementation-widget-segment :label="s__('AgentPlan|Readiness')">
    <div class="gl-flex gl-items-center gl-gap-3">
      <div class="gl-flex gl-items-center gl-gap-3" role="img" :aria-label="ariaLabel">
        <span>{{ readinessLevelText }}</span>
        <readiness-bar :readiness-level="readinessLevel" />
      </div>
      <help-popover
        :aria-label="$options.popoverTitle"
        :options="$options.helpPopoverOptions"
        class="gl-inline-flex"
        icon="information-o"
        @shown="trackScoreViewed"
      >
        <template #title>
          <div>
            <span
              class="gl-mb-2 gl-block gl-text-sm gl-font-normal gl-text-subtle"
              data-testid="readiness-score-value"
              >{{ scoreText }}
            </span>
            <span>{{ $options.popoverTitle }}</span>
          </div>
        </template>
        <gl-sprintf :message="$options.helpPopoverOptions.content">
          <template #link="{ content }">
            <gl-link :href="$options.readinessHelpPath" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </help-popover>
    </div>
  </implementation-widget-segment>
</template>
