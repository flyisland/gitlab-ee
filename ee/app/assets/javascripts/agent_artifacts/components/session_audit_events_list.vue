<script>
import { GlAlert, GlAvatar, GlAvatarLink, GlKeysetPagination, GlLoadingIcon } from '@gitlab/ui';
import TimelineEntryItem from '~/vue_shared/components/notes/timeline_entry_item.vue';
import { formatDate } from '~/lib/utils/datetime_utility';
import getSessionAuditEventsQuery from '../graphql/queries/get_session_audit_events.query.graphql';

const DEFAULT_PAGE_SIZE = 20;

export default {
  name: 'SessionAuditEventsList',
  components: {
    GlAlert,
    GlAvatar,
    GlAvatarLink,
    GlKeysetPagination,
    GlLoadingIcon,
    TimelineEntryItem,
  },
  props: {
    sessionId: {
      type: String,
      required: true,
    },
  },
  apollo: {
    auditEvents: {
      query: getSessionAuditEventsQuery,
      variables() {
        return {
          sessionId: this.sessionId,
          after: this.after,
          before: this.before,
          first: this.before ? null : DEFAULT_PAGE_SIZE,
          last: this.before ? DEFAULT_PAGE_SIZE : null,
        };
      },
      update(data) {
        this.hasError = false;
        return data.aiDuoWorkflow?.auditEvents;
      },
      error() {
        this.hasError = true;
      },
    },
  },
  data() {
    return {
      auditEvents: null,
      after: null,
      before: null,
      hasError: false,
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.auditEvents.loading;
    },
    events() {
      return this.auditEvents?.nodes || [];
    },
    pageInfo() {
      return this.auditEvents?.pageInfo || {};
    },
    hasEvents() {
      return this.events.length > 0;
    },
  },
  methods: {
    handleNext(endCursor) {
      this.after = endCursor;
      this.before = null;
    },
    handlePrev(startCursor) {
      this.before = startCursor;
      this.after = null;
    },
    formatEventDate(dateString) {
      return formatDate(dateString, 'yyyy-mm-dd HH:MM:ss Z');
    },
  },
};
</script>

<template>
  <div data-testid="session-audit-events-list">
    <h5 class="gl-heading-5">{{ s__('AgentArtifacts|Audit events') }}</h5>

    <gl-alert v-if="hasError" variant="danger" :dismissible="false" class="gl-mb-5">
      {{ s__('AgentArtifacts|Failed to load audit events.') }}
    </gl-alert>

    <gl-loading-icon v-else-if="isLoading" size="md" class="gl-my-4" />

    <template v-else>
      <div v-if="hasEvents" class="issuable-discussion" data-testid="audit-events-timeline">
        <ul class="notes main-notes-list timeline">
          <timeline-entry-item
            v-for="event in events"
            :key="event.id"
            class="note note-wrapper note-comment"
          >
            <div
              class="system-note-dot gl-relative -gl-top-1 gl-float-left gl-ml-4 gl-mt-3 gl-h-3 gl-w-3 gl-rounded-full gl-border-2 gl-border-solid gl-border-subtle"
            ></div>
            <div class="gl-ml-8 gl-rounded-lg gl-bg-gray-10 gl-px-3 gl-py-2">
              <span class="gl-mb-2 gl-block gl-text-sm gl-text-subtle" data-testid="event-date">{{
                formatEventDate(event.createdAt)
              }}</span>
              <span class="gl-block gl-text-400 gl-font-bold" data-testid="event-type">{{
                event.eventType
              }}</span>
              <div class="gl-mt-2 gl-flex gl-flex-wrap gl-items-center gl-gap-2">
                <gl-avatar-link v-if="event.author" :href="event.author.webPath">
                  <gl-avatar
                    :src="event.author.avatarUrl"
                    :entity-name="event.author.name"
                    :size="16"
                  />
                </gl-avatar-link>
                <a
                  v-if="event.author"
                  :href="event.author.webPath"
                  class="gl-text-sm gl-text-subtle"
                  data-testid="event-author"
                  >{{ event.author.name }}</a
                >
              </div>
            </div>
          </timeline-entry-item>
        </ul>
      </div>

      <div v-else class="gl-py-4 gl-text-center gl-text-subtle" data-testid="empty-state">
        {{ s__('AgentArtifacts|No audit events found.') }}
      </div>

      <div
        v-if="pageInfo.hasNextPage || pageInfo.hasPreviousPage"
        class="gl-mt-4 gl-flex gl-justify-center"
      >
        <gl-keyset-pagination v-bind="pageInfo" @prev="handlePrev" @next="handleNext" />
      </div>
    </template>
  </div>
</template>
