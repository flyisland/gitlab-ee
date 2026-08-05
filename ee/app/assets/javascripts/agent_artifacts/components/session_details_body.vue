<script>
import { GlButton, GlIcon, GlLink, GlTruncate } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { formatDate } from '~/lib/utils/datetime_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import { LONG_DATE_FORMAT_WITH_TZ } from '~/vue_shared/constants';
import SessionAuditEventsList from './session_audit_events_list.vue';

export default {
  name: 'SessionDetailsBody',
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlTruncate,
    CrudComponent,
    SessionAuditEventsList,
  },
  props: {
    activeItem: {
      type: Object,
      required: true,
    },
    sessionId: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['select'],
  computed: {
    formattedName() {
      return formatAgentDefinition(this.activeItem?.workflowDefinition);
    },
    formattedDate() {
      return formatDate(this.activeItem?.workflowCreatedAt, LONG_DATE_FORMAT_WITH_TZ);
    },
    sessionDetailsUrl() {
      return this.activeItem?.webPath;
    },
    formattedSessionId() {
      return getIdFromGraphQLId(this.sessionId);
    },
    downloadPath() {
      return this.activeItem?.downloadPath;
    },
  },
  i18n: {
    sessionDetailsTitle: s__('AgentArtifacts|Session details'),
    viewFullSessionDetails: s__('AgentArtifacts|View full session details'),
    downloadAuditArtifact: s__('AgentArtifacts|Download Session Artifacts'),
    sessionLabel: s__('AgentArtifacts|Session'),
    dateLabel: __('Date'),
    projectLabel: __('Project'),
  },
};
</script>

<template>
  <div>
    <div class="gl-mt-6 gl-flex gl-items-center gl-justify-between gl-gap-3">
      <h4 class="gl-m-0" data-testid="session-content-title">
        {{ formattedName }}
      </h4>
      <gl-button
        v-if="downloadPath"
        icon="download"
        :href="downloadPath"
        data-testid="download-audit-artifact-button"
      >
        {{ $options.i18n.downloadAuditArtifact }}
      </gl-button>
    </div>

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

    <session-audit-events-list
      v-if="sessionId"
      :session-id="sessionId"
      class="gl-mt-6"
      @select="$emit('select', $event)"
    />
  </div>
</template>
