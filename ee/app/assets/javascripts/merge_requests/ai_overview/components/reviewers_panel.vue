<script>
import { GlAvatar, GlButton, GlIcon, GlLink, GlTooltipDirective } from '@gitlab/ui';
import { createAlert } from '~/alert';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import HelpPopover from '~/vue_shared/components/help_popover.vue';
import { __, sprintf } from '~/locale';
import setReviewersMutation from '~/merge_requests/components/reviewers/queries/set_reviewers.mutation.graphql';
import { buildReviewers, buildSuggestedReviewers } from '../utils';

export default {
  name: 'ReviewersPanel',
  components: {
    GlAvatar,
    GlButton,
    GlIcon,
    GlLink,
    HelpPopover,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['projectPath', 'iid'],
  props: {
    mergeRequest: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      addingUserIds: [],
    };
  },
  computed: {
    reviewers() {
      return buildReviewers(this.mergeRequest);
    },
    suggestions() {
      return buildSuggestedReviewers(this.mergeRequest);
    },
    canUpdate() {
      return Boolean(this.mergeRequest.userPermissions?.updateMergeRequest);
    },
    approvedText() {
      return sprintf(__('%{approved} of %{total} approved'), {
        approved: this.reviewers.filter((reviewer) => reviewer.mergeRequestInteraction?.approved)
          .length,
        total: this.reviewers.length,
      });
    },
  },
  methods: {
    userId(user) {
      return getIdFromGraphQLId(user.id);
    },
    addLabel(user) {
      return sprintf(__('Add %{name} as a reviewer'), { name: user.name });
    },
    async addReviewer(user) {
      this.addingUserIds = [...this.addingUserIds, user.id];

      try {
        await this.$apollo.mutate({
          mutation: setReviewersMutation,
          variables: {
            projectPath: this.projectPath,
            iid: this.iid,
            reviewerUsernames: [user.username],
            operationMode: 'APPEND',
          },
        });
      } catch (error) {
        createAlert({
          message: sprintf(__('Could not add %{name} as a reviewer. Try again later.'), {
            name: user.name,
          }),
          error,
          captureError: true,
        });
      } finally {
        this.addingUserIds = this.addingUserIds.filter((id) => id !== user.id);
      }
    },
  },
  i18n: {
    reviewers: __('Reviewers'),
    noReviewers: __('No reviewers yet'),
    recommended: __('Recommended'),
    addReviewer: __('Add reviewer'),
    reason: __('Reason for recommended reviewer'),
  },
  userLinkClasses:
    'js-user-link gl-mr-auto gl-flex gl-min-w-0 gl-items-center gl-gap-3 !gl-text-inherit hover:!gl-text-link',
};
</script>

<template>
  <section
    class="gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-default"
  >
    <div class="gl-flex gl-items-center gl-justify-between gl-px-4 gl-py-3">
      <h3 class="gl-m-0 gl-text-sm gl-font-bold">{{ $options.i18n.reviewers }}</h3>
      <span v-if="reviewers.length" class="gl-text-sm gl-text-subtle">{{ approvedText }}</span>
    </div>
    <ul v-if="reviewers.length" class="gl-m-0 gl-list-none gl-p-0">
      <li
        v-for="reviewer in reviewers"
        :key="reviewer.id"
        data-testid="reviewer-row"
        class="gl-flex gl-items-center gl-gap-3 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-border-t-solid"
      >
        <gl-link
          :href="reviewer.webPath"
          :data-user-id="userId(reviewer)"
          :data-username="reviewer.username"
          :class="$options.userLinkClasses"
        >
          <gl-avatar :src="reviewer.avatarUrl" :entity-name="reviewer.name" :size="24" />
          <span class="gl-text-sm">{{ reviewer.name }}</span>
        </gl-link>
        <span
          class="gl-inline-flex gl-items-center gl-gap-2 gl-text-sm gl-font-bold"
          :class="reviewer.textClass"
        >
          <gl-icon :name="reviewer.icon" :size="14" :variant="reviewer.variant" />
          {{ reviewer.stateLabel }}
        </span>
      </li>
    </ul>
    <p
      v-else
      class="gl-m-0 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-sm gl-text-subtle gl-border-t-solid"
    >
      {{ $options.i18n.noReviewers }}
    </p>

    <template v-if="suggestions.length">
      <h4
        class="gl-m-0 gl-flex gl-items-center gl-gap-2 gl-border-t-1 gl-border-t-default gl-bg-subtle gl-px-4 gl-py-2 gl-text-sm gl-font-bold gl-border-t-solid"
      >
        <gl-icon name="tanuki-ai" :size="14" />
        {{ $options.i18n.recommended }}
      </h4>
      <ul class="gl-m-0 gl-list-none gl-p-0">
        <li
          v-for="suggestion in suggestions"
          :key="suggestion.id"
          data-testid="suggested-reviewer-row"
          class="gl-flex gl-items-center gl-gap-3 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-border-t-solid"
        >
          <gl-link
            :href="suggestion.user.webPath"
            :data-user-id="userId(suggestion.user)"
            :data-username="suggestion.user.username"
            :class="$options.userLinkClasses"
          >
            <gl-avatar
              :src="suggestion.user.avatarUrl"
              :entity-name="suggestion.user.name"
              :size="24"
            />
            <span class="gl-min-w-0">
              <span class="gl-block gl-text-sm">{{ suggestion.user.name }}</span>
              <span v-if="suggestion.ruleName" class="gl-block gl-text-sm gl-text-subtle">
                {{ suggestion.ruleName }}
              </span>
            </span>
          </gl-link>
          <help-popover
            v-if="suggestion.reason"
            :aria-label="$options.i18n.reason"
            data-testid="suggested-reviewer-reason"
          >
            {{ suggestion.reason }}
          </help-popover>
          <gl-button
            v-if="canUpdate"
            v-gl-tooltip
            :title="$options.i18n.addReviewer"
            :aria-label="addLabel(suggestion.user)"
            :loading="addingUserIds.includes(suggestion.user.id)"
            data-testid="add-suggested-reviewer"
            icon="plus"
            size="small"
            category="tertiary"
            @click="addReviewer(suggestion.user)"
          />
        </li>
      </ul>
    </template>
  </section>
</template>
