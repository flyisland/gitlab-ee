<script>
import { GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { getMessageData } from 'ee/ai/duo_agents_platform/utils';
import LogEntry from './log_entry.vue';

export default {
  components: {
    GlIcon,
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
            item.content &&
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
  methods: {
    assignIcon(message, index) {
      // TODO: The starting message might warrant its own type
      // https://gitlab.com/gitlab-org/gitlab/-/issues/562418
      if (index === 0) {
        return this.$options.startMessage.icon;
      }

      return getMessageData(message)?.icon;
    },
    isLast(index) {
      return index === this.items.length - 1;
    },
  },
  startMessage: { icon: 'play', title: s__('DuoAgentPlatform|Session triggered'), level: 1 },
};
</script>
<template>
  <ul id="activity-list" class="gl-relative gl-flex gl-flex-col gl-pl-0">
    <li v-for="(item, index) in items" :key="item.id" class="gl-relative gl-mb-5 gl-flex gl-w-full">
      <div :ref="`icon-${index}`" class="gl-relative gl-mr-4 gl-flex gl-flex-col gl-items-center">
        <div class="gl-border gl-rounded-full gl-bg-strong gl-p-2">
          <gl-icon :name="assignIcon(item, index)" variant="subtle" />
        </div>
      </div>

      <log-entry
        :item="item"
        :index="index"
        :last="isLast(index)"
        :can-resume-workflow="canResumeWorkflow"
        :can-update-workflow="canUpdateWorkflow"
      />
    </li>
  </ul>
</template>
