<script>
import { defineComponent } from 'vue';
import { GlCollapsibleListbox, GlModal, GlSprintf } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

export default defineComponent({
  name: 'OrbitConfigureButtonBase',
  compatConfig: { MODE: 3 },
  components: {
    GlCollapsibleListbox,
    GlModal,
    GlSprintf,
  },
  props: {
    namespaces: {
      type: Array,
      required: false,
      default: () => [],
    },
    namespacesLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    enabling: {
      type: Boolean,
      required: false,
      default: false,
    },
    pendingGroup: {
      type: Object,
      required: false,
      default: null,
    },
    confirmModalVisible: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['select', 'confirm-enable', 'modal-hidden'],
  i18n: {
    configure: s__('Orbit|Configure'),
    headerText: s__('Orbit|Configure Orbit for a group'),
    noResultsText: s__('Orbit|No groups match your search.'),
    notEnabledText: s__('Orbit|Orbit not enabled'),
    primary: s__('Orbit|Turn on indexing'),
    cancel: s__('Orbit|Cancel'),
    accessIntro: s__(
      "Orbit|All content from this group, its subgroups, and projects will be added to Orbit. Existing access controls still apply — users who cannot access content in this group won't see it through Orbit.",
    ),
    initialScan: s__(
      'Orbit|%{boldStart}The initial scan can take some time depending on the amount of content.%{boldEnd} After that, updated content is automatically re-indexed. You can turn off Orbit at any time.',
    ),
  },
  data() {
    return {
      search: '',
    };
  },
  computed: {
    filteredNamespaces() {
      const term = this.search.trim().toLowerCase();
      if (!term) return this.namespaces;
      return this.namespaces.filter(
        (ns) =>
          ns.name.toLowerCase().includes(term) ||
          ns.fullName?.toLowerCase().includes(term) ||
          ns.fullPath.toLowerCase().includes(term),
      );
    },
    enabledNamespaces() {
      return this.filteredNamespaces
        .filter((ns) => ns.knowledgeGraphEnabled)
        .toSorted((a, b) => a.name.localeCompare(b.name));
    },
    disabledNamespaces() {
      return this.filteredNamespaces
        .filter((ns) => !ns.knowledgeGraphEnabled)
        .toSorted((a, b) => a.name.localeCompare(b.name));
    },
    enabledGroup() {
      if (!this.enabledNamespaces.length) return null;
      return { text: '', options: this.enabledNamespaces.map(this.toListboxItem) };
    },
    disabledGroup() {
      if (!this.disabledNamespaces.length) return null;
      return {
        text: this.$options.i18n.notEnabledText,
        options: this.disabledNamespaces.map(this.toListboxItem),
      };
    },
    groupedListboxItems() {
      return [this.enabledGroup, this.disabledGroup].filter(Boolean);
    },
    modalTitle() {
      if (!this.pendingGroup) return '';
      return sprintf(s__('Orbit|Turn on Orbit indexing for %{groupName}'), {
        groupName: this.pendingGroup.name,
      });
    },
    primaryAction() {
      return {
        text: this.$options.i18n.primary,
        attributes: { variant: 'confirm', loading: this.enabling },
      };
    },
    cancelAction() {
      return {
        text: this.$options.i18n.cancel,
        attributes: { disabled: this.enabling },
      };
    },
  },
  methods: {
    toListboxItem(ns) {
      return { value: ns.fullPath, text: ns.name };
    },
    onSearch(term) {
      this.search = term;
    },
    onSelect(fullPath) {
      this.$emit('select', fullPath);
    },
  },
});
</script>

<template>
  <div>
    <gl-collapsible-listbox
      :items="groupedListboxItems"
      :searchable="true"
      :searching="namespacesLoading"
      :toggle-text="$options.i18n.configure"
      :header-text="$options.i18n.headerText"
      :no-results-text="$options.i18n.noResultsText"
      icon="settings"
      data-testid="orbit-configure-groups-listbox"
      @search="onSearch"
      @select="onSelect"
    />
    <gl-modal
      :visible="confirmModalVisible"
      modal-id="orbit-enable-confirm-modal"
      :title="modalTitle"
      :action-primary="primaryAction"
      :action-cancel="cancelAction"
      data-testid="orbit-enable-confirm-modal"
      @primary.prevent="$emit('confirm-enable')"
      @hidden="$emit('modal-hidden')"
    >
      <p>{{ $options.i18n.accessIntro }}</p>
      <p>
        <gl-sprintf :message="$options.i18n.initialScan">
          <template #bold="{ content }">
            <strong>{{ content }}</strong>
          </template>
        </gl-sprintf>
      </p>
    </gl-modal>
  </div>
</template>
