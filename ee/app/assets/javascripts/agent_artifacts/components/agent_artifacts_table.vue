<script>
import {
  GlTable,
  GlLink,
  GlKeysetPagination,
  GlLoadingIcon,
  GlBadge,
  GlTruncate,
  GlAlert,
} from '@gitlab/ui';
import { last } from 'lodash-es';
import { formatDate } from '~/lib/utils/datetime_utility';
import { s__, __, formatNumber } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';
import getAgentArtifactsQuery from '../graphql/queries/get_agent_artifacts.query.graphql';

const DEFAULT_PAGE_SIZE = 10;

export default {
  name: 'AgentArtifactsTable',
  components: {
    GlTable,
    GlLink,
    GlKeysetPagination,
    GlLoadingIcon,
    GlBadge,
    GlTruncate,
    GlAlert,
  },
  props: {
    activeItem: {
      type: Object,
      required: false,
      default: null,
    },
    filter: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  emits: ['row-click'],
  apollo: {
    aiItems: {
      query: getAgentArtifactsQuery,
      variables() {
        return {
          last: this.before ? DEFAULT_PAGE_SIZE : null,
          first: this.before ? null : DEFAULT_PAGE_SIZE,
          after: this.after,
          before: this.before,
          ...this.filter,
        };
      },
      update(data) {
        this.hasError = false;
        return data.aiItems;
      },
      error() {
        this.hasError = true;
      },
    },
  },
  data() {
    return {
      aiItems: null,
      after: null,
      before: null,
      hasError: false,
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.aiItems.loading;
    },
    items() {
      return this.aiItems?.nodes || [];
    },
    pageInfo() {
      return this.aiItems?.pageInfo || {};
    },
    fields() {
      return [
        {
          key: 'aiItem',
          label: s__('AgentArtifacts|AI Item'),
          tdClass: '@max-sm/panel:gl-w-full @max-lg/panel:gl-wrap-anywhere @sm/panel:gl-max-w-30',
          thClass: '@sm/panel:gl-max-w-30',
        },
        {
          key: 'sessionId',
          label: s__('AgentArtifacts|Session ID'),
          tdClass: 'gl-whitespace-nowrap',
        },
        {
          key: 'auditEvents',
          label: s__('AgentArtifacts|Audit events'),
          tdClass: 'gl-whitespace-nowrap',
        },
        {
          key: 'credits',
          label: s__('AgentArtifacts|Credits'),
          tdClass: 'gl-whitespace-nowrap gl-hidden @lg/panel:!gl-table-cell',
          thClass: 'gl-hidden @lg/panel:!gl-table-cell',
        },
        {
          key: 'project',
          label: __('Project'),
          tdClass:
            '@max-lg/panel:gl-w-full @max-lg/panel:gl-wrap-anywhere @lg/panel:gl-max-w-30 gl-hidden @lg/panel:!gl-table-cell',
          thClass: 'gl-max-w-30 gl-hidden @lg/panel:!gl-table-cell',
        },
        {
          key: 'startTime',
          label: s__('AgentArtifacts|Start time'),
          tdClass: 'gl-whitespace-nowrap',
        },
      ];
    },
  },
  watch: {
    filter() {
      this.after = null;
      this.before = null;
    },
  },
  methods: {
    rowClass(item) {
      const classes = ['gl-cursor-pointer', 'hover:gl-bg-gray-50'];
      if (item === this.activeItem) {
        classes.push('!gl-bg-blue-50');
      }
      return classes;
    },
    handleNext(endCursor) {
      this.after = endCursor;
      this.before = null;
    },
    handlePrev(startCursor) {
      this.before = startCursor;
      this.after = null;
    },
    formatStartDate(dateString) {
      return formatDate(dateString, 'yyyy-mm-dd');
    },
    formatStartTime(dateString) {
      return formatDate(dateString, 'HH:MM:ss Z');
    },
    formatCredits(credits) {
      return formatNumber(credits);
    },
    getSessionId(sessionId) {
      return getIdFromGraphQLId(sessionId);
    },
    lastMessage(latestCheckpoint) {
      return last(latestCheckpoint?.duoMessages)?.content;
    },
    formatName(name) {
      return formatAgentDefinition(name);
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="hasError" variant="danger" :dismissible="false" class="gl-mb-5">
      {{ s__('AgentArtifacts|Failed to load agent artifacts.') }}
    </gl-alert>
    <gl-table
      :fields="fields"
      :items="items"
      :busy="isLoading"
      show-empty
      stacked="sm"
      :tbody-tr-class="rowClass"
      :tbody-tr-attr="{ 'data-testid': 'agent-artifacts-table-row' }"
      @row-clicked="$emit('row-click', $event)"
    >
      <template #table-busy>
        <gl-loading-icon size="lg" class="gl-my-5" />
      </template>

      <template #empty>
        <div class="gl-py-5 gl-text-center">
          {{ s__('AgentArtifacts|No agent artifacts found.') }}
        </div>
      </template>

      <template #cell(aiItem)="{ item }">
        <div>
          <gl-truncate
            :text="formatName(item.name)"
            class="gl-min-w-0 gl-max-w-full gl-font-bold"
            with-tooltip
            data-testid="ai-item-name"
          />
          <gl-truncate
            :text="lastMessage(item.latestCheckpoint)"
            class="gl-min-w-0 gl-max-w-full gl-text-subtle"
            with-tooltip
            data-testid="ai-item-last-message"
          />
        </div>
      </template>

      <template #cell(sessionId)="{ item }">
        <gl-link :href="item.session?.webPath" data-testid="session-link">
          #{{ getSessionId(item.session?.id) }}
        </gl-link>
      </template>

      <template #cell(auditEvents)="{ item }">
        <gl-badge variant="neutral" class="gl-px-4" data-testid="audit-events-count">
          {{ item.auditEvents?.count }}
        </gl-badge>
      </template>

      <template #cell(credits)="{ item }">
        <span data-testid="credits-used" class="gl-font-bold">{{
          formatCredits(item.creditsUsed)
        }}</span>
      </template>

      <template #cell(project)="{ item }">
        <gl-link :href="item.project?.webPath" data-testid="project-link">
          <gl-truncate
            :text="item.project?.name"
            class="gl-min-w-0 gl-max-w-full hover:gl-underline"
            with-tooltip
          />
        </gl-link>
      </template>

      <template #cell(startTime)="{ item }">
        <div class="gl-text-subtle" data-testid="start-time">
          <div>{{ formatStartDate(item.startTime) }}</div>
          <div>{{ formatStartTime(item.startTime) }}</div>
        </div>
      </template>
    </gl-table>

    <div
      v-if="pageInfo.hasNextPage || pageInfo.hasPreviousPage"
      class="gl-mt-5 gl-flex gl-justify-center"
    >
      <gl-keyset-pagination v-bind="pageInfo" @prev="handlePrev" @next="handleNext" />
    </div>
  </div>
</template>
