<script>
import SafeHtml from '~/vue_shared/directives/safe_html';
import EventItem from 'ee/vue_shared/security_reports/components/event_item.vue';
import HistoryComment from './history_comment.vue';

export default {
  components: {
    EventItem,
    HistoryComment,
  },
  directives: {
    SafeHtml,
  },
  props: {
    discussion: {
      type: Object,
      required: true,
    },
    /*
     * Displays the entry as a feed item with dividers instead of a bordered card.
     */
    borderless: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    notes() {
      return this.discussion.notes;
    },
    systemNote() {
      return this.notes.find((x) => x.system === true);
    },
    comments() {
      return this.notes.filter((x) => x !== this.systemNote);
    },
    rootClass() {
      return this.borderless
        ? 'system-note gl-border-b gl-border-subtle gl-p-0 last:gl-border-b-0'
        : 'card system-note gl-border-b gl-p-0';
    },
  },
  // Remove paragraph tags so that markdown can be displayed inline.
  safeHtmlConfig: { FORBID_TAGS: ['p'] },
};
</script>

<template>
  <div v-if="systemNote" :class="rootClass">
    <event-item
      :id="systemNote.id"
      :author="systemNote.author"
      :created-at="systemNote.createdAt"
      :icon-name="systemNote.systemNoteIconName"
      is-system-note
      icon-class="timeline-icon"
      class="gl-m-5"
    >
      <template #header-message>
        <span v-safe-html:[$options.safeHtmlConfig]="systemNote.bodyHtml" class="md"></span>
      </template>
    </event-item>
    <history-comment
      v-for="comment in comments"
      :key="comment.id"
      :comment="comment"
      :discussion-id="discussion.replyId"
      data-testid="existing-comment"
      v-on="$listeners"
    />
    <history-comment
      v-if="!comments.length"
      :discussion-id="discussion.replyId"
      data-testid="new-comment"
      v-on="$listeners"
    />
  </div>
</template>
