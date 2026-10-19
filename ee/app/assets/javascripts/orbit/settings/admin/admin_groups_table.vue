<script>
import { defineComponent } from 'vue';
import {
  GlAlert,
  GlAvatar,
  GlBadge,
  GlButton,
  GlCollapsibleListbox,
  GlDisclosureDropdown,
  GlFormCheckbox,
  GlKeysetPagination,
  GlLink,
  GlLoadingIcon,
  GlSearchBoxByType,
  GlSkeletonLoader,
  GlSprintf,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import { DEFAULT_DEBOUNCE_AND_THROTTLE_MS } from '~/lib/utils/constants';
import { n__, s__, sprintf } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import {
  ACTION_PROGRESS_LABELS,
  GROUP_FILTER_ALL,
  GROUP_FILTER_EXCLUDED,
  GROUP_FILTER_OPTIONS,
} from './constants';
import { groupNote, hasIndexingError, indexStatusLabel } from './utils';

export default defineComponent({
  name: 'AdminGroupsTable',
  compatConfig: { MODE: 3 },
  components: {
    GlAlert,
    GlAvatar,
    GlBadge,
    GlButton,
    GlCollapsibleListbox,
    GlDisclosureDropdown,
    GlFormCheckbox,
    GlKeysetPagination,
    GlLink,
    GlLoadingIcon,
    GlSearchBoxByType,
    GlSkeletonLoader,
    GlSprintf,
    GlTable,
    TimeAgoTooltip,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    groups: {
      type: Array,
      required: true,
    },
    selectedPaths: {
      type: Array,
      required: true,
    },
    actionItems: {
      type: Array,
      required: true,
    },
    search: {
      type: String,
      required: true,
    },
    filter: {
      type: String,
      required: true,
      validator: (value) => GROUP_FILTER_OPTIONS.some((option) => option.value === value),
    },
    pageInfo: {
      type: Object,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
    loadError: {
      type: String,
      required: false,
      default: null,
    },
    bulkProgress: {
      type: Object,
      required: false,
      default: null,
    },
    newGroupPath: {
      type: String,
      required: true,
    },
  },
  emits: ['search', 'filter', 'select', 'action', 'prev', 'next', 'retry'],
  computed: {
    rows() {
      return this.groups.map((group) => ({
        ...group,
        isSelected: this.selectedPaths.includes(group.fullPath),
        isPending: Boolean(this.bulkProgress?.pendingPaths.includes(group.fullPath)),
        showPath: group.fullPath !== group.name,
        selectLabel: sprintf(s__('Orbit|Select %{group}'), { group: group.fullPath }, false),
        statusLabel: indexStatusLabel(group),
        hasIndexingError: hasIndexingError(group),
        note: groupNote(group),
      }));
    },
    isRunning() {
      return this.bulkProgress !== null;
    },
    allSelected() {
      return this.groups.length > 0 && this.selectedPaths.length === this.groups.length;
    },
    someSelected() {
      return this.selectedPaths.length > 0 && !this.allSelected;
    },
    hasNoGroups() {
      return (
        !this.isLoading &&
        !this.loadError &&
        !this.groups.length &&
        !this.search &&
        this.filter === GROUP_FILTER_ALL &&
        !this.pageInfo.hasPreviousPage
      );
    },
    filterToggleText() {
      const option = GROUP_FILTER_OPTIONS.find(({ value }) => value === this.filter);
      return sprintf(s__('Orbit|Orbit state: %{state}'), { state: option.text });
    },
    selectedCountText() {
      return n__('Orbit|%d group selected', 'Orbit|%d groups selected', this.selectedPaths.length);
    },
    progressText() {
      const { action, done, total } = this.bulkProgress;
      return sprintf(s__('Orbit|%{action}: %{done} of %{total} done'), {
        action: ACTION_PROGRESS_LABELS[action],
        done,
        total,
      });
    },
    emptyTitle() {
      if (this.search)
        return sprintf(s__('Orbit|No groups match "%{search}"'), { search: this.search }, false);
      if (this.filter === GROUP_FILTER_EXCLUDED) return s__('Orbit|No groups are excluded');
      return s__('Orbit|No groups have Orbit on');
    },
    showPagination() {
      return this.pageInfo.hasNextPage || this.pageInfo.hasPreviousPage;
    },
  },
  methods: {
    toggleGroup(fullPath, checked) {
      const otherPaths = this.selectedPaths.filter((path) => path !== fullPath);
      this.$emit('select', checked ? [...otherPaths, fullPath] : otherPaths);
    },
    toggleAll(checked) {
      this.$emit('select', checked ? this.groups.map((group) => group.fullPath) : []);
    },
  },
  fields: [
    { key: 'select', label: '', thClass: 'gl-w-5' },
    { key: 'name', label: s__('Orbit|Group') },
    { key: 'state', label: s__('Orbit|Orbit state') },
    { key: 'status', label: s__('Orbit|Index status') },
  ],
  filterOptions: GROUP_FILTER_OPTIONS,
  searchDebounceMs: DEFAULT_DEBOUNCE_AND_THROTTLE_MS,
});
</script>

<template>
  <section class="gl-flex gl-flex-col gl-gap-4" aria-labelledby="orbit-groups-heading">
    <div>
      <h2 id="orbit-groups-heading" class="gl-heading-3 gl-mb-2">
        {{ s__('Orbit|Top-level groups') }}
      </h2>
      <p class="gl-mb-0 gl-text-subtle">
        {{
          s__(
            'Orbit|Select groups to turn Orbit on or off, or to exclude them from automatic indexing.',
          )
        }}
      </p>
    </div>

    <div v-if="!hasNoGroups" class="gl-flex gl-flex-wrap gl-items-center gl-gap-3">
      <gl-search-box-by-type
        :value="search"
        :placeholder="s__('Orbit|Search groups')"
        :debounce="$options.searchDebounceMs"
        :disabled="isRunning"
        class="gl-w-full sm:gl-w-30"
        data-testid="groups-search"
        @input="$emit('search', $event)"
      />
      <gl-collapsible-listbox
        :items="$options.filterOptions"
        :selected="filter"
        :toggle-text="filterToggleText"
        :disabled="isRunning"
        data-testid="groups-filter"
        @select="$emit('filter', $event)"
      />
      <div class="gl-flex gl-items-center gl-gap-3 sm:gl-ml-auto" aria-live="polite">
        <span v-if="isRunning" class="gl-flex gl-items-center gl-gap-2 gl-text-subtle">
          <gl-loading-icon size="sm" inline />
          {{ progressText }}
        </span>
        <span v-else-if="selectedPaths.length" class="gl-text-subtle">
          {{ selectedCountText }}
        </span>
      </div>
      <gl-disclosure-dropdown
        :items="actionItems"
        :toggle-text="s__('Orbit|Actions')"
        :disabled="isRunning || !actionItems.length"
        placement="bottom-end"
        data-testid="groups-actions"
        @action="$emit('action', $event.value)"
      />
    </div>

    <gl-alert
      v-if="loadError"
      variant="danger"
      :title="s__('Orbit|Could not load groups')"
      :dismissible="false"
      :primary-button-text="s__('Orbit|Try again')"
      data-testid="groups-load-error"
      @primary-action="$emit('retry')"
    >
      {{ loadError }}
    </gl-alert>

    <template v-else>
      <gl-table
        :items="rows"
        :fields="$options.fields"
        :busy="isLoading"
        primary-key="fullPath"
        responsive
        show-empty
        class="gl-mb-0"
        data-testid="groups-table"
      >
        <template #table-busy>
          <gl-skeleton-loader :lines="4" :width="600" equal-width-lines />
        </template>

        <template #head(select)>
          <gl-form-checkbox
            :checked="allSelected"
            :indeterminate="someSelected"
            :disabled="isRunning || !groups.length"
            :aria-label="s__('Orbit|Select all groups on this page')"
            data-testid="select-all-groups"
            @change="toggleAll"
          />
        </template>

        <template #cell(select)="{ item }">
          <gl-form-checkbox
            :checked="item.isSelected"
            :disabled="isRunning"
            :aria-label="item.selectLabel"
            data-testid="select-group"
            @change="toggleGroup(item.fullPath, $event)"
          />
        </template>

        <template #cell(name)="{ item }">
          <span class="gl-flex gl-items-center gl-gap-3 gl-whitespace-nowrap">
            <gl-avatar
              :src="item.avatarUrl"
              :entity-name="item.name"
              :size="24"
              shape="rect"
              :alt="''"
            />
            <span class="gl-flex gl-flex-col">
              <gl-link :href="item.webPath" class="gl-font-bold gl-text-default">
                {{ item.name }}
              </gl-link>
              <span v-if="item.showPath" class="gl-text-sm gl-text-subtle">{{
                item.fullPath
              }}</span>
            </span>
          </span>
        </template>

        <template #cell(state)="{ item }">
          <span v-if="item.isPending" class="gl-flex gl-items-center gl-gap-2 gl-text-subtle">
            <gl-loading-icon size="sm" inline />
            {{ s__('Orbit|Updating…') }}
          </span>
          <span v-else class="gl-flex gl-flex-wrap gl-items-center gl-gap-2">
            <gl-badge v-if="item.isOn" variant="success" icon="status-success">
              {{ s__('Orbit|On') }}
            </gl-badge>
            <gl-badge v-else variant="neutral">{{ s__('Orbit|Off') }}</gl-badge>
            <gl-badge v-if="item.isExcluded" variant="warning">{{
              s__('Orbit|Excluded')
            }}</gl-badge>
            <gl-badge v-if="item.failure" variant="danger" icon="error">
              {{ s__('Orbit|Failed') }}
            </gl-badge>
            <gl-button
              v-if="item.note"
              v-gl-tooltip
              :title="item.note"
              :aria-label="item.note"
              category="tertiary"
              size="small"
              icon="information-o"
              data-testid="group-note"
            />
          </span>
        </template>

        <template #cell(status)="{ item }">
          <span class="gl-whitespace-nowrap" :class="{ 'gl-text-danger': item.hasIndexingError }">
            {{ item.statusLabel }}
          </span>
          <span v-if="item.isOn && item.enabledAt" class="gl-whitespace-nowrap gl-text-subtle">
            ·
            <gl-sprintf :message="s__('Orbit|Turned on %{time}')">
              <template #time><time-ago-tooltip :time="item.enabledAt" /></template>
            </gl-sprintf>
          </span>
        </template>

        <template #empty>
          <div class="gl-py-7 gl-text-center" data-testid="groups-empty">
            <template v-if="hasNoGroups">
              <p class="gl-mb-1 gl-font-bold">{{ s__('Orbit|No top-level groups yet') }}</p>
              <p class="gl-mb-4 gl-text-subtle">
                {{ s__('Orbit|Orbit indexes top-level groups. Create a group to start.') }}
              </p>
              <gl-button size="small" :href="newGroupPath">{{ s__('Orbit|New group') }}</gl-button>
            </template>
            <template v-else>
              <p class="gl-mb-1 gl-font-bold">{{ emptyTitle }}</p>
              <p v-if="search" class="gl-mb-4 gl-text-subtle">
                {{ s__('Orbit|Check the spelling or clear the search.') }}
              </p>
              <gl-button v-if="search" size="small" @click="$emit('search', '')">
                {{ s__('Orbit|Clear search') }}
              </gl-button>
            </template>
          </div>
        </template>
      </gl-table>

      <div class="gl-flex gl-flex-wrap gl-items-start gl-justify-between gl-gap-4">
        <p class="gl-mb-0 gl-text-sm gl-text-subtle">
          {{
            s__(
              'Orbit|A group is indexed when Core, Planning, Code review, CI/CD, Source code, and Security are all indexed.',
            )
          }}
        </p>
        <gl-keyset-pagination
          v-if="showPagination"
          v-bind="pageInfo"
          :disabled="isRunning || isLoading"
          :prev-text="__('Previous')"
          :next-text="__('Next')"
          @prev="$emit('prev', $event)"
          @next="$emit('next', $event)"
        />
      </div>
    </template>
  </section>
</template>
