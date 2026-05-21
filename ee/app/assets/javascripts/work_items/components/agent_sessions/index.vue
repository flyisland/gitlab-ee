<script>
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import AgentSessionsList from 'ee/ai/shared/widgets/agent_sessions_list.vue';
import getDuoAgentSessionsOnWorkItemQuery from 'ee/ai/shared/widgets/graphql/get_duo_agent_sessions_on_work_item.query.graphql';
import { eventHub, SHOW_SESSION } from 'ee/ai/events/panel';

export default {
  name: 'WorkItemAgentSessions',

  components: {
    AgentSessionsList,
  },
  props: {
    workItemId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      allSessions: [],
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.allSessions.loading;
    },
  },
  apollo: {
    allSessions: {
      query: getDuoAgentSessionsOnWorkItemQuery,
      variables() {
        return {
          id: this.workItemId,
        };
      },
      skip() {
        return !this.workItemId;
      },
      update(data) {
        return data?.workItem?.features?.aiSession?.duoWorkflows?.nodes ?? [];
      },
      error(err) {
        createAlert({
          message:
            err?.message ||
            s__('DuoAgentPlatform|Failed to load agent sessions for this work item.'),
          captureError: true,
          error: err,
        });
      },
    },
  },
  created() {
    eventHub.$on(SHOW_SESSION, this.refetchSessions);
  },
  beforeDestroy() {
    eventHub.$off(SHOW_SESSION, this.refetchSessions);
  },
  methods: {
    refetchSessions() {
      this.$apollo.queries.allSessions.refetch();
    },
  },
};
</script>

<template>
  <agent-sessions-list
    :sessions="allSessions"
    :is-loading="isLoading"
    :class="{ 'gl-mt-5': !isLoading && allSessions.length > 0 }"
  />
</template>
