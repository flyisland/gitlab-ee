<script>
import WorkItemDetail from '~/work_items/components/work_item_detail.vue';
import AgentPlan from 'ee/work_items/components/agent_plan/agent_plan.vue';
import WorkItemAgentSessions from 'ee/work_items/components/agent_sessions/index.vue';
import { AGENT_PLAN_PANEL } from '~/work_items/constants';
import { findAgentPlanWidget } from 'ee/work_items/utils';

export default {
  name: 'WorkItemDetailEE',
  AGENT_PLAN_PANEL,
  components: {
    WorkItemDetail,
    AgentPlan,
    WorkItemAgentSessions,
  },
  inheritAttrs: false,
  methods: {
    isAgentPlanAvailable(workItem) {
      return Boolean(findAgentPlanWidget(workItem));
    },
  },
};
</script>

<template>
  <work-item-detail v-bind="$attrs" v-on="$listeners">
    <template #widgets-top="{ workItem, isDetailPanel, activePanel, editMode, requestPanel }">
      <!-- eslint-disable local-rules/vue-no-web-url -- Internal drawer-redirect URL; webUrl is what the work-item fragment already exposes. -->
      <agent-plan
        v-if="workItem && isAgentPlanAvailable(workItem) && !editMode"
        :work-item="workItem"
        :work-item-web-url="workItem.webUrl"
        :is-in-drawer="isDetailPanel"
        :is-panel-open="activePanel === $options.AGENT_PLAN_PANEL"
        :can-update="workItem.userPermissions?.updateWorkItem"
        class="gl-mb-5"
        @request-panel="requestPanel"
      />
      <!-- eslint-enable local-rules/vue-no-web-url -->
    </template>
    <template #widgets="{ workItem }">
      <work-item-agent-sessions v-if="workItem" :work-item-id="workItem.id" />
    </template>
  </work-item-detail>
</template>
