<script>
import { s__, __ } from '~/locale';
import { ACCESS_LEVEL_MAINTAINER_STRING } from '~/access_level/constants';
import getProjects from '~/graphql_shared/queries/get_users_projects.query.graphql';
import getGroupProjects from '../graphql/queries/ai_catalog_group_projects.query.graphql';
import getAvailableProjects from '../graphql/queries/ai_catalog_available_projects.query.graphql';
import SingleSelectDropdown from './single_select_dropdown.vue';

export default {
  name: 'FormProjectDropdown',
  components: {
    SingleSelectDropdown,
  },
  props: {
    id: {
      type: String,
      required: false,
      default: null,
    },
    value: {
      type: String,
      required: false,
      default: null,
    },
    isValid: {
      type: Boolean,
      required: false,
      default: true,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    groupFullPath: {
      type: String,
      required: false,
      default: null,
    },
    itemId: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['error', 'input'],
  computed: {
    isFilteringEnabledProjects() {
      return Boolean(this.itemId) && !this.groupFullPath;
    },
    query() {
      if (this.groupFullPath) return getGroupProjects;
      if (this.isFilteringEnabledProjects) return getAvailableProjects;
      return getProjects;
    },
    queryVariables() {
      if (this.groupFullPath) {
        return { fullPath: this.groupFullPath };
      }
      const baseVariables = {
        minAccessLevel: ACCESS_LEVEL_MAINTAINER_STRING,
        sort: 'similarity',
        searchNamespaces: true,
      };
      if (this.isFilteringEnabledProjects) {
        return { ...baseVariables, itemId: this.itemId };
      }
      return baseVariables;
    },
    dataKey() {
      return this.groupFullPath ? 'group.projects' : 'projects';
    },
  },
  methods: {
    itemAlreadyEnabledFn(item) {
      return Boolean(item?.aiCatalogItemConsumerForItem?.enabled);
    },
    itemTextFn(item) {
      return this.groupFullPath ? item?.name : item?.nameWithNamespace;
    },
    itemLabelFn(item) {
      return item?.name;
    },
    itemSubLabelFn(item) {
      return this.groupFullPath ? null : item?.nameWithNamespace;
    },
    itemDisabledFn(item) {
      return this.itemAlreadyEnabledFn(item);
    },
    itemTrailingLabelFn(item) {
      return this.itemAlreadyEnabledFn(item) ? s__('AICatalog|Already enabled') : null;
    },
    onInput(item) {
      this.$emit('input', item.id);
    },
    onError() {
      this.$emit('error', __('Failed to load projects'));
    },
  },
};
</script>

<template>
  <single-select-dropdown
    :id="id"
    :value="value"
    :is-valid="isValid"
    :disabled="disabled"
    :query="query"
    :query-variables="queryVariables"
    :data-key="dataKey"
    :placeholder-text="__('Select a project')"
    searchable
    :item-text-fn="itemTextFn"
    :item-label-fn="itemLabelFn"
    :item-sub-label-fn="itemSubLabelFn"
    :item-disabled-fn="itemDisabledFn"
    :item-trailing-label-fn="itemTrailingLabelFn"
    @input="onInput"
    @error="onError"
  />
</template>
