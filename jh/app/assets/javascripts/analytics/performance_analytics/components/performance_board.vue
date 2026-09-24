<script>
import PerformanceCards from 'jh/analytics/performance_analytics/components/performance_cards.vue';
import RankList from 'jh/analytics/performance_analytics/components/rank_list.vue';

export default {
  name: 'PerformanceBoard',
  components: {
    PerformanceCards,
    RankList,
  },
};
</script>

<template>
  <div class="performance-board gl-sm-flex-direction-column gl-flex">
    <performance-cards class="gl-mr-6 gl-flex-grow-2 gl-basis-0 gl-flex-wrap" />
    <rank-list />
  </div>
</template>
