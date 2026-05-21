<script>
import { GlTab, GlTabs } from '@gitlab/ui';
import { s__ } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

const TABS = {
  TOOL_MANAGEMENT: {
    title: s__('AiGovernance|Tool management'),
    queryParamValue: 'tool-management',
  },
  AGENT_ARTIFACTS: {
    title: s__('AiGovernance|Agent artifacts'),
    queryParamValue: 'agent-artifacts',
  },
};

export default {
  TABS,
  name: 'GovernanceApp',
  components: {
    GlTabs,
    GlTab,
    PageHeading,
    AiToolManagementApp: () =>
      import(
        /* webpackChunkName: 'ai_tool_management_app' */ './ai_tool_management/ai_tool_management_app.vue'
      ),
    AgentArtifactsApp: () =>
      import(
        /* webpackChunkName: 'agent_artifacts_app' */ 'ee/agent_artifacts/components/agent_artifacts_app.vue'
      ),
  },
  mixins: [glFeatureFlagMixin()],
  data() {
    return {
      activeTabIndex: 0,
    };
  },
  computed: {
    showAgentArtifactsTab() {
      return this.glFeatures.agentArtifactsPage;
    },
  },
};
</script>

<template>
  <div>
    <page-heading :heading="s__('AiGovernance|AI Governance')">
      <template #description>
        {{ s__('AiGovernance|Control how your AI-powered features are used.') }}
      </template>
    </page-heading>

    <gl-tabs v-model="activeTabIndex" content-class="gl-pt-0" sync-active-tab-with-query-params>
      <gl-tab
        data-testid="tool-management-tab"
        :title="$options.TABS.TOOL_MANAGEMENT.title"
        :query-param-value="$options.TABS.TOOL_MANAGEMENT.queryParamValue"
        lazy
      >
        <ai-tool-management-app />
      </gl-tab>

      <gl-tab
        v-if="showAgentArtifactsTab"
        data-testid="agent-artifacts-tab"
        :title="$options.TABS.AGENT_ARTIFACTS.title"
        :query-param-value="$options.TABS.AGENT_ARTIFACTS.queryParamValue"
        lazy
      >
        <agent-artifacts-app />
      </gl-tab>
    </gl-tabs>
  </div>
</template>
