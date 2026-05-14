<script>
import { GlAvatarLabeled, GlAvatarLink, GlKeysetPagination, GlTable } from '@gitlab/ui';
import { s__ } from '~/locale';
import { formatNumber } from '../../../usage_billing/utils';

export default {
  name: 'UsersList',
  components: {
    GlAvatarLabeled,
    GlAvatarLink,
    GlKeysetPagination,
    GlTable,
  },
  props: {
    users: {
      type: Object,
      required: true,
    },
    userUsagePath: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['next-page', 'prev-page'],
  computed: {
    userNodes() {
      return this.users.nodes ?? [];
    },
  },
  methods: {
    formatNumber,
    getUserUsagePath(username) {
      if (!this.userUsagePath) return null;
      return this.userUsagePath.replace('__USERNAME__', username);
    },
    onNextPage(cursor) {
      this.$emit('next-page', cursor);
    },
    onPrevPage(cursor) {
      this.$emit('prev-page', cursor);
    },
  },
  tableFields: [
    {
      key: 'user',
      label: s__('UsageBilling|User'),
    },
    {
      key: 'creditsUsed',
      label: s__('UsageBilling|Credits used'),
      thAlignRight: true,
      tdClass: 'gl-text-right',
    },
  ],
};
</script>

<template>
  <div>
    <gl-table
      :items="userNodes"
      :fields="$options.tableFields"
      show-empty
      stacked="md"
      class="gl-w-full"
      borderless
    >
      <template #head(creditsUsed)="{ label }">
        <div class="gl-flex gl-justify-end">{{ label }}</div>
      </template>

      <template #cell(user)="{ item: user }">
        <gl-avatar-link :href="getUserUsagePath(user.username)" :alt="user.name">
          <gl-avatar-labeled
            :src="user.avatarUrl"
            :size="32"
            :label="user.name"
            :sub-label="`@${user.username}`"
          />
        </gl-avatar-link>
      </template>

      <template #cell(creditsUsed)="{ item: user }">
        {{ formatNumber(user.usage?.totalCreditsUsed) }}
      </template>

      <template #empty>
        <div class="gl-py-6 gl-text-center">
          <p class="gl-mb-0 gl-text-subtle">{{ s__('UsageBilling|No user data available') }}</p>
        </div>
      </template>
    </gl-table>

    <div class="gl-mt-5 gl-flex gl-justify-center">
      <gl-keyset-pagination v-bind="users.pageInfo" @prev="onPrevPage" @next="onNextPage" />
    </div>
  </div>
</template>
