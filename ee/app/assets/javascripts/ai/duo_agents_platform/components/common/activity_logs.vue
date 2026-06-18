<script>
import { GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import {
  MESSAGE_SUB_TYPE_DELEGATION,
  MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
} from 'ee/ai/duo_agents_platform/constants';
import {
  buildComponentColorIndexMap,
  computeItemDepths,
  getDelegationData,
  getMessageData,
} from 'ee/ai/duo_agents_platform/utils';
import DelegationEntry from './delegation_entry.vue';
import LogEntry from './log_entry.vue';

// Static class strings so Tailwind JIT picks them up at build time.
// Dynamic class names like `gl-pl-${n}` are invisible to the content scanner
// and the corresponding utilities would be purged from the bundle.
const DEPTH_PADDING_CLASSES = ['', 'gl-pl-8', 'gl-pl-16', 'gl-pl-24'];
const MAX_DEPTH_PADDING_INDEX = DEPTH_PADDING_CLASSES.length - 1;

export default {
  name: 'ActivityLogs',
  components: {
    GlIcon,
    DelegationEntry,
    LogEntry,
  },
  props: {
    items: {
      type: Array,
      required: true,
      validator(items) {
        return items.every(
          (item) =>
            typeof item === 'object' &&
            typeof item.content === 'string' &&
            item.messageType &&
            item.status &&
            item.timestamp,
        );
      },
    },
    canResumeWorkflow: {
      type: Boolean,
      required: true,
    },
    canUpdateWorkflow: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    componentColorIndexMap() {
      return buildComponentColorIndexMap(this.items);
    },
    itemDepths() {
      return computeItemDepths(this.items);
    },
  },
  methods: {
    assignIcon(message, index) {
      // TODO: The starting message might warrant its own type
      // https://gitlab.com/gitlab-org/gitlab/-/issues/562418
      if (index === 0) {
        return this.$options.startMessage.icon;
      }

      return getMessageData(message)?.icon;
    },
    isDelegationOrReturn(item) {
      return [MESSAGE_SUB_TYPE_DELEGATION, MESSAGE_SUB_TYPE_DELEGATION_RETURNS].includes(
        item.messageSubType,
      );
    },
    getDelegationData,
    depthPaddingClass(index) {
      const depth = Math.min(this.itemDepths[index], this.$options.MAX_DEPTH_PADDING_INDEX);
      return this.$options.DEPTH_PADDING_CLASSES[depth] || '';
    },
    isLast(index) {
      return index === this.items.length - 1;
    },
  },
  startMessage: { icon: 'play', title: s__('DuoAgentPlatform|Session triggered'), level: 1 },
  DEPTH_PADDING_CLASSES,
  MAX_DEPTH_PADDING_INDEX,
};
</script>
<template>
  <ul id="activity-list" class="gl-relative gl-flex gl-flex-col gl-pl-0">
    <li
      v-for="(item, index) in items"
      :key="item.id"
      class="gl-relative gl-mb-5 gl-flex gl-w-full"
      :class="depthPaddingClass(index)"
      data-testid="activity-log-item"
    >
      <div :ref="`icon-${index}`" class="gl-relative gl-mr-4 gl-flex gl-flex-col gl-items-center">
        <div
          class="gl-flex gl-p-2"
          data-testid="activity-log-icon-wrapper"
          :class="{
            'gl-border gl-rounded-full gl-bg-strong': !isDelegationOrReturn(item),
          }"
        >
          <gl-icon :name="assignIcon(item, index)" variant="subtle" />
        </div>
      </div>

      <delegation-entry
        v-if="isDelegationOrReturn(item)"
        :item="item"
        :delegation-data="getDelegationData(item)"
      />
      <log-entry
        v-else
        :item="item"
        :index="index"
        :last="isLast(index)"
        :can-resume-workflow="canResumeWorkflow"
        :can-update-workflow="canUpdateWorkflow"
        :component-color-index-map="componentColorIndexMap"
      />
    </li>
  </ul>
</template>
