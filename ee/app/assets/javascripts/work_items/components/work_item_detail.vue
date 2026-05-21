<script>
import WorkItemDetail from '~/work_items/components/work_item_detail.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import AgentPlan from 'ee/work_items/components/agent_plan/agent_plan.vue';
import { findWidget } from '~/work_items/list/utils';
import { WIDGET_TYPE_AGENT_PLAN } from '../constants';

export default {
  name: 'WorkItemDetailEE',
  components: {
    WorkItemDetail,
    AgentPlan,
  },
  mixins: [glFeatureFlagsMixin()],
  inheritAttrs: false,
  methods: {
    isAgentPlanAvailable(workItem) {
      return (
        this.glFeatures.agentPlan &&
        (this.glFeatures.workItemFeaturesField
          ? workItem.features?.agentPlan || false
          : findWidget(WIDGET_TYPE_AGENT_PLAN, workItem))
      );
    },
  },
};
</script>

<template>
  <work-item-detail v-bind="$attrs" v-on="$listeners">
    <template #widgets="{ workItem }">
      <agent-plan
        v-if="workItem && isAgentPlanAvailable(workItem)"
        :work-item-id="workItem.id"
        :can-update="workItem.userPermissions?.updateWorkItem"
        :content="''"
        @save="() => {}"
      />
    </template>
  </work-item-detail>
</template>
