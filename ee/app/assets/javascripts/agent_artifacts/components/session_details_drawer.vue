<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import { __ } from '~/locale';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';
import SessionDetailsBody from './session_details_body.vue';
import AuditEventDetailsPanel from './audit_event_details_panel.vue';

export default {
  name: 'SessionDetailsDrawer',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    MountingPortal,
    SessionDetailsBody,
    AuditEventDetailsPanel,
  },
  props: {
    activeItem: {
      type: Object,
      required: true,
    },
    selectedEvent: {
      type: Object,
      required: false,
      default: null,
    },
    sessionName: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['close', 'select', 'back', 'maximize'],
  computed: {
    formattedName() {
      return formatAgentDefinition(this.activeItem?.workflowDefinition);
    },
    sessionId() {
      return this.activeItem?.id;
    },
  },
  mounted() {
    document.addEventListener('keydown', this.closeOnEscape);
  },
  beforeDestroy() {
    document.removeEventListener('keydown', this.closeOnEscape);
  },
  methods: {
    handleClose() {
      this.$emit('close');
    },
    closeOnEscape({ key }) {
      if (key === 'Escape') {
        this.handleClose();
      }
    },
  },
  i18n: {
    closePanelText: __('Close panel'),
    maximizeText: __('Maximize'),
  },
};
</script>

<template>
  <mounting-portal mount-to="#contextual-panel-portal" append>
    <div data-testid="session-details-drawer" class="work-item-detail-panel gl-leading-reset">
      <div
        class="gl-border-b gl-flex gl-min-h-8 gl-items-center gl-gap-3 gl-border-section gl-px-4 @xl/panel:gl-px-6"
      >
        <h2
          v-if="!selectedEvent"
          class="gl-m-0 gl-grow gl-truncate gl-text-sm gl-text-default"
          data-testid="drawer-title"
        >
          {{ formattedName }}
        </h2>
        <div class="panel-header-controls gl-ml-auto">
          <gl-button
            v-if="selectedEvent"
            v-gl-tooltip.bottom
            category="tertiary"
            icon="maximize"
            size="small"
            :aria-label="$options.i18n.maximizeText"
            :title="$options.i18n.maximizeText"
            data-testid="audit-event-maximize-button"
            @click="$emit('maximize')"
          />
          <gl-button
            v-gl-tooltip.bottom
            category="tertiary"
            icon="close"
            size="small"
            :aria-label="$options.i18n.closePanelText"
            :title="$options.i18n.closePanelText"
            data-testid="session-details-drawer-close-button"
            @click="handleClose"
          />
        </div>
      </div>
      <div class="js-dynamic-panel-inner work-item-detail-panel-content gl-px-4 @xl/panel:gl-px-6">
        <audit-event-details-panel
          v-if="selectedEvent"
          :event="selectedEvent"
          :session-name="sessionName"
          :workflow-definition="activeItem.workflowDefinition"
          :is-full-page="false"
          @back="$emit('back')"
        />
        <session-details-body
          v-else
          :active-item="activeItem"
          :session-id="sessionId"
          @select="$emit('select', $event)"
        />
      </div>
    </div>
  </mounting-portal>
</template>
