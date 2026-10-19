<script>
import { defineComponent } from 'vue';
import { GlButton, GlIcon } from '@gitlab/ui';

export default defineComponent({
  name: 'QueryDuoRequest',
  compatConfig: { MODE: 3 },
  components: { GlButton, GlIcon },
  emits: ['submit'],
  data() {
    return {
      request: '',
    };
  },
  computed: {
    isRequestEmpty() {
      return !this.request.trim();
    },
  },
});
</script>

<template>
  <form
    class="gl-border-t gl-flex gl-items-center gl-gap-3 gl-border-default gl-bg-subtle gl-py-2 gl-pl-4 gl-pr-2"
    @submit.prevent="$emit('submit', request)"
  >
    <gl-icon name="tanuki-ai" />
    <label for="orbit-query-duo-request" class="gl-sr-only">
      {{ s__('Orbit|Describe a query for GitLab Duo to write') }}
    </label>
    <input
      id="orbit-query-duo-request"
      v-model="request"
      type="text"
      class="gl-min-w-0 gl-grow gl-border-0 gl-bg-transparent gl-py-2 focus:gl-focus"
      :placeholder="s__('Orbit|Or describe what you want, and GitLab Duo writes the query')"
    />
    <gl-button type="submit" size="small" :disabled="isRequestEmpty">
      {{ s__('Orbit|Generate') }}
    </gl-button>
  </form>
</template>
