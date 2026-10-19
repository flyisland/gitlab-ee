<script>
import { defineComponent } from 'vue';
import { GlAlert } from '@gitlab/ui';

export default defineComponent({
  name: 'AdminGroupsWarnings',
  compatConfig: { MODE: 3 },
  components: {
    GlAlert,
  },
  props: {
    indexStatusError: {
      type: String,
      required: false,
      default: null,
    },
    excludedGroupsError: {
      type: String,
      required: false,
      default: null,
    },
  },
});
</script>

<template>
  <div v-if="indexStatusError || excludedGroupsError" class="gl-flex gl-flex-col gl-gap-4">
    <gl-alert
      v-if="indexStatusError"
      variant="warning"
      :title="s__('Orbit|Index status is not available right now')"
      :dismissible="false"
      data-testid="orbit-index-status-error"
    >
      <p class="gl-mb-2">{{ indexStatusError }}</p>
      <p class="gl-mb-0">{{ s__('Orbit|You can still turn Orbit on or off.') }}</p>
    </gl-alert>
    <gl-alert
      v-if="excludedGroupsError"
      variant="warning"
      :title="s__('Orbit|Could not load excluded groups')"
      :dismissible="false"
      data-testid="orbit-excluded-error"
    >
      <p class="gl-mb-2">{{ excludedGroupsError }}</p>
      <p class="gl-mb-0">
        {{ s__('Orbit|Bulk actions are not available until the excluded groups load.') }}
      </p>
    </gl-alert>
  </div>
</template>
