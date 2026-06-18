<script>
import { GlBreadcrumb, GlButton } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import SummarySection from './summary_section.vue';
import DetailsSection from './details_section.vue';

// Audit events for the Duo Agent Platform always target the workflow session.
// The backend does not expose entity/target as stored columns, so the target
// facts are reconstructed client-side from the workflow definition and id.
const TARGET_TYPE = 'Ai::DuoWorkflows::Workflow';

export default {
  name: 'AuditEventDetailsPanel',
  components: {
    GlBreadcrumb,
    GlButton,
    SummarySection,
    DetailsSection,
  },
  props: {
    event: {
      type: Object,
      required: true,
    },
    sessionName: {
      type: String,
      required: false,
      default: '',
    },
    workflowDefinition: {
      type: String,
      required: false,
      default: '',
    },
    isFullPage: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['close', 'back'],
  computed: {
    breadcrumbItems() {
      return [
        { text: this.$options.i18n.agentAuditEvents },
        { text: this.sessionName },
        { text: this.event.eventName },
      ].filter((item) => item.text);
    },
    targetType() {
      return TARGET_TYPE;
    },
    targetDetails() {
      const { workflowId } = this.event;

      if (!this.workflowDefinition || !workflowId) {
        return '';
      }

      return sprintf(this.$options.i18n.targetDetailsFormat, {
        workflowDefinition: this.workflowDefinition,
        workflowId,
      });
    },
    detailsData() {
      return this.event.details || {};
    },
  },
  i18n: {
    agentAuditEvents: s__('AgentArtifacts|Agent audit events'),
    auditEvents: s__('AgentArtifacts|Audit events'),
    targetDetailsFormat: s__('AgentArtifacts|%{workflowDefinition} session %{workflowId}'),
    close: s__('AgentArtifacts|Close'),
  },
};
</script>

<template>
  <div data-testid="audit-event-details-panel">
    <div v-if="isFullPage" class="gl-flex gl-justify-end">
      <gl-button
        category="tertiary"
        icon="close"
        size="small"
        :aria-label="$options.i18n.close"
        data-testid="audit-event-close-button"
        @click="$emit('close')"
      />
    </div>

    <gl-breadcrumb :items="breadcrumbItems" />

    <div v-if="!isFullPage" class="gl-mt-3 gl-flex gl-items-center gl-justify-between gl-gap-3">
      <gl-button
        variant="link"
        icon="arrow-left"
        data-testid="audit-event-back-button"
        @click="$emit('back')"
      >
        {{ $options.i18n.auditEvents }}
      </gl-button>
      <slot name="download-action"></slot>
    </div>

    <h4 class="gl-mt-4" data-testid="audit-event-title">{{ event.eventName }}</h4>

    <summary-section
      :event="event"
      :target-type="targetType"
      :target-details="targetDetails"
      class="gl-mt-6"
    />

    <details-section :details="detailsData" class="gl-mt-6" />
  </div>
</template>
