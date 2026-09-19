<script>
import { GlIcon } from '@gitlab/ui';
import { managedByLabel } from './utils';

export default {
  name: 'ScanProfileList',
  components: {
    GlIcon,
  },
  props: {
    profiles: {
      type: Array,
      required: true,
    },
    selectedId: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['select'],
  methods: {
    managedByLabel,
  },
};
</script>

<template>
  <ul class="gl-m-0 gl-list-none gl-p-0" data-testid="scan-profile-list">
    <li v-for="profile in profiles" :key="profile.id" class="gl-mr-5">
      <button
        type="button"
        class="gl-w-full gl-cursor-pointer gl-rounded-base gl-border-0 gl-bg-transparent gl-px-4 gl-py-3 gl-text-left"
        :class="{ '!gl-bg-blue-50': profile.id === selectedId }"
        :aria-current="profile.id === selectedId ? 'true' : null"
        data-testid="scan-profile-list-item"
        @click="$emit('select', profile.id)"
      >
        <span class="gl-block gl-font-bold gl-text-default">{{ profile.name }}</span>
        <span class="gl-mt-1 gl-line-clamp-2 gl-text-sm gl-text-subtle">
          {{ profile.description }}
        </span>
        <span class="gl-mt-2 gl-flex gl-items-center gl-gap-2 gl-text-sm gl-text-subtle">
          <gl-icon name="user" :size="12" />
          {{ managedByLabel(profile) }}
        </span>
      </button>
    </li>
  </ul>
</template>
