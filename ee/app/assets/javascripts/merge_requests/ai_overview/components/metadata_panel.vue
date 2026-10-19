<script>
import { GlLabel, GlLink } from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { isScopedLabel } from '~/lib/utils/common_utils';
import metadataQuery from '../queries/mr_ai_overview_metadata.query.graphql';
import labelsSubscription from '../queries/mr_ai_overview_labels.subscription.graphql';
import milestoneSubscription from '../queries/mr_ai_overview_milestone.subscription.graphql';

export default {
  name: 'MetadataPanel',
  components: {
    GlLabel,
    GlLink,
  },
  inject: ['projectPath', 'iid'],
  data() {
    return {
      mergeRequest: null,
    };
  },
  // Its own query keeps labels and milestone out of the main overview query's complexity.
  apollo: {
    mergeRequest: {
      query: metadataQuery,
      variables() {
        return { projectPath: this.projectPath, iid: this.iid };
      },
      update: (data) => data?.project?.mergeRequest,
      error(error) {
        Sentry.captureException(error);
      },
      subscribeToMore: [labelsSubscription, milestoneSubscription].map((document) => ({
        document,
        skip() {
          return !this.mergeRequest?.id;
        },
        variables() {
          return { issuableId: this.mergeRequest?.id };
        },
      })),
    },
  },
  computed: {
    labels() {
      return this.mergeRequest?.labels.nodes ?? [];
    },
    milestone() {
      return this.mergeRequest?.milestone;
    },
  },
  methods: {
    isScopedLabel,
  },
};
</script>

<template>
  <section
    v-if="labels.length || milestone"
    class="gl-flex gl-flex-col gl-gap-4 gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-default gl-p-4"
  >
    <div v-if="labels.length">
      <h3 class="gl-m-0 gl-mb-3 gl-text-sm gl-font-bold">{{ __('Labels') }}</h3>
      <div class="gl-flex gl-flex-wrap gl-gap-2">
        <gl-label
          v-for="label in labels"
          :key="label.id"
          :background-color="label.color"
          :title="label.title"
          :description="label.description"
          :scoped="isScopedLabel(label)"
        />
      </div>
    </div>
    <div v-if="milestone" class="gl-flex gl-items-center gl-justify-between gl-gap-3">
      <h3 class="gl-m-0 gl-text-sm gl-font-bold">{{ __('Milestone') }}</h3>
      <gl-link :href="milestone.webPath" class="gl-text-sm" data-testid="milestone-link">
        {{ milestone.title }}
      </gl-link>
    </div>
  </section>
</template>
