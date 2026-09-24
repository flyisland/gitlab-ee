<script>
import { mapState, mapActions } from 'vuex';
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import RefSelector from '~/vue_shared/components/ref/components/ref_selector.vue';
import { REF_TYPE_BRANCHES } from '~/vue_shared/components/ref/constants';
import ProjectsDropdownFilter from '~/analytics/shared/components/projects_dropdown_filter.vue';
import DateRangeSelector from 'jh/analytics/performance_analytics/components/date_range_selector.vue';
import { PROJECTS_PER_PAGE } from '~/analytics/shared/constants'; // eslint-disable-line @jihu-fe/prefer-ee-modules
import {
  DEFAULT_SELECT_RANGE,
  BRANCH_SELECTOR_TIP,
} from 'jh/analytics/performance_analytics/constants';
import { nDaysBefore, getStartOfDay } from '~/lib/utils/datetime_utility';
import Tracking from '~/tracking';

const trackingMixin = Tracking.mixin();

export default {
  components: {
    ProjectsDropdownFilter,
    DateRangeSelector,
    RefSelector,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [trackingMixin],
  props: {
    groupId: {
      type: Number,
      required: true,
    },
    fullPath: {
      type: String,
      required: true,
    },
  },
  refTypes: [REF_TYPE_BRANCHES],
  i18n: {
    branchSelectorTip: BRANCH_SELECTOR_TIP,
  },
  data() {
    return {
      currentBranch: '',
      selectedProjects: [],
      currentDate: getStartOfDay(new Date()),
      startDate: nDaysBefore(new Date(), DEFAULT_SELECT_RANGE - 1),
      endDate: getStartOfDay(new Date()),
      projectsQueryParams: {
        first: PROJECTS_PER_PAGE,
        includeSubgroups: true,
      },
    };
  },
  computed: {
    ...mapState({
      isGroup: (state) => state.isGroup,
      branch: (state) => state.branch,
    }),
  },
  created() {
    this.currentBranch = this.branch;
    this.updatePerformanceData();
  },
  methods: {
    ...mapActions(['refreshPerformanceData']),
    onSelectProjects(projects) {
      this.track('click_dropdown', {
        label: 'switch_project',
      });

      this.selectedProjects = projects;
      this.updatePerformanceData();
    },
    onSelectBranch(currentBranch) {
      this.track('click_dropdown', {
        label: 'switch_branch',
      });

      this.currentBranch = currentBranch;
      this.updatePerformanceData();
    },
    onUpdateDate({ startDate, endDate }) {
      this.startDate = startDate;
      this.endDate = endDate;
      this.updatePerformanceData();
    },
    updatePerformanceData() {
      this.refreshPerformanceData({
        projects: this.selectedProjects,
        branch: this.currentBranch,
        startDate: this.startDate,
        endDate: this.endDate,
      });
    },
  },
};
</script>

<template>
  <div
    class="performance-value-filter gl-flex gl-flex-col gl-border-b-1 gl-border-t-1 gl-border-gray-100 gl-bg-gray-10 gl-px-5 gl-py-2 gl-border-b-solid gl-border-t-solid lg:gl-flex-row"
  >
    <projects-dropdown-filter
      v-if="isGroup"
      :key="groupId"
      class="js-projects-dropdown-filter project-select gl-mb-2 lg:gl-mb-0"
      :group-id="groupId"
      :group-namespace="fullPath"
      :query-params="projectsQueryParams"
      :multi-select="true"
      :default-projects="selectedProjects"
      data-testid="project-filter"
      @selected="onSelectProjects"
    />
    <ref-selector
      v-else
      :value="currentBranch"
      :enabled-ref-types="$options.refTypes"
      :project-id="fullPath"
      data-testid="branch-filter"
      @input="onSelectBranch"
    />
    <gl-icon
      v-if="!isGroup"
      v-gl-tooltip.hover
      name="information-o"
      :title="$options.i18n.branchSelectorTip"
      :size="16"
      class="branch-select-tooltip gl-mb-1 gl-ml-2 gl-mr-3 gl-mt-1 gl-text-gray-500"
    />
    <date-range-selector
      :current-date="currentDate"
      :start-date="startDate"
      :end-date="endDate"
      @updateDate="onUpdateDate"
    />
  </div>
</template>
