<script>
import { GlButton, GlCollapsibleListbox, GlIcon, GlTruncate } from '@gitlab/ui';
import { n__ } from '~/locale';

const mapItemToListboxFormat = (item) => ({ ...item, value: item.id, text: item.name });

// Temporary placeholder
// Replace with GraphQL `dependencyTrackedRefs` when it is completed
// https://gitlab.com/gitlab-org/gitlab/-/work_items/603818
const MOCK_TRACKED_REFS = [
  { id: 'gid://gitlab/Security::TrackedRef/1', name: 'main', refType: 'BRANCH' },
  { id: 'gid://gitlab/Security::TrackedRef/2', name: 'v1.0.0', refType: 'TAG' },
  { id: 'gid://gitlab/Security::TrackedRef/3', name: 'release/18.8', refType: 'BRANCH' },
];

export default {
  name: 'DependencyRefCount',
  components: {
    GlButton,
    GlCollapsibleListbox,
    GlIcon,
    GlTruncate,
  },
  props: {
    trackedRefsCount: {
      type: Number,
      required: true,
    },
    componentId: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      loading: true,
      trackedRefs: [],
    };
  },
  computed: {
    refsText() {
      return n__('Dependencies|%d ref', 'Dependencies|%d refs', this.trackedRefsCount);
    },
    // The `:searching` spinner only shows when `searchable` is also true
    searchEnabled() {
      return this.loading;
    },
  },
  methods: {
    async onShown() {
      this.loading = true;

      const refs = await this.fetchTrackedRefs(this.componentId);

      this.trackedRefs = refs.map(mapItemToListboxFormat);
      this.loading = false;
    },

    // Temporary to mimic a network fetch
    // Replace with GraphQL: https://gitlab.com/gitlab-org/gitlab/-/work_items/603818
    // eslint-disable-next-line no-unused-vars
    fetchTrackedRefs(componentId) {
      return Promise.resolve(MOCK_TRACKED_REFS);
    },
  },
};
</script>

<template>
  <gl-collapsible-listbox
    :header-text="refsText"
    :items="trackedRefs"
    :searching="loading"
    :searchable="searchEnabled"
    @shown="onShown"
  >
    <template #toggle>
      <gl-button variant="link" category="tertiary" data-testid="ref-count">
        <span class="@md/panel:gl-hidden">{{ trackedRefsCount }}</span>
        <span class="gl-hidden @md/panel:gl-inline-flex" data-testid="ref-count-text">{{
          refsText
        }}</span>
      </gl-button>
    </template>
    <template #list-item="{ item }">
      <span class="gl-flex gl-items-center gl-gap-3">
        <gl-icon :name="item.refType.toLowerCase()" :size="16" />
        <gl-truncate position="end" :text="item.name" with-tooltip class="gl-min-w-0" />
      </span>
    </template>
  </gl-collapsible-listbox>
</template>
