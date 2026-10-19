<script>
import { GlSprintf } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { EXTENSION_ICONS } from '~/vue_merge_request_widget/constants';
import MrWidget from '~/vue_merge_request_widget/components/widget/widget.vue';
import ViewSessionButton from 'ee/ai/shared/widgets/view_session_button.vue';
import SeverityMeter from 'ee/vue_shared/components/severity_meter/severity_meter.vue';
import RiskConfidenceNotice from './components/risk_confidence_notice.vue';
import RiskRationale from './components/risk_rationale.vue';
import RiskSignalBreakdown from './components/risk_signal_breakdown.vue';
import RiskStaleWarning from './components/risk_stale_warning.vue';
import {
  CONFIDENCE_LOW,
  DEFAULT_RISK_ASSESSMENT,
  IN_PROGRESS_STATUSES,
  STATUS_COMPLETE,
  STATUS_FAILED,
  STATUS_ICONS,
  STATUS_PENDING,
  TIER_LABELS,
  riskHeadline,
} from './constants';

export default {
  name: 'WidgetRiskAssessment',
  components: {
    GlSprintf,
    MrWidget,
    RiskConfidenceNotice,
    RiskRationale,
    RiskSignalBreakdown,
    RiskStaleWarning,
    SeverityMeter,
    ViewSessionButton,
  },
  props: {
    riskAssessment: {
      type: Object,
      required: false,
      default: null,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    hasError: {
      type: Boolean,
      required: false,
      default: false,
    },
    canRefresh: {
      type: Boolean,
      required: false,
      default: false,
    },
    isSubmitting: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['refresh'],
  computed: {
    safeRiskAssessment() {
      return { ...DEFAULT_RISK_ASSESSMENT, ...this.riskAssessment };
    },
    status() {
      return this.safeRiskAssessment.status;
    },
    // A refresh leaves the previous score in place for the scoring job to replace,
    // so a queued record still carries a result worth showing. A failed run is a
    // hard stop instead: there is no result left to trust.
    isAssessed() {
      return [STATUS_COMPLETE, ...IN_PROGRESS_STATUSES].includes(this.status) && Boolean(this.tier);
    },
    isRefreshing() {
      return this.isAssessed && IN_PROGRESS_STATUSES.includes(this.status);
    },
    showsStaleWarning() {
      return (
        this.isStale && !this.isRefreshing && (this.isAssessed || this.status === STATUS_FAILED)
      );
    },
    hasDetails() {
      return (
        this.isAssessed &&
        !this.isRefreshing &&
        Boolean(
          this.rationale ||
          this.contributions.length ||
          (this.isLowConfidence && this.missingSignalLabels.length),
        )
      );
    },
    // Not rendered (the meter overrides the status-icon slot); passed to mr-widget
    // only so its expand telemetry reports the risk lifecycle rather than neutral.
    statusIconName() {
      return STATUS_ICONS[this.status] ?? EXTENSION_ICONS.neutral;
    },
    tier() {
      return this.safeRiskAssessment.riskTier;
    },
    tierLabel() {
      return TIER_LABELS[this.tier] ?? this.tier;
    },
    // Risk-domain wording for the meter's accessible name, e.g. "Risk level: High risk".
    meterLabel() {
      if (this.isLoading) {
        return s__('RiskAssessment|Assessing risk');
      }

      return this.tier
        ? sprintf(s__('RiskAssessment|Risk level: %{level}'), { level: this.tierLabel })
        : s__('RiskAssessment|Risk level not available');
    },
    confidenceTier() {
      return this.safeRiskAssessment.confidenceTier;
    },
    isLowConfidence() {
      return this.confidenceTier === CONFIDENCE_LOW;
    },
    summaryTitle() {
      if (this.isAssessed) {
        return riskHeadline(this.tier, this.confidenceTier);
      }

      if (this.isLoading) {
        return s__('RiskAssessment|%{boldStart}Risk assessment:%{boldEnd} Evaluating…');
      }

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
    contributions() {
      return this.safeRiskAssessment.contributingSignals;
    },
    // A key matching neither a registered signal nor a claim domain comes back with
    // a null label. Naming it as a raw key reads worse than leaving it out.
    missingSignalLabels() {
      return this.safeRiskAssessment.missingSignals.map((entry) => entry.label).filter(Boolean);
    },
    isStale() {
      return this.safeRiskAssessment.stale;
    },
    rationale() {
      return this.safeRiskAssessment.rationale;
    },
    duoWorkflowId() {
      return this.safeRiskAssessment.duoWorkflowId;
    },
  },
};
</script>

<template>
  <div class="mr-section-container">
    <mr-widget
      :error-text="s__('RiskAssessment|Failed to load the risk assessment')"
      :status-icon-name="statusIconName"
      :has-error="hasError"
      :is-collapsible="hasDetails || showsStaleWarning"
      widget-name="WidgetRiskAssessment"
      data-testid="mr-risk-assessment-widget"
      class="mr-widget-section"
    >
      <template #status-icon>
        <severity-meter
          :severity="isAssessed ? tier : null"
          :label="meterLabel"
          :loading="isLoading"
          class="gl-mr-3 gl-self-center"
        />
      </template>

      <template #summary>
        <div class="gl-flex gl-h-full gl-flex-wrap gl-items-center gl-gap-3">
          <span data-testid="risk-summary">
            <gl-sprintf :message="summaryTitle">
              <template #bold="{ content }">
                <strong>{{ content }}</strong>
              </template>
            </gl-sprintf>
          </span>

          <span v-if="isRefreshing" class="gl-text-subtle" data-testid="risk-updating">
            {{ s__('RiskAssessment|Updating…') }}
          </span>
        </div>
      </template>

      <template #action-buttons>
        <view-session-button
          v-if="duoWorkflowId && !isRefreshing"
          class="gl-ml-3"
          size="small"
          :session-id="duoWorkflowId"
          data-testid="risk-duo-session-link"
        />
      </template>

      <template #content>
        <div v-if="hasDetails || showsStaleWarning" class="gl-px-4 gl-py-3">
          <template v-if="hasDetails">
            <risk-rationale v-if="rationale" :rationale="rationale" />
            <risk-signal-breakdown v-if="contributions.length" :contributions="contributions" />
            <risk-confidence-notice v-if="isLowConfidence" :missing-labels="missingSignalLabels" />
          </template>

          <risk-stale-warning
            v-if="showsStaleWarning"
            :can-refresh="canRefresh"
            :is-submitting="isSubmitting"
            @refresh="$emit('refresh')"
          />
        </div>
      </template>
    </mr-widget>
  </div>
</template>
