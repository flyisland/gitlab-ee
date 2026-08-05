<script>
import { GlCollapse, GlButton } from '@gitlab/ui';
import { MessageToolKvSection } from '@gitlab/duo-ui';
import { s__ } from '~/locale';
import { truncate } from '~/lib/utils/text_utility';
import { captureException } from '~/sentry/sentry_browser_wrapper';
import { getMessageData, getComponentLabel } from 'ee/ai/duo_agents_platform/utils';
import NonGfmMarkdown from '~/vue_shared/components/markdown/non_gfm_markdown.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { getToolContentRenderer } from './tool_content_renderers';
import AgentFlowUserApproval from './agent_flow_user_approval.vue';
import ComponentLabel from './component_label.vue';
import SubagentBadge from './subagent_badge.vue';

const INLINE_CONTENT_MAX_LENGTH = 140;

export default {
  name: 'LogEntry',
  components: {
    GlCollapse,
    GlButton,
    MessageToolKvSection,
    NonGfmMarkdown,
    TimeAgoTooltip,
    AgentFlowUserApproval,
    ComponentLabel,
    SubagentBadge,
  },
  props: {
    item: {
      type: Object,
      required: true,
      validator(item) {
        return (
          typeof item === 'object' &&
          typeof item.content === 'string' &&
          item.messageType &&
          item.status &&
          item.timestamp
        );
      },
    },
    index: {
      type: Number,
      required: true,
    },
    last: {
      type: Boolean,
      required: true,
    },
    canResumeWorkflow: {
      type: Boolean,
      required: true,
    },
    canUpdateWorkflow: {
      type: Boolean,
      required: true,
    },
    componentColorIndexMap: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      visible: false,
    };
  },
  computed: {
    toolInfo() {
      if (!this.item.toolInfo) {
        return null;
      }
      try {
        return JSON.parse(this.item.toolInfo);
      } catch (e) {
        captureException(e);
        return null;
      }
    },
    toolResponse() {
      return this.toolInfo?.tool_response ?? null;
    },
    filePath() {
      return this.toolInfo?.args?.file_path;
    },
    title() {
      if (this.index === 0) {
        return s__('DuoAgentPlatform|Session triggered');
      }
      return getMessageData(this.item)?.title;
    },
    isMarkdown() {
      return !this.componentLabel && this.item.messageType !== 'user' && this.index > 0;
    },
    isFullContentMessage() {
      return this.item.messageType === 'request' || this.item.messageType === 'agent';
    },
    componentLabel() {
      return getComponentLabel(this.item);
    },
    componentColorIndex() {
      return this.componentColorIndexMap[this.componentLabel?.componentName] ?? 0;
    },
    toolInfoName() {
      return this.toolInfo?.name;
    },
    inlineContent() {
      return truncate(this.item.content, INLINE_CONTENT_MAX_LENGTH);
    },
    collapseIcon() {
      return this.visible ? 'chevron-down' : 'chevron-right';
    },
    toolContentComponent() {
      return getToolContentRenderer(this.toolInfo?.name);
    },
    flowFinished() {
      return Boolean(this.item.todoFinished);
    },
    isApprovalRequest() {
      return (
        this.item.messageType === 'request' &&
        this.canResumeWorkflow &&
        this.canUpdateWorkflow &&
        this.last
      );
    },
  },
};
</script>
<template>
  <div class="gl-w-full gl-pt-1">
    <div class="gl-flex gl-justify-between">
      <strong class="gl-mb-1 gl-text-strong" data-testid="log-entry-title">{{ title }}</strong>

      <time-ago-tooltip
        :time="item.timestamp"
        css-class="gl-text-subtle gl-text-sm"
        data-testid="log-entry-timestamp"
      />
    </div>

    <div
      class="gl-overflow-wrap-anywhere gl-mb-1 gl-flex gl-items-start gl-justify-between gl-gap-2"
    >
      <div>
        <template v-if="componentLabel">
          <p class="gl-m-0 gl-py-2 gl-wrap-anywhere" data-testid="log-entry-attributed-line">
            <component-label
              :component-name="componentLabel.componentName"
              :color-index="componentColorIndex"
              data-testid="log-entry-component-label"
            />
            <template v-if="!isFullContentMessage">
              <template v-if="toolInfoName">
                <span class="gl-text-subtle" data-testid="log-entry-tool-name">{{
                  toolInfoName
                }}</span>
                <span aria-hidden="true">—</span>
              </template>
              <span data-testid="log-entry-inline-content">{{ inlineContent }}</span>
            </template>
          </p>
          <non-gfm-markdown
            v-if="isFullContentMessage"
            :markdown="item.content"
            class="gl-m-0 gl-flex-1 gl-py-2 gl-pr-7 gl-wrap-anywhere"
            data-testid="log-entry-markdown"
          />
        </template>
        <non-gfm-markdown
          v-else-if="isMarkdown"
          :markdown="item.content"
          class="gl-m-0 gl-flex-1 gl-py-2 gl-pr-7 gl-wrap-anywhere"
          data-testid="log-entry-markdown"
        />
        <div
          v-else
          class="gl-m-0 gl-flex-1 gl-break-all gl-py-2"
          data-testid="log-entry-plain-text"
        >
          {{ item.content }}
        </div>
        <code v-if="filePath" class="gl-break-all" data-testid="log-entry-file-path">
          {{ filePath }}
        </code>
      </div>
      <gl-button
        v-if="toolInfo"
        :icon="collapseIcon"
        size="small"
        category="tertiary"
        :aria-label="s__('DuoAgentPlatform|Show tool details')"
        data-testid="log-entry-collapse-button"
        @click="visible = !visible"
      />
    </div>
    <gl-collapse v-if="toolInfo" :visible="visible" data-testid="log-entry-collapse">
      <subagent-badge
        v-if="componentLabel && componentLabel.isSubagent"
        class="gl-mt-4"
        :component-name="componentLabel.componentName"
        :subsession-id="componentLabel.subsessionId"
        :status="item.status"
        data-testid="log-entry-subagent-badge"
      />
      <component
        :is="toolContentComponent"
        v-if="toolContentComponent"
        :tool-info="toolInfo"
        :flow-finished="flowFinished"
        data-testid="log-entry-custom-renderer"
      />
      <template v-else>
        <message-tool-kv-section
          class="gl-mt-4"
          :title="s__('DuoAgentPlatform|Request')"
          :value="toolInfo.args"
        />
        <message-tool-kv-section
          v-if="toolResponse"
          class="gl-mt-4"
          :title="s__('DuoAgentPlatform|Response')"
          :value="toolResponse"
          data-testid="log-entry-tool-response"
        />
      </template>
    </gl-collapse>

    <agent-flow-user-approval v-if="isApprovalRequest" />
  </div>
</template>
