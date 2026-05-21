<script>
import { GlSkeletonLoader, GlAvatarLink, GlTooltipDirective } from '@gitlab/ui';
import { isGid, getIdFromGraphQLId } from '~/graphql_shared/utils';
import { getUser } from '~/api/user_api';
import * as Sentry from '~/sentry/sentry_browser_wrapper';

export default {
  name: 'AgentFlowTriggeredUser',
  components: {
    GlSkeletonLoader,
    GlAvatarLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    isLoading: {
      required: true,
      type: Boolean,
    },
    userId: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      user: {},
      isFetchingUser: false,
    };
  },
  computed: {
    numericUserId() {
      return this.userId && isGid(this.userId) ? getIdFromGraphQLId(this.userId) : this.userId;
    },
    userUsername() {
      return this.user?.username || '';
    },
    userWebUrl() {
      return this.user?.web_url || '';
    },
    userName() {
      return this.user?.name || '';
    },
    isLoadingUser() {
      return this.isLoading || this.isFetchingUser;
    },
  },
  watch: {
    numericUserId: {
      immediate: true,
      handler(newUserId) {
        if (newUserId) {
          this.fetchUser();
        }
      },
    },
  },
  methods: {
    async fetchUser() {
      this.isFetchingUser = true;
      try {
        const { data } = await getUser(this.numericUserId);
        this.user = data;
      } catch (error) {
        Sentry.captureException(error);
        this.user = {};
      } finally {
        this.isFetchingUser = false;
      }
    },
  },
};
</script>
<template>
  <span>
    <gl-skeleton-loader v-if="isLoadingUser" :lines="1" :width="400" />
    <gl-avatar-link
      v-else
      v-gl-tooltip.bottom
      :href="userWebUrl"
      :data-user-id="numericUserId"
      :data-username="userUsername"
      :title="userName"
      class="js-user-link"
    >
      @{{ userUsername }}
    </gl-avatar-link>
  </span>
</template>
