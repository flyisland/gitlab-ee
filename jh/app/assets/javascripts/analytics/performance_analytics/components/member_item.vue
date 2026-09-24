<script>
import { GlAvatarLink, GlAvatarLabeled } from '@gitlab/ui';
import { escape } from 'lodash-es';
import { AVATAR_SIZE } from 'jh/analytics/performance_analytics/constants';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import SafeHtml from '~/vue_shared/directives/safe_html';
import medalGold from 'jh_images/leaderboard/medal_gold.svg?raw';
import medalSilver from 'jh_images/leaderboard/medal_silver.svg?raw';
import medalBronze from 'jh_images/leaderboard/medal_bronze.svg?raw';

export default {
  name: 'MemberItem',
  components: {
    GlAvatarLink,
    GlAvatarLabeled,
  },
  avatarSize: AVATAR_SIZE,
  directives: {
    SafeHtml,
  },
  props: {
    member: {
      type: Object,
      required: true,
    },
    ranking: {
      type: Number,
      required: true,
    },
  },
  computed: {
    memberInfo() {
      const memberDetail = convertObjectPropsToCamelCase(this.member.user);
      memberDetail.value = this.member.value;
      return memberDetail;
    },
    memberLink() {
      return escape(this.memberInfo.userWebUrl);
    },
    memberMedal() {
      const medalsList = [medalGold, medalSilver, medalBronze];
      return medalsList[this.ranking] ? medalsList[this.ranking] : null;
    },
  },
};
</script>

<template>
  <gl-avatar-link
    class="member-item gl-border-b gl-flex gl-items-center gl-justify-between gl-py-5"
    :href="memberLink"
    :data-username="memberInfo.username"
  >
    <div class="gl-flex gl-items-center">
      <div
        v-if="memberMedal"
        v-safe-html="memberMedal"
        data-testid="member-ranking-icon"
        class="gl-mr-1 gl-flex gl-w-7 gl-items-center"
      ></div>
      <span
        v-else
        data-testid="member-ranking-text"
        class="gl-mr-1 gl-flex gl-w-7 gl-justify-center gl-text-lg gl-text-default"
        >{{ ranking + 1 }}</span
      >
      <gl-avatar-labeled
        :label="memberInfo.fullname"
        :sub-label="`@${memberInfo.username}`"
        :size="$options.avatarSize"
        :src="memberInfo.avatar"
        :alt="memberInfo.fullname"
      />
    </div>
    <span class="gl-text-lg gl-text-default">{{ memberInfo.value }}</span>
  </gl-avatar-link>
</template>
