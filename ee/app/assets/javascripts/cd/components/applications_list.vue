<script>
import { GlBadge, GlSprintf } from '@gitlab/ui';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import ProjectAvatar from '~/vue_shared/components/project_avatar.vue';
import { statusDescriptionMap, statusTextMap, statusVariantMap } from '../constants';

export default {
  name: 'ApplicationsList',
  components: {
    GlBadge,
    GlSprintf,
    ProjectAvatar,
    TimeAgo,
  },
  props: {
    applications: {
      type: Array,
      default: () => [],
      required: false,
    },
  },
  methods: {
    getBadgeDescription(status) {
      return statusDescriptionMap[status];
    },
    getBadgeText(status) {
      return statusTextMap[status];
    },
    getBadgeVariant(status) {
      return statusVariantMap[status];
    },
    applicationRoute(application) {
      return {
        name: 'applications_show_route',
        params: { id: String(getIdFromGraphQLId(application.id)) },
      };
    },
  },
};
</script>

<template>
  <!-- eslint-disable-next-line tailwindcss/no-arbitrary-value -->
  <div class="gl-mt-5 gl-grid gl-grid-cols-[repeat(auto-fill,minmax(16rem,1fr))] gl-gap-3">
    <div
      v-for="application in applications"
      :key="application.id"
      class="gl-rounded-lg gl-border-1 gl-border-solid gl-border-subtle"
      data-testid="application-card"
    >
      <div class="gl-border-b gl-flex gl-items-center gl-gap-3 gl-border-subtle gl-p-4">
        <project-avatar :project-name="application.name" :size="24" />
        <h2 class="gl-m-0 gl-truncate gl-text-base">
          <router-link
            :to="applicationRoute(application)"
            class="gl-text-default hover:gl-no-underline"
            data-testid="application-card-link"
            >{{ application.name }}</router-link
          >
        </h2>
        <gl-badge
          class="gl-ml-auto"
          icon="status_created_borderless"
          :variant="getBadgeVariant(application.status)"
        >
          {{ getBadgeText(application.status) }}
        </gl-badge>
      </div>
      <div class="gl-p-4">
        <div class="gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-purple-400">
          {{ getBadgeDescription(application.status) }}
        </div>
        <span v-if="application.updatedAt" class="gl-mt-3 gl-text-sm gl-text-secondary">
          <gl-sprintf :message="s__('ContinuousDeployment|Last deployed %{time}')">
            <template #time><time-ago :time="application.updatedAt" /></template>
          </gl-sprintf>
        </span>
      </div>
    </div>
  </div>
</template>
