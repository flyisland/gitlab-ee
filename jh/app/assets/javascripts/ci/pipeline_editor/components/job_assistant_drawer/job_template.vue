<script>
import { GlSkeletonLoader, GlIcon, GlButton, GlEmptyState } from '@gitlab/ui';
import { i18n, HELP_PATHS, EMPTY_STATE_SVG_PATH } from './constants';

export default {
  i18n,
  HELP_PATHS,
  EMPTY_STATE_SVG_PATH,
  components: {
    GlSkeletonLoader,
    GlIcon,
    GlButton,
    GlEmptyState,
  },
  props: {
    jobTemplateList: {
      required: true,
      type: Array,
    },
    loading: {
      required: true,
      type: Boolean,
    },
  },
};
</script>
<template>
  <div>
    <template v-if="!loading && jobTemplateList.length === 0">
      <gl-empty-state
        :description="$options.i18n.EMPTY_STATE_DESCRIPTION"
        :svg-path="$options.EMPTY_STATE_SVG_PATH"
        :svg-height="72"
      >
        <template #title>
          <h4 class="gl-mb-5 gl-mt-0">{{ $options.i18n.GETTING_STARTED_WITH_JOB_TEMPLATE }}</h4>
        </template>
        <template #actions>
          <div class="gl-w-100p gl-mb-5 gl-shrink-0 gl-basis-full">
            <gl-button
              class="!gl-m-0"
              category="primary"
              variant="confirm"
              data-testid="create-new-template-button"
              @click="$emit('hide')"
              >{{ $options.i18n.CREATE_NEW_TEMPLATE }}
            </gl-button>
          </div>
          <gl-button class="!gl-m-0" :href="$options.HELP_PATHS.jobHelpPath" target="_blank">{{
            $options.i18n.LEARN_MORE
          }}</gl-button>
        </template>
      </gl-empty-state>
    </template>
    <template v-else>
      <div
        class="gl-mb-5 gl-flex gl-cursor-pointer gl-items-center gl-rounded-base gl-bg-gray-10 !gl-px-5 !gl-py-4 gl-transition-all hover:gl-bg-gray-50"
        data-testid="create-blank-template-button"
        @click="$emit('hide')"
      >
        <gl-icon name="plus" />
        <div class="gl-pl-4">
          <div class="gl-pb-2">{{ $options.i18n.BLANK_TEMPLATE }}</div>
          <div class="gl-text-gray-500">{{ $options.i18n.DESCRIPTION }}</div>
        </div>
      </div>
      <div class="gl-border-t gl-pb-5 gl-pt-5 gl-font-bold">
        {{ $options.i18n.JOB_TEMPLATE }}
      </div>

      <template v-if="loading">
        <gl-skeleton-loader v-for="i in 3" :key="i" :height="40">
          <rect x="8" y="8" width="40" height="8" rx="4" ry="4" />
          <rect x="8" y="20" width="392" height="8" rx="4" ry="4" />
        </gl-skeleton-loader>
      </template>
      <template v-if="!loading && jobTemplateList.length > 0">
        <gl-button
          v-for="jobTemplate in jobTemplateList"
          :key="jobTemplate.name"
          class="gl-mb-5 gl-w-full !gl-justify-start !gl-px-5 !gl-py-4 gl-text-left"
        >
          <div class="gl-pb-2 gl-font-bold">{{ jobTemplate.name }}</div>
          <div class="gl-text-gray-500">{{ jobTemplate.description }}</div>
        </gl-button>
      </template>
    </template>
  </div>
</template>
