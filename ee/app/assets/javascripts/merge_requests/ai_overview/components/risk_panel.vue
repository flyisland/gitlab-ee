<script>
import { GlAnimatedChevronLgDownUpIcon, GlButton, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import { uniqueId } from 'lodash-es';
import { __, s__, sprintf } from '~/locale';
import ViewSessionButton from 'ee/ai/shared/widgets/view_session_button.vue';
import SeverityMeter from 'ee/vue_shared/components/severity_meter/severity_meter.vue';
import riskAssessmentQuery from 'ee/vue_merge_request_widget/widgets/risk_assessment/graphql/risk_assessment.query.graphql';
import {
  CONFIDENCE_LOW,
  IN_PROGRESS_STATUSES,
  STATUS_COMPLETE,
  STATUS_FAILED,
  STATUS_PENDING,
  TIER_LABELS,
  riskHeadline,
} from 'ee/vue_merge_request_widget/widgets/risk_assessment/constants';

export default {
  name: 'RiskPanel',
  components: {
    GlAnimatedChevronLgDownUpIcon,
    GlButton,
    GlSprintf,
    SeverityMeter,
    ViewSessionButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['projectPath', 'iid'],
  data() {
    return {
      riskAssessment: null,
      hasError: false,
      isExpanded: false,
      detailsId: uniqueId('ai-overview-risk-details-'),
    };
  },
  // Its own query, as in the merge widget: the field is experimental, and an error on it must
  // not take the rest of the overview down with it.
  apollo: {
    riskAssessment: {
      query: riskAssessmentQuery,
      variables() {
        return { projectPath: this.projectPath, iid: this.iid };
      },
      update: (data) => data?.project?.mergeRequest?.riskAssessment ?? null,
      error() {
        this.hasError = true;
      },
    },
  },
  computed: {
    status() {
      return this.riskAssessment?.status;
    },
    tier() {
      return this.riskAssessment?.riskTier;
    },
    // As in the merge widget: a queued refresh keeps the previous result on screen until the new
    // score replaces it, while a failed run leaves nothing to trust.
    isAssessed() {
      return [STATUS_COMPLETE, ...IN_PROGRESS_STATUSES].includes(this.status) && Boolean(this.tier);
    },
    isRefreshing() {
      return this.isAssessed && IN_PROGRESS_STATUSES.includes(this.status);
    },
    // The meter only reads a tier we still trust, so a failed run empties it.
    meterSeverity() {
      return this.isAssessed ? this.tier : null;
    },
    meterLabel() {
      return this.meterSeverity
        ? sprintf(s__('RiskAssessment|Risk level: %{level}'), {
            level: TIER_LABELS[this.meterSeverity] ?? this.meterSeverity,
          })
        : s__('RiskAssessment|Risk level not available');
    },
    headline() {
      if (this.isAssessed) return riskHeadline(this.tier, this.confidenceTier);
      if (this.status === STATUS_FAILED) {
        return s__('RiskAssessment|%{boldStart}Risk assessment:%{boldEnd} Unavailable');
      }
      if (IN_PROGRESS_STATUSES.includes(this.status)) {
        return s__('RiskAssessment|%{boldStart}Risk assessment:%{boldEnd} Queued');
      }
      if (this.status === STATUS_PENDING) {
        return s__('RiskAssessment|%{boldStart}Risk assessment:%{boldEnd} Pending');
      }

      return s__('RiskAssessment|%{boldStart}Risk assessment:%{boldEnd} Not available');
    },
    confidenceTier() {
      return this.riskAssessment?.confidenceTier;
    },
    isLowConfidence() {
      return this.confidenceTier === CONFIDENCE_LOW;
    },
    contributions() {
      return this.riskAssessment?.contributingSignals || [];
    },
    // A claim has no registered signal to take a label from, so it has none to show.
    missingSignalsText() {
      return (this.riskAssessment?.missingSignals || [])
        .map((entry) => entry.label)
        .filter(Boolean)
        .join(', ');
    },
    toggleLabel() {
      return this.isExpanded ? __('Hide details') : __('Show details');
    },
    hasDetails() {
      return (
        this.isAssessed &&
        Boolean(
          this.riskAssessment.stale || this.riskAssessment.rationale || this.contributions.length,
        )
      );
    },
  },
};
</script>

<template>
  <section
    v-if="hasError || riskAssessment"
    class="gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-default"
    data-testid="risk-panel"
  >
    <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-3 gl-px-4 gl-py-3">
      <severity-meter :severity="meterSeverity" :label="meterLabel" />
      <h3 class="gl-m-0 gl-text-sm gl-font-normal" data-testid="risk-title">
        <gl-sprintf :message="headline">
          <template #bold="{ content }">
            <strong>{{ content }}</strong>
          </template>
        </gl-sprintf>
      </h3>
      <span v-if="isRefreshing" class="gl-text-sm gl-text-subtle" data-testid="risk-updating">
        {{ s__('RiskAssessment|Updating…') }}
      </span>
      <span class="gl-mr-auto"></span>
      <view-session-button
        v-if="riskAssessment && riskAssessment.duoWorkflowId"
        size="small"
        :session-id="riskAssessment.duoWorkflowId"
      />
      <gl-button
        v-if="hasDetails && !hasError"
        v-gl-tooltip
        :title="toggleLabel"
        :aria-label="toggleLabel"
        :aria-expanded="String(isExpanded)"
        :aria-controls="detailsId"
        category="tertiary"
        size="small"
        class="btn-icon"
        data-testid="risk-details-toggle"
        @click="isExpanded = !isExpanded"
      >
        <gl-animated-chevron-lg-down-up-icon :is-on="isExpanded" variant="default" />
      </gl-button>
    </div>
    <p
      v-if="hasError"
      class="gl-m-0 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-sm gl-text-danger gl-border-t-solid"
    >
      {{ s__('RiskAssessment|Failed to load the risk assessment') }}
    </p>
    <div
      v-else-if="hasDetails"
      v-show="isExpanded"
      :id="detailsId"
      class="gl-flex gl-flex-col gl-gap-3 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-sm gl-border-t-solid"
    >
      <p
        v-if="riskAssessment.stale"
        class="gl-m-0 gl-text-warning"
        data-testid="risk-stale-warning"
      >
        {{
          s__(
            'RiskAssessment|New commits were pushed after this assessment. It reflects an earlier version of the changes.',
          )
        }}
      </p>
      <p v-if="riskAssessment.rationale" class="gl-m-0" data-testid="risk-rationale">
        {{ riskAssessment.rationale }}
      </p>
      <div v-if="contributions.length">
        <h4 class="gl-m-0 gl-mb-2 gl-text-sm gl-font-bold">
          {{ s__('RiskAssessment|What contributed to this score') }}
        </h4>
        <p
          v-if="isLowConfidence && missingSignalsText"
          class="gl-mb-2 gl-mt-0 gl-text-subtle"
          data-testid="risk-low-confidence"
        >
          <gl-sprintf
            :message="
              s__('RiskAssessment|Based on a partial picture: %{missing} could not be measured.')
            "
          >
            <template #missing>{{ missingSignalsText }}</template>
          </gl-sprintf>
        </p>
        <ul class="gl-m-0 gl-list-none gl-p-0" data-testid="risk-signal-breakdown">
          <li
            v-for="entry in contributions"
            :key="entry.signal"
            class="gl-border-t-1 gl-border-t-default gl-py-2 gl-border-t-solid first:gl-border-t-0"
          >
            {{ entry.label || entry.signal }}
            <span v-if="entry.detail" class="gl-block gl-text-subtle">{{ entry.detail }}</span>
          </li>
        </ul>
      </div>
    </div>
  </section>
</template>
