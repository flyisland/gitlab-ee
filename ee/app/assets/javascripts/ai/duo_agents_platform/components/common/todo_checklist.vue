<script>
import { GlIcon } from '@gitlab/ui';

export default {
  name: 'TodoChecklist',
  components: {
    GlIcon,
  },
  props: {
    toolInfo: {
      type: Object,
      required: true,
    },
  },
  computed: {
    todos() {
      return this.toolInfo?.args?.todos || [];
    },
  },
  methods: {
    statusIcon(status) {
      const iconMap = {
        completed: 'check',
        in_progress: 'status-running',
        pending: 'status-waiting',
        cancelled: 'close',
      };
      return iconMap[status] ?? 'status-waiting';
    },
  },
};
</script>
<template>
  <div
    v-if="todos.length"
    data-testid="todo-checklist-container"
    class="gl-border gl-rounded-base gl-px-4 gl-py-3"
  >
    <ul class="gl-m-0 gl-list-none gl-pl-0">
      <li
        v-for="(todo, index) in todos"
        :key="index"
        class="gl-flex gl-items-center gl-gap-3 gl-py-1"
      >
        <gl-icon :name="statusIcon(todo.status)" :size="14" class="gl-shrink-0 gl-text-subtle" />
        <span class="gl-text-subtle">{{ todo.description }}</span>
      </li>
    </ul>
  </div>
</template>
