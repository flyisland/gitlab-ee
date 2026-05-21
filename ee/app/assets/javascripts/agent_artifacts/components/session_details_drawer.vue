<script>
import { GlButton, GlIcon, GlLink, GlTooltipDirective, GlTruncate } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import { __, s__ } from '~/locale';
import { formatDate } from '~/lib/utils/datetime_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import { LONG_DATE_FORMAT_WITH_TZ } from '~/vue_shared/constants';
import SessionAuditEventsList from './session_audit_events_list.vue';

export default {
  name: 'SessionDetailsDrawer',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlTruncate,
    MountingPortal,
    CrudComponent,
    SessionAuditEventsList,
  },
  props: {
    activeItem: {
      type: Object,
      required: true,
    },
  },
  emits: ['close'],
  computed: {
    formattedName() {
      return formatAgentDefinition(this.activeItem?.name);
    },
    formattedDate() {
      return formatDate(this.activeItem?.startTime, LONG_DATE_FORMAT_WITH_TZ);
    },
    sessionDetailsUrl() {
      return this.activeItem?.session?.webPath;
    },
    formattedSessionId() {
      return getIdFromGraphQLId(this.activeItem?.session?.id);
    },
    sessionId() {
      return this.activeItem?.session?.id;
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
    sessionDetailsTitle: s__('AgentArtifacts|Session details'),
    viewFullSessionDetails: s__('AgentArtifacts|View full session details'),
    sessionLabel: s__('AgentArtifacts|Session'),
    dateLabel: __('Date'),
    modelUsedLabel: s__('AgentArtifacts|Model used'),
    creditsUsedLabel: s__('AgentArtifacts|Credits used in this session'),
    projectLabel: __('Project'),
  },
};
</script>

<template>
  <mounting-portal mount-to="#contextual-panel-portal" append>
    <div
      data-testid="session-details-drawer"
      class="work-item-detail-panel gl-pt-4 gl-leading-reset"
    >
      <div class="work-item-detail-panel-header">
        <h2 class="gl-m-0 gl-grow gl-text-sm gl-text-default" data-testid="drawer-title">
          {{ formattedName }}
        </h2>
        <gl-button
          v-gl-tooltip.bottom
          class="gl-drawer-close-button"
          category="tertiary"
          icon="close"
          size="small"
          :aria-label="$options.i18n.closePanelText"
          :title="$options.i18n.closePanelText"
          data-testid="session-details-drawer-close-button"
          @click="handleClose"
        />
      </div>
      <div class="js-dynamic-panel-inner work-item-detail-panel-content gl-px-4 @xl/panel:gl-px-6">
        <h4 class="gl-mt-6" data-testid="drawer-content-title">
          {{ formattedName }}
        </h4>

        <crud-component :title="$options.i18n.sessionDetailsTitle" class="gl-mt-6" is-collapsible>
          <template #actions>
            <gl-button
              :href="sessionDetailsUrl"
              size="small"
              data-testid="view-full-session-details-button"
            >
              {{ $options.i18n.viewFullSessionDetails }}
            </gl-button>
          </template>

          <div class="gl-flex gl-flex-col">
            <div
              class="gl-border-b gl-flex gl-justify-between gl-border-section gl-py-4 dark:gl-border-default"
              data-testid="session-row"
            >
              <span class="gl-flex gl-items-center gl-gap-3">
                <gl-icon name="session-ai" />
                <span class="gl-font-bold">{{ $options.i18n.sessionLabel }}</span>
              </span>
              <gl-link :href="sessionDetailsUrl" data-testid="session-link">
                #{{ formattedSessionId }}
              </gl-link>
            </div>

            <div
              class="gl-border-b gl-flex gl-justify-between gl-border-section gl-py-4 dark:gl-border-default"
              data-testid="date-row"
            >
              <span class="gl-flex gl-items-center gl-gap-3">
                <gl-icon name="clock" />
                <span class="gl-font-bold">{{ $options.i18n.dateLabel }}</span>
              </span>
              <span data-testid="formatted-date">{{ formattedDate }}</span>
            </div>

            <div
              class="gl-border-b gl-flex gl-justify-between gl-border-section gl-py-4 dark:gl-border-default"
              data-testid="model-row"
            >
              <span class="gl-flex gl-items-center gl-gap-3">
                <gl-icon name="agent-ai" />
                <span class="gl-font-bold">{{ $options.i18n.modelUsedLabel }}</span>
              </span>
              <span v-if="activeItem.session?.model" data-testid="model-name">{{
                activeItem.session?.model
              }}</span>
            </div>

            <div
              class="gl-border-b gl-flex gl-justify-between gl-border-section gl-py-4 dark:gl-border-default"
              data-testid="credits-row"
            >
              <span class="gl-flex gl-items-center gl-gap-3">
                <gl-icon name="gitlab-credits" />
                <span class="gl-font-bold">{{ $options.i18n.creditsUsedLabel }}</span>
              </span>
              <span data-testid="credits-used">{{ activeItem.creditsUsed }}</span>
            </div>

            <div class="gl-flex gl-justify-between gl-gap-3 gl-py-4" data-testid="project-row">
              <span class="gl-flex gl-shrink-0 gl-items-center gl-gap-3">
                <gl-icon name="project" />
                <span class="gl-font-bold">{{ $options.i18n.projectLabel }}</span>
              </span>
              <gl-link
                v-if="activeItem.project"
                :href="activeItem.project?.webPath"
                data-testid="project-link"
                class="gl-block gl-min-w-0 gl-truncate"
              >
                <gl-truncate :text="activeItem.project?.name" with-tooltip />
              </gl-link>
            </div>
          </div>
        </crud-component>

        <session-audit-events-list v-if="sessionId" :session-id="sessionId" class="gl-mt-6" />
      </div>
    </div>
  </mounting-portal>
</template>
