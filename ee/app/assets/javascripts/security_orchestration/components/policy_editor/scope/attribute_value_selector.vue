<script>
import { GlCollapsibleListbox, GlFormGroup, GlLabel, GlPopover } from '@gitlab/ui';
import { uniqueId } from 'lodash-es';
import { s__, __ } from '~/locale';
import { searchInItemsProperties } from '~/lib/utils/search_utils';
import { renderMultiSelectText } from 'ee/security_orchestration/components/policy_editor/utils';

export default {
  i18n: {
    header: s__('SecurityOrchestration|Select attributes'),
    noResults: s__('SecurityOrchestration|No attributes'),
    noAttributesPopover: s__(
      'SecurityOrchestration|There are no attributes for the selected category',
    ),
    itemTypeName: s__('SecurityOrchestration|attributes'),
    selectAllLabel: __('Select all'),
    clearAllLabel: __('Clear all'),
  },
  name: 'AttributeValueSelector',
  components: {
    GlCollapsibleListbox,
    GlFormGroup,
    GlLabel,
    GlPopover,
  },
  props: {
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    items: {
      type: Array,
      required: true,
    },
    selected: {
      type: Array,
      required: false,
      default: () => [],
    },
    isCategoryEmpty: {
      type: Boolean,
      required: false,
      default: false,
    },
    isDirty: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['select', 'reset', 'select-all'],
  data() {
    return {
      searchTerm: '',
      dropdownId: uniqueId('attribute-value-selector-'),
    };
  },
  computed: {
    filteredItems() {
      return searchInItemsProperties({
        items: this.items,
        properties: ['text'],
        searchQuery: this.searchTerm,
      });
    },
    itemsMap() {
      return this.items.reduce((acc, { value, text }) => {
        acc[value] = text;
        return acc;
      }, {});
    },
    toggleText() {
      return renderMultiSelectText({
        selected: this.selected,
        items: this.itemsMap,
        itemTypeName: this.$options.i18n.itemTypeName,
      });
    },
    allIds() {
      return this.items.map(({ value }) => value);
    },
    isValid() {
      return !this.isDirty || this.selected.length > 0;
    },
  },
  methods: {
    setSearchTerm(searchTerm = '') {
      this.searchTerm = searchTerm.trim();
    },
    onSelect(ids) {
      this.$emit('select', ids);
    },
    onReset() {
      this.$emit('reset');
    },
    onSelectAll() {
      this.$emit('select-all', this.allIds);
    },
  },
};
</script>

<template>
  <gl-form-group class="gl-mb-0" :state="isValid">
    <gl-popover
      v-if="isCategoryEmpty"
      boundary="viewport"
      placement="bottom"
      show-close-button
      :target="dropdownId"
      :show="true"
      data-testid="no-attributes-popover"
    >
      <p class="gl-m-0">{{ $options.i18n.noAttributesPopover }}</p>
    </gl-popover>
    <gl-collapsible-listbox
      :id="dropdownId"
      data-testid="attribute-value-dropdown"
      multiple
      searchable
      :disabled="disabled || isCategoryEmpty"
      :loading="loading"
      :items="filteredItems"
      :header-text="$options.i18n.header"
      :no-results-text="$options.i18n.noResults"
      :reset-button-label="$options.i18n.clearAllLabel"
      :show-select-all-button-label="$options.i18n.selectAllLabel"
      :selected="selected"
      :toggle-text="toggleText"
      @search="setSearchTerm"
      @select="onSelect"
      @reset="onReset"
      @select-all="onSelectAll"
    >
      <template #list-item="{ item }">
        <gl-label :background-color="item.color" :title="item.text" />
      </template>
    </gl-collapsible-listbox>
  </gl-form-group>
</template>
