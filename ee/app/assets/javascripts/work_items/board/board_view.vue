<script>
import BoardView from '~/work_items/board/board_view.vue';

export default {
  name: 'BoardViewEE',
  components: {
    BoardView,
  },
  props: {
    rootPageFullPath: {
      type: String,
      required: true,
    },
    queryVariables: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <board-view
    :root-page-full-path="rootPageFullPath"
    :query-variables="queryVariables"
    v-on="$listeners"
  />
</template>
