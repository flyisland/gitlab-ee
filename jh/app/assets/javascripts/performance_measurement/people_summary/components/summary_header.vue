<script>
/* eslint-disable vue/no-unused-properties */
import { GlAvatarLabeled, GlFormSelect, GlDaterangePicker, GlCollapsibleListbox } from '@gitlab/ui';
import { sprintf } from '~/locale';
import { getDateInPast } from '~/lib/utils/datetime_utility';
import { fetchBranches, fetchMembers } from '../api';
import { SUMMARY_HEADER_I18N, DATE_RANGE_PICKER_SHORTCUTS } from '../constants';
import GroupsAndProjectsListbox from './groups_and_projects_listbox.vue';

const today = new Date();

export default {
  components: {
    GlAvatarLabeled,
    GlFormSelect,
    GlDaterangePicker,
    GlCollapsibleListbox,
    GroupsAndProjectsListbox,
  },
  data() {
    return {
      selectedShortcut: 'last_30_days',
      selectedGroupsAndProjects: [],
      selectedBranches: [],
      selectedMembers: [],
      groupsAndProjects: [],
      startDate: getDateInPast(today, 30),
      endDate: today,
      branches: [],
      members: [],
      loadingStates: {
        groupsAndProjects: false,
        branches: false,
        members: false,
      },
    };
  },
  computed: {
    filters() {
      const { startDate, endDate, selectedMembers, selectedBranches, selectedGroupsAndProjects } =
        this;
      return {
        startDate,
        endDate,
        members: selectedMembers,
        branches: selectedBranches,
        groupsAndProjects: selectedGroupsAndProjects,
      };
    },
    dateRange: {
      get() {
        return {
          startDate: this.startDate,
          endDate: this.endDate,
        };
      },
      set({ startDate, endDate }) {
        this.startDate = startDate;
        this.endDate = endDate;
      },
    },
    projectSelectorToggleText() {
      if (this.loadingStates.groupsAndProjects) {
        return this.$options.i18n.placeholders.loading;
      }

      if (this.selectedGroupsAndProjects.length === 0) {
        return this.$options.i18n.placeholders.all;
      }

      return this.$options.i18n.placeholders.groupsAndProjects;
    },
    branchSelectToggleText() {
      if (this.loadingStates.branches) {
        return this.$options.i18n.placeholders.loading;
      }

      if (this.selectedBranches.length === 0) {
        return this.$options.i18n.placeholders.all;
      }

      const firstItemName = this.branches.find(
        ({ value }) => this.selectedBranches[0] === value,
      )?.text;

      return this.selectedBranches.length === 1
        ? firstItemName
        : sprintf(this.$options.i18n.multipleSelectedLabel, {
            firstSelectedName: firstItemName,
            selectedLength: this.selectedBranches.length - 1,
          });
    },
    memberSelectToggleText() {
      if (this.loadingStates.members) {
        return this.$options.i18n.placeholders.loading;
      }

      if (this.selectedMembers.length === 0) {
        return this.$options.i18n.placeholders.all;
      }

      const firstItemName = this.members.find(({ id }) => this.selectedMembers[0] === id)?.name;

      return this.selectedMembers.length === 1
        ? firstItemName
        : sprintf(this.$options.i18n.multipleSelectedLabel, {
            firstSelectedName: firstItemName,
            selectedLength: this.selectedMembers.length - 1,
          });
    },
  },
  watch: {
    selectedShortcut(val) {
      if (val !== 'custom') {
        this.endDate = today;
      }

      switch (val) {
        case 'last_7_days':
          this.startDate = getDateInPast(today, 7);
          break;
        case 'last_14_days':
          this.startDate = getDateInPast(today, 14);
          break;
        case 'last_30_days':
          this.startDate = getDateInPast(today, 30);
          break;
        case 'last_60_days':
          this.startDate = getDateInPast(today, 60);
          break;
        case 'last_90_days':
          this.startDate = getDateInPast(today, 90);
          break;
        case 'last_180_days':
          this.startDate = getDateInPast(today, 180);
          break;
        default:
          break;
      }
    },
    filters: {
      handler(val) {
        this.updateFilters(val);
      },
      deep: true,
      immediate: true,
    },
  },
  mounted() {
    this.fetchBranches();
    this.fetchMembers();
  },
  methods: {
    composeFilters() {
      return window.encodeURIComponent();
    },
    updateFilters(val) {
      this.$emit('change', val);
    },
    async fetchBranches() {
      this.loadingStates.branches = true;
      try {
        this.branches = await fetchBranches();
      } finally {
        this.loadingStates.branches = false;
      }
    },
    async fetchMembers() {
      this.loadingStates.members = true;
      try {
        this.members = await fetchMembers();
      } finally {
        this.loadingStates.members = false;
      }
    },
  },
  i18n: SUMMARY_HEADER_I18N,
  shortcuts: DATE_RANGE_PICKER_SHORTCUTS,
};
</script>

