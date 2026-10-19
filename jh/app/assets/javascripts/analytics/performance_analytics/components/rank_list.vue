<script>
import { mapState, mapActions, mapMutations } from 'vuex';
import { isUndefined } from 'lodash-es';
import { GlCard, GlCollapsibleListbox, GlLoadingIcon } from '@gitlab/ui';
import VirtualList from 'vue-virtual-scroll-list';
import { createAlert } from '~/alert';
import {
  PERFORMANCE_TYPE_COMMITS_NUMBER,
  RANK_DROPDOWN_OPTIONS,
  EMPTY_TABLE_TEXT,
  PERFORMANCE_TYPE_PUSH_TEXTS,
} from 'jh/analytics/performance_analytics/constants';
import { s__ } from '~/locale';
import { SET_RANK_LIST } from 'jh/analytics/performance_analytics/store/mutation_types';
import MemberItem from 'jh/analytics/performance_analytics/components/member_item.vue';
import Tracking from '~/tracking';

const trackingMixin = Tracking.mixin();

export default {
  name: 'RankList',
  components: {
    GlCard,
    GlCollapsibleListbox,
    VirtualList,
    MemberItem,
    GlLoadingIcon,
  },
  mixins: [trackingMixin],
  data() {
    return {
      selectedRankType: PERFORMANCE_TYPE_COMMITS_NUMBER,
      rankListLoading: false,
      // The following is used by upstream component, we are simply overriding it
      // eslint-disable-next-line vue/no-unused-properties
      currentPage: 1,
    };
  },
  computed: {
    ...mapState({
      isGroup: (state) => state.isGroup,
      rankList: (state) => state.rankList,
    }),
    showEmptyTip() {
      return this.rankList.length === 0 && !this.rankListLoading;
    },
    rankItemsList() {
      if (this.isGroup) {
        const groupOptions = RANK_DROPDOWN_OPTIONS.map((item) => {
          if (!isUndefined(PERFORMANCE_TYPE_PUSH_TEXTS[item.key])) {
            return {
              value: item.key,
              text: PERFORMANCE_TYPE_PUSH_TEXTS[item.key],
            };
          }
          return item;
        });

        return groupOptions;
      }

      return RANK_DROPDOWN_OPTIONS;
    },
  },
  methods: {
    ...mapMutations({
      setRankList: SET_RANK_LIST,
    }),
    ...mapActions(['updateMemberRankList']),
    onSelect(type) {
      this.track('click_dropdown', {
        label: 'switch_leaderboard_type',
        value: type,
      });

      this.selectedRankType = type;
      this.rankListLoading = true;
      this.updateMemberRankList(type)
        .then((res) => {
          const response = res?.data;
          this.setRankList(response);
          this.$refs.virtualScroller.setScrollTop(0);
          this.$refs.virtualScroller.forceRender();
          this.rankListLoading = false;
        })
        .catch(() => {
          createAlert({
            message: s__('JH|There was an error while fetching performance analytics data.'),
          });
          this.rankListLoading = false;
        });
    },
  },
  i18n: {
    rankListTitle: s__('JH|Leaderboard'),
    emptyText: EMPTY_TABLE_TEXT,
  },
};
</script>

<template>
  <div class="rank-list gl-mb-6 gl-grow gl-basis-0" data-testid="rank-list">
    <gl-card header-class="gl-flex gl-justify-between gl-items-center" body-class="gl-pt-1 gl-px-0">
      <template #header>
        <h5 class="gl-my-0">{{ $options.i18n.rankListTitle }}</h5>
        <gl-collapsible-listbox
          v-model="selectedRankType"
          size="small"
          :items="rankItemsList"
          data-testid="leaderboard-option"
          right
          @select="onSelect"
        />
      </template>
      <template #default>
        <virtual-list ref="virtualScroller" :size="64" :remain="5" class="gl-px-5">
          <div v-if="showEmptyTip" class="gl-flex gl-justify-center gl-text-gray-400">
            {{ $options.i18n.emptyText }}
          </div>
          <gl-loading-icon v-if="rankListLoading" class="gl-my-5" size="lg" />
          <member-item
            v-for="(item, index) in rankList"
            v-else
            :key="`${item.user.username}-${index}`"
            :member="item"
            :ranking="index"
          />
        </virtual-list>
      </template>
    </gl-card>
  </div>
</template>
