<script>
import { GlAttributeList, GlBadge, GlLink, GlSkeletonLoader, GlTooltipDirective } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { localeDateFormat } from '~/lib/utils/datetime/locale_dateformat';
import { projectAutomateAgentSessionPath } from 'ee/lib/utils/path_helpers/project';
import { formatFlowLabel, parseExecutorLogUrls } from 'ee/ai/duo_agents_platform/utils';
import AgentFlowDetailsPanel from './agent_flow_details_panel.vue';

export default {
  name: 'AgentFlowInfo',
  components: {
    GlAttributeList,
    GlBadge,
    GlLink,
    GlSkeletonLoader,
    AgentFlowDetailsPanel,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    isLoading: {
      required: true,
      type: Boolean,
    },
    agentFlowDefinition: {
      required: true,
      type: String,
    },
    aiCatalogItemPath: {
      type: String,
      required: false,
      default: '',
    },
    flowVersion: {
      type: String,
      required: false,
      default: '',
    },
    modelName: {
      type: String,
      required: false,
      default: '',
    },
    modelIdentifier: {
      type: String,
      required: false,
      default: '',
    },
    allExecutorUrls: {
      required: false,
      type: Array,
      default: () => [],
    },
    createdAt: {
      type: String,
      required: false,
      default: '',
    },
    updatedAt: {
      type: String,
      required: false,
      default: '',
    },
    project: {
      type: Object,
      required: true,
    },
    workItem: {
      type: Object,
      required: false,
      default: null,
    },
    mergeRequest: {
      type: Object,
      required: false,
      default: null,
    },
    user: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    projectAgentSessionsUrl() {
      const sessionId = this.$route.params.id;
      const projectFullPath = this.project?.fullPath;

      return sessionId && projectFullPath
        ? projectAutomateAgentSessionPath(projectFullPath, sessionId)
        : '';
    },
    sessionDetailsRightRail() {
      return Boolean(window.gon?.features?.sessionDetailsRightRail);
    },
    jobItems() {
      return parseExecutorLogUrls(this.allExecutorUrls);
    },
    flowText() {
      return formatFlowLabel(this.agentFlowDefinition, this.flowVersion);
    },
    payload() {
      return [
        {
          label: s__('AI|AI Item'),
          text: this.flowText,
          link: this.aiCatalogItemPath || null,
        },
        {
          label: s__('DuoAgentPlatform|Session ID'),
          text: `${this.$route.params.id}`,
          link: this.projectAgentSessionsUrl,
        },
        {
          label: __('Type'),
          text: s__('DuoAgentPlatform|Flow'),
        },
        {
          label: __('Project'),
          text: this.project?.name || __('None'),
          link: this.project?.webUrl,
        },
        {
          label: __('Group'),
          text: this.project?.namespace?.name || __('None'),
          link: this.project?.namespace?.webUrl,
        },
        {
          label: __('Work item'),
          text: this.workItem ? `#${this.workItem.iid}` : __('None'),
          link: this.workItem?.webUrl ?? null,
        },
        {
          label: __('Merge request'),
          text: this.mergeRequest ? `!${this.mergeRequest.iid}` : __('None'),
          link: this.mergeRequest?.webUrl ?? null,
        },
        {
          label: __('Started'),
          text: this.formatTimestamp(this.createdAt) ?? '',
          hideIfEmpty: true,
        },
        {
          label: __('Last updated'),
          text: this.formatTimestamp(this.updatedAt) ?? '',
          hideIfEmpty: true,
        },
        {
          label: s__('DuoAgentPlatform|Job IDs'),
          text: this.jobItems.length
            ? this.jobItems.map((item) => `${item.iid}`).join(', ')
            : __('None'),
          type: 'jobItems',
          jobItems: this.jobItems,
        },
        ...(this.modelName
          ? [
              {
                label: s__('DuoAgentPlatform|Default model'),
                type: 'model',
                text: this.modelName,
                tooltip: this.modelIdentifier,
              },
            ]
          : []),
      ].filter((entry) => !entry.hideIfEmpty || entry.text);
    },
  },
  methods: {
    formatTimestamp(isoString) {
      if (!isoString) {
        return null;
      }

      try {
        const date = new Date(isoString);
        if (Number.isNaN(date.getTime())) {
          return null;
        }
        return localeDateFormat.asDateTime.format(date);
      } catch (error) {
        return null;
      }
    },
  },
};
</script>
<template>
  <div>
    <div class="gl-overflow-hidden">
      <div class="gl-@container">
        <agent-flow-details-panel
          v-if="sessionDetailsRightRail"
          :session-id="`${$route.params.id}`"
          :session-url="projectAgentSessionsUrl"
          :flow-name="flowText"
          :flow-path="aiCatalogItemPath"
          :project="project"
          :user="user"
          :created-at="formatTimestamp(createdAt)"
          :updated-at="formatTimestamp(updatedAt)"
          :model-name="modelName"
          :model-identifier="modelIdentifier"
          :job-items="jobItems"
        />
        <gl-attribute-list v-else :items="payload">
          <template #label="{ item }">
            <span data-testid="info-title">
              {{ sprintf(__('%{label}'), { label: item.label }) }}
            </span>
          </template>
          <template #description="{ item }">
            <div :data-testid="`info-row-${item.label}`">
              <gl-skeleton-loader v-if="isLoading" :lines="1" />
              <template v-else>
                <span v-if="item.type === 'jobItems'" class="gl-min-w-0" data-testid="info-value">
                  <template v-if="item.jobItems.length">
                    <span v-for="(jobItem, index) in item.jobItems" :key="jobItem.iid">
                      <template v-if="index > 0">{{ __(', ') }}</template>
                      <gl-link :href="jobItem.webPath">{{ jobItem.iid }}</gl-link>
                    </span>
                  </template>
                  <template v-else>{{ __('None') }}</template>
                </span>
                <span v-else-if="item.type === 'model'" data-testid="info-value">
                  <gl-badge
                    v-gl-tooltip="item.tooltip"
                    class="gl-font-monospace"
                    data-testid="model-badge"
                  >
                    {{ item.text }}
                  </gl-badge>
                </span>
                <span v-else data-testid="info-value">
                  <gl-link v-if="item.link" :href="item.link">{{ item.text }}</gl-link>
                  <template v-else>{{ item.text }}</template>
                </span>
              </template>
            </div>
          </template>
        </gl-attribute-list>
      </div>
    </div>
  </div>
</template>
