<script>
import {
  GlAvatar,
  GlDisclosureDropdown,
  GlDisclosureDropdownGroup,
  GlDisclosureDropdownItem,
  GlLink,
} from '@gitlab/ui';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { getBaseURL, setUrlParams } from '~/lib/utils/url_utility';
import { __, sprintf } from '~/locale';
import toast from '~/vue_shared/plugins/global_toast';
import { DECISION_LOG_PANEL, DETAIL_VIEW_QUERY_PARAM_NAME } from '~/work_items/constants';
import { DECISION_ANCHOR_PREFIX, DECISION_SOURCE_TEXTS } from './constants';
import { decisionSource } from './utils';
import DecisionLogContext from './decision_log_context.vue';

export default {
  name: 'DecisionLogItem',
  components: {
    DecisionLogContext,
    GlAvatar,
    GlDisclosureDropdown,
    GlDisclosureDropdownGroup,
    GlDisclosureDropdownItem,
    GlLink,
    TimeAgoTooltip,
  },
  props: {
    decision: {
      type: Object,
      required: true,
    },
    workItemWebUrl: {
      type: String,
      required: true,
    },
    // The anchor the reader arrived on. The panel owns the hash and hands it to every card.
    targetAnchor: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['view-comment', 'edit', 'delete'],
  computed: {
    anchorId() {
      return `${DECISION_ANCHOR_PREFIX}${getIdFromGraphQLId(this.decision.id)}`;
    },
    isTarget() {
      return this.targetAnchor === this.anchorId;
    },
    // The link has to land somewhere the reader can see, so it points at the whole work item, with
    // the param that reopens this panel and the hash that highlights this card.
    decisionUrl() {
      const workItemUrl = new URL(this.workItemWebUrl, getBaseURL()).href;
      const panelUrl = setUrlParams(
        { [DETAIL_VIEW_QUERY_PARAM_NAME]: DECISION_LOG_PANEL },
        { url: workItemUrl, clearParams: true },
      );

      return `${panelUrl}#${this.anchorId}`;
    },
    settledOptions() {
      return (this.decision.options?.nodes || []).filter((option) => option.selected);
    },
    // A record with no settled option should not exist, because a decision is only logged once an
    // option is chosen. Should one arrive, the question it was raised for still heads the card.
    heading() {
      return this.settledOptions[0]?.content || this.decision.title;
    },
    otherSettledOptions() {
      return this.settledOptions.slice(1);
    },
    // The question already heads the card when nothing was settled, so it is not repeated below.
    questionSubhead() {
      return this.settledOptions.length ? this.decision.title : null;
    },
    hasContext() {
      return Boolean(this.decision.description || this.decision.resolutionRationale);
    },
    sourceText() {
      const message = DECISION_SOURCE_TEXTS[decisionSource(this.decision)];
      const author = this.decision.author?.name;
      // A source that names its author reads wrong without one, so the line is dropped instead.
      if (message.includes('%{author}')) {
        return author ? sprintf(message, { author }) : '';
      }

      return message;
    },
  },
  async mounted() {
    if (!this.isTarget) return;

    // The panel mounts the card, so the scroll waits for that to settle before it measures.
    await this.$nextTick();

    this.$el.scrollIntoView({ block: 'center' });
  },
  methods: {
    notifyLinkCopied() {
      toast(__('Link copied to clipboard.'));
    },
  },
};
</script>

<template>
  <li
    :id="anchorId"
    class="decision-log-item gl-mb-4 gl-list-none gl-rounded-lg gl-border-1 gl-border-solid gl-border-section gl-bg-subtle gl-p-4"
    :class="{ 'is-target': isTarget }"
    data-testid="decision-log-item"
  >
    <div class="gl-flex gl-items-start gl-justify-between gl-gap-3">
      <div v-if="heading || otherSettledOptions.length" class="gl-min-w-0">
        <!-- The decision leads the card, because that is what people scan a log for. The question
          it settled follows underneath, and is absent when the decision was marked from a
          thread. -->
        <h3 v-if="heading" class="gl-heading-4 gl-mb-1" data-testid="decision-answer">
          {{ heading }}
        </h3>

        <ul v-if="otherSettledOptions.length" class="gl-mb-1 gl-p-0">
          <li
            v-for="option in otherSettledOptions"
            :key="option.id"
            class="gl-heading-4 gl-mb-1 gl-list-none"
            data-testid="decision-answer"
          >
            {{ option.content }}
          </li>
        </ul>
      </div>

      <!-- Without the work item URL there is nothing safe to copy, so the menu stays away rather
        than handing the reader a link to the wrong page. -->
      <gl-disclosure-dropdown
        v-if="workItemWebUrl"
        icon="ellipsis_v"
        category="tertiary"
        size="small"
        placement="bottom-end"
        text-sr-only
        no-caret
        :toggle-text="s__('WorkItemDecisionLog|Decision actions')"
      >
        <gl-disclosure-dropdown-item
          :data-clipboard-text="decisionUrl"
          data-testid="copy-decision-link-action"
          @action="notifyLinkCopied"
        >
          <template #list-item>
            {{ __('Copy link') }}
          </template>
        </gl-disclosure-dropdown-item>
        <gl-disclosure-dropdown-item data-testid="edit-decision-action" @action="$emit('edit')">
          <template #list-item>
            {{ s__('WorkItemDecisionLog|Edit decision') }}
          </template>
        </gl-disclosure-dropdown-item>
        <gl-disclosure-dropdown-group bordered>
          <gl-disclosure-dropdown-item
            variant="danger"
            data-testid="remove-decision-action"
            @action="$emit('delete')"
          >
            <template #list-item>
              {{ s__('WorkItemDecisionLog|Remove decision') }}
            </template>
          </gl-disclosure-dropdown-item>
        </gl-disclosure-dropdown-group>
      </gl-disclosure-dropdown>
    </div>

    <p
      v-if="questionSubhead"
      class="gl-mb-3 gl-text-sm gl-text-subtle"
      data-testid="decision-question"
    >
      {{ questionSubhead }}
    </p>

    <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-2 gl-text-sm gl-text-subtle">
      <!-- A decision with no resolver drops the attribution rather than the whole line, because
        the time and the link still read on their own. -->

      <template v-if="decision.resolvedBy">
        <gl-avatar
          :size="16"
          :src="decision.resolvedBy.avatarUrl"
          :entity-name="decision.resolvedBy.name"
        />
        <span class="gl-font-bold gl-text-default" data-testid="decision-decided-by">
          {{ decision.resolvedBy.name }}
        </span>
      </template>
      <time-ago-tooltip v-if="decision.resolvedAt" :time="decision.resolvedAt" />
      <!-- The note lives on the page behind this panel, so the panel has to get out of the way
        for the link to land anywhere the reader can see. -->
      <gl-link
        v-if="decision.noteUrl"
        :href="decision.noteUrl"
        class="gl-text-sm"
        data-testid="decision-comment-link"
        @click="$emit('view-comment')"
      >
        {{ s__('WorkItemDecisionLog|View comment') }}
      </gl-link>
    </div>

    <p
      v-if="sourceText"
      class="gl-mb-0 gl-mt-2 gl-text-sm gl-text-subtle"
      data-testid="decision-source"
    >
      {{ sourceText }}
    </p>

    <decision-log-context
      v-if="hasContext"
      :context="decision.description"
      :rationale="decision.resolutionRationale"
    />
  </li>
</template>
