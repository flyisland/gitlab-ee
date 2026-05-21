<script>
import { GlButton, GlAnimatedChevronLgDownUpIcon } from '@gitlab/ui';
import { n__ } from '~/locale';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import AgentSessionRow from './agent_session_row.vue';
import { SESSION_STATUSES_ACTIVE } from './agent_session_constants';

export default {
  name: 'AgentSessionsList',
  components: {
    CrudComponent,
    GlButton,
    GlAnimatedChevronLgDownUpIcon,
    AgentSessionRow,
  },
  props: {
    sessions: {
      type: Array,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      areCollapsedSessionsVisible: false,
      userHasToggled: false,
    };
  },
  computed: {
    activeSessions() {
      return this.sessions.filter((s) => SESSION_STATUSES_ACTIVE.includes(s.status));
    },
    collapsedSessions() {
      return this.sessions.filter((s) => !SESSION_STATUSES_ACTIVE.includes(s.status));
    },
    hasActiveSessions() {
      return this.activeSessions.length > 0;
    },
    hasSessions() {
      return this.sessions.length > 0;
    },
    hasCollapsedSessions() {
      return this.collapsedSessions.length > 0;
    },
    sessionCount() {
      return this.sessions.length || null;
    },
    collapsedSessionsToggleLabel() {
      if (this.areCollapsedSessionsVisible) {
        return n__(
          'DuoAgentPlatform|Hide %d inactive session',
          'DuoAgentPlatform|Hide %d inactive sessions',
          this.collapsedSessions.length,
        );
      }
      return n__(
        'DuoAgentPlatform|Show %d inactive session',
        'DuoAgentPlatform|Show %d inactive sessions',
        this.collapsedSessions.length,
      );
    },
  },
  watch: {
    hasActiveSessions: {
      immediate: true,
      handler(value) {
        if (!this.userHasToggled) {
          this.areCollapsedSessionsVisible = !value;
        }
      },
    },
  },
  methods: {
    toggleCollapsedSessions() {
      this.userHasToggled = true;
      this.areCollapsedSessionsVisible = !this.areCollapsedSessionsVisible;
    },
  },
};
</script>

<template>
  <crud-component
    v-if="hasSessions"
    :title="s__('DuoAgentPlatform|Sessions')"
    icon="session-ai"
    :count="sessionCount"
    :is-loading="isLoading"
    :is-collapsible="true"
    :collapsed="!hasActiveSessions"
    data-testid="agent-sessions-widget"
  >
    <div data-testid="agent-sessions-list">
      <template v-if="hasActiveSessions">
        <agent-session-row v-for="session in activeSessions" :key="session.id" :session="session" />
      </template>

      <div
        v-if="hasCollapsedSessions"
        :class="{ 'gl-border-t gl-border-t-section': hasActiveSessions }"
        data-testid="collapsed-sessions-section"
      >
        <gl-button
          category="tertiary"
          size="small"
          class="gl-my-5"
          :aria-expanded="`${areCollapsedSessionsVisible}`"
          data-testid="toggle-collapsed-sessions"
          @click="toggleCollapsedSessions"
        >
          <span class="gl-flex gl-items-center gl-gap-2">
            <gl-animated-chevron-lg-down-up-icon :is-on="areCollapsedSessionsVisible" />
            {{ collapsedSessionsToggleLabel }}
          </span>
        </gl-button>

        <template v-if="areCollapsedSessionsVisible">
          <agent-session-row
            v-for="session in collapsedSessions"
            :key="session.id"
            :session="session"
          />
        </template>
      </div>
    </div>
  </crud-component>
</template>
