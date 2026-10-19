<script>
import {
  GlAnimatedChevronLgDownUpIcon,
  GlAvatar,
  GlButton,
  GlLink,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import { uniqueId } from 'lodash-es';
import { __ } from '~/locale';
import { renderGFM } from '~/behaviors/markdown/render_gfm';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import SafeHtml from '~/vue_shared/directives/safe_html';

export default {
  name: 'DescriptionPanel',
  components: {
    GlAnimatedChevronLgDownUpIcon,
    GlAvatar,
    GlButton,
    GlLink,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    SafeHtml,
  },
  props: {
    mergeRequest: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isExpanded: false,
      contentId: uniqueId('ai-overview-description-'),
    };
  },
  computed: {
    author() {
      return this.mergeRequest.author;
    },
    authorId() {
      return getIdFromGraphQLId(this.author.id);
    },
    toggleLabel() {
      return this.isExpanded ? __('Collapse') : __('Expand');
    },
  },
  mounted() {
    if (this.$refs.gfmContainer) renderGFM(this.$refs.gfmContainer);
  },
};
</script>

<template>
  <section
    class="gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-default"
  >
    <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-3 gl-px-4 gl-py-3">
      <h3 class="gl-m-0 gl-mr-auto gl-text-sm gl-font-bold">{{ __('Description') }}</h3>
      <span
        v-if="author"
        class="gl-flex gl-items-center gl-gap-2 gl-text-sm gl-text-subtle"
        data-testid="description-author"
      >
        <gl-sprintf :message="__('Created by %{author}')">
          <template #author>
            <gl-link
              :href="author.webPath"
              :data-user-id="authorId"
              :data-username="author.username"
              class="js-user-link gl-inline-flex gl-items-center gl-gap-2 !gl-text-inherit hover:!gl-text-link"
            >
              <gl-avatar :src="author.avatarUrl" :entity-name="author.name" :size="16" />
              {{ author.name }}
            </gl-link>
          </template>
        </gl-sprintf>
      </span>
      <gl-button
        v-if="mergeRequest.descriptionHtml"
        v-gl-tooltip
        :title="toggleLabel"
        :aria-label="toggleLabel"
        :aria-expanded="String(isExpanded)"
        :aria-controls="contentId"
        category="tertiary"
        size="small"
        class="btn-icon"
        data-testid="description-toggle"
        @click="isExpanded = !isExpanded"
      >
        <gl-animated-chevron-lg-down-up-icon :is-on="isExpanded" variant="default" />
      </gl-button>
    </div>
    <div
      v-if="mergeRequest.descriptionHtml"
      v-show="isExpanded"
      :id="contentId"
      class="gl-border-t-1 gl-border-t-default gl-px-4 gl-py-4 gl-border-t-solid"
    >
      <div
        ref="gfmContainer"
        v-safe-html="mergeRequest.descriptionHtml"
        class="md"
        data-testid="description-content"
      ></div>
    </div>
    <p
      v-else
      class="gl-m-0 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-sm gl-text-subtle gl-border-t-solid"
    >
      {{ __('No description') }}
    </p>
  </section>
</template>