<template>
  <div
    class="gl-flex-column gl-flex gl-gap-5 gl-bg-gray-10 gl-px-5 gl-py-3 lg:gl-flex-row"
    data-testid="people-summary-header"
  >
    <div class="dropdown-container flex-column gl-flex md:gl-my-3 lg:gl-mr-5 lg:gl-flex-row">
      <gl-form-select
        v-model="selectedShortcut"
        :options="$options.shortcuts"
        label="shortcut"
        data-testid="people-summary-date-range-shortcut"
      />
    </div>
    <div class="align-items-lg-center justify-content-lg-end gl-flex gl-flex-col lg:gl-flex-row">
      <gl-daterange-picker
        v-model="dateRange"
        :default-start-date="startDate"
        :default-end-date="endDate"
        class="gl-flex gl-flex-col lg:gl-flex-row"
        start-picker-class="gl-flex gl-flex-col lg:gl-flex-row lg:gl-items-center lg:gl-mr-3 gl-mb-2 lg:gl-mb-0"
        end-picker-class="js-daterange-picker-to gl-flex gl-flex-col lg:gl-flex-row lg:gl-items-center gl-mb-2 lg:gl-mb-0"
        data-testid="people-summary-date-range-picker"
      />
    </div>
    <div class="align-items-lg-center gl-flex gl-flex-col gl-gap-3 lg:gl-flex-row">
      <div class="gl-max-w-15">
        <groups-and-projects-listbox
          v-model="selectedGroupsAndProjects"
          :placeholder="$options.i18n.titles.groupOrProject"
          is-valid
        />
      </div>
      <div class="gl-max-w-15">
        <gl-collapsible-listbox
          block
          searchable
          multiple
          data-testid="people-summary-branch-selector"
          :selected="selectedBranches"
          :items="branches"
          :header-text="$options.i18n.titles.branch"
          :toggle-text="branchSelectToggleText"
          :loading="loadingStates.branches"
          :reset-button-label="$options.i18n.resetLabel"
          @select="($event) => (selectedBranches = $event)"
        />
      </div>
      <div class="gl-max-w-15">
        <gl-collapsible-listbox
          block
          searchable
          multiple
          is-check-centered
          data-testid="people-summary-member-selector"
          :selected="selectedMembers"
          :items="members"
          :header-text="$options.i18n.titles.member"
          :toggle-text="memberSelectToggleText"
          :reset-button-label="$options.i18n.resetLabel"
          :loading="loadingStates.members"
          @select="($event) => (selectedMembers = $event)"
        >
          <template #list-item="{ item }">
            <gl-avatar-labeled
              :size="32"
              :src="item.avatar_url"
              :entity-name="item.name"
              :label="item.name"
              :sub-label="`@${item.username}`"
              class="gl-flex gl-items-center"
              shape="circle"
            />
          </template>
        </gl-collapsible-listbox>
      </div>
    </div>
  </div>
</template>
