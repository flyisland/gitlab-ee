<script>
import { GlIcon } from '@gitlab/ui';
import { getTimeago } from '~/lib/utils/datetime/timeago_utility';

export default {
  name: 'ApplicationsList',
  components: {
    GlIcon,
  },
  props: {
    applications: {
      type: Array,
      default: () => [],
      required: false,
    },
  },
  methods: {
    getUpdatedText(value) {
      return getTimeago().format(value);
    },
  },
};
</script>

<template>
  <div class="gl-mt-5 gl-flex gl-gap-3">
    <div
      v-for="application in applications"
      :key="application.id"
      class="gl-basis-1/3 gl-rounded-lg gl-border-1 gl-border-solid gl-border-subtle gl-p-4"
      data-testid="application-card"
    >
      <h2 class="gl-m-0 gl-text-base">{{ application.name }}</h2>
      <span class="gl-text-sm gl-text-secondary">{{ application.group.name }}</span>
      <p class="gl-my-3 gl-text-sm gl-text-secondary">{{ application.description }}</p>
      <span class="gl-flex gl-items-center gl-gap-2">
        <gl-icon name="clock" :size="14" />
        <span class="gl-text-sm gl-text-secondary">
          {{ getUpdatedText(application.updatedAt) }}
        </span>
      </span>
    </div>
  </div>
</template>
