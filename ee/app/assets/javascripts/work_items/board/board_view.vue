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
    collapsedGroups: {
      type: Array,
      required: false,
      default: () => [],
    },
    hiddenMetadataKeys: {
      type: Array,
      required: false,
      default: () => [],
    },
    visibleGroups: {
      required: false,
      default: null,
      validator: (value) => value === null || Array.isArray(value),
    },
    activeItem: {
      type: Object,
      required: false,
      default: null,
    },
    detailPanelEnabled: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
};
</script>

<template>
  <board-view
    :root-page-full-path="rootPageFullPath"
    :query-variables="queryVariables"
    :collapsed-groups="collapsedGroups"
    :hidden-metadata-keys="hiddenMetadataKeys"
    :visible-groups="visibleGroups"
    :active-item="activeItem"
    :detail-panel-enabled="detailPanelEnabled"
    v-on="$listeners"
  />
</template>
