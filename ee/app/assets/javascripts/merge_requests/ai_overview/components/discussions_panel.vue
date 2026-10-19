<script>
import { GlBadge, GlButton, GlIcon, GlLoadingIcon, GlSegmentedControl } from '@gitlab/ui';
import { produce } from 'immer';
import Api from '~/api';
import { __, sprintf } from '~/locale';
import { createAlert } from '~/alert';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { joinPaths } from '~/lib/utils/url_utility';
import { withLinkedFileUrlParams } from '~/rapid_diffs/utils/linked_file';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import discussionsQuery from '../queries/mr_ai_overview_discussions.query.graphql';
import createNoteMutation from '../queries/mr_ai_overview_create_note.mutation.graphql';
import toggleResolveMutation from '../queries/mr_ai_overview_toggle_resolve.mutation.graphql';
import ConversationForm from './conversation_form.vue';
import ConversationNote from './conversation_note.vue';

const DIFF_REFS = ['baseSha', 'startSha', 'headSha'];
const NEW_COMMENT = Symbol('newComment');

// The design's snippet is a few lines: the suggested change, or else the lines the comment is on.
const SNIPPET_MAX_LINES = 6;
const SNIPPET_CONTEXT_LINES = 3;
// The same line backgrounds as a suggestion diff; the theme class on the snippet scopes the variables.
const SNIPPET_LINE_TYPES = {
  old: { sign: '-', classes: 'gl-bg-[var(--code-old-diff-background-color)]' },
  new: { sign: '+', classes: 'gl-bg-[var(--code-new-diff-background-color)]' },
  context: { sign: ' ', classes: 'gl-text-subtle' },
};

const contentLines = (content, type) =>
  content
    .replace(/\n$/, '')
    .split('\n')
    .map((text) => ({ type, text }));

const FILTERS = {
  all: () => true,
  action: (discussion) => discussion.isUnresolved,
  people: (discussion) => !discussion.isAgent,
  agents: (discussion) => discussion.isAgent,
};

export default {
  name: 'DiscussionsPanel',
  NEW_COMMENT,
  components: {
    ConversationForm,
    ConversationNote,
    GlBadge,
    GlButton,
    GlIcon,
    GlLoadingIcon,
    GlSegmentedControl,
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
      connection: null,
      hasError: false,
      isLoadingMore: false,
      filter: null,
      replyingTo: null,
      isCommenting: false,
      submittingTo: null,
      resolvingIds: [],
      applyingIds: [],
    };
  },
  apollo: {
    connection: {
      query: discussionsQuery,
      variables() {
        return { projectPath: this.projectPath, iid: this.iid };
      },
      update: (data) => data?.project?.mergeRequest?.discussionsWithActivity,
      error(error) {
        this.hasError = true;
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    isInitialLoading() {
      return this.$apollo.queries.connection.loading && !this.connection;
    },
    canCreateNote() {
      return this.mergeRequest.userPermissions.createNote;
    },
    canApplySuggestions() {
      return this.mergeRequest.userPermissions.pushToSourceBranch;
    },
    reviewerIds() {
      return this.mergeRequest.reviewers?.nodes.map(({ id }) => id) ?? [];
    },
    discussions() {
      return (this.connection?.nodes ?? [])
        .map((discussion) => this.buildDiscussion(discussion))
        .filter(Boolean);
    },
    openCount() {
      return this.discussions.filter(FILTERS.action).length;
    },
    // Opens on Needs action, unless nothing needs action, in which case the card would be empty.
    activeFilter: {
      get() {
        return this.filter ?? (this.openCount ? 'action' : 'all');
      },
      set(filter) {
        this.filter = filter;
      },
    },
    filteredDiscussions() {
      return this.discussions.filter(FILTERS[this.activeFilter]);
    },
    openText() {
      return sprintf(__('%{count} open'), { count: this.openCount });
    },
  },
  methods: {
    buildDiscussion({
      id,
      replyId,
      resolvable,
      resolved,
      userPermissions,
      truncatedDiffLines,
      notes,
    }) {
      const [note, ...replies] = notes.nodes;
      if (!note) return null;

      const canResolve = userPermissions.resolveNote;
      const isUnresolved = resolvable && !resolved;
      const suggestions = note.suggestions?.nodes ?? [];
      const pendingSuggestionIds = suggestions
        .filter((suggestion) => !suggestion.applied)
        .map((suggestion) => suggestion.id);
      const location = this.diffLocation(note);

      return {
        id,
        replyId,
        note,
        role: this.roleFor(note.author),
        replies: replies.map((reply) => ({ note: reply, role: this.roleFor(reply.author) })),
        resolved,
        canResolve,
        isUnresolved,
        hasActions: isUnresolved && (this.canCreateNote || canResolve),
        canReopen: resolved && canResolve,
        isResolving: this.resolvingIds.includes(id),
        isApplying: this.applyingIds.includes(id),
        isAgent: Boolean(note.author?.bot),
        snippet: this.snippet(suggestions, truncatedDiffLines),
        pendingSuggestionIds,
        // A suggestion on an older diff no longer matches the code, so it cannot be applied.
        canApply:
          this.canApplySuggestions &&
          isUnresolved &&
          !location.isOutdated &&
          pendingSuggestionIds.length > 0,
        ...location,
      };
    },
    snippet(suggestions, diffLines) {
      const lines = suggestions.length
        ? suggestions.flatMap(({ fromContent, toContent }) => [
            ...contentLines(fromContent, 'old'),
            ...contentLines(toContent, 'new'),
          ])
        : (diffLines ?? [])
            .filter(({ type }) => type === null || type === 'old' || type === 'new')
            .slice(-SNIPPET_CONTEXT_LINES)
            // The diff line's text starts with its own +, - or space.
            .map(({ type, text }) => ({ type: type ?? 'context', text: text.slice(1) }));

      return lines.slice(0, SNIPPET_MAX_LINES).map((line) => ({
        ...line,
        ...SNIPPET_LINE_TYPES[line.type],
      }));
    },
    // The new overview replaces the classic thread list, so a diff thread links to its
    // place on the Changes tab rather than to the note's anchor on this page.
    diffLocation({ id, position }) {
      if (!position) return {};

      const line = position.newLine ?? position.oldLine;
      const location = line ? `${position.filePath}:${line}` : position.filePath;

      // Same test as DiffNote#active?: a thread on an older diff is not on the Changes tab.
      const isOutdated = DIFF_REFS.some(
        (ref) => position.diffRefs[ref] !== this.mergeRequest.diffRefs?.[ref],
      );
      if (isOutdated) return { location, isOutdated };

      return {
        location,
        diffHref: withLinkedFileUrlParams(joinPaths(this.mergeRequest.webPath, 'diffs'), {
          oldPath: position.oldPath,
          newPath: position.newPath,
          hash: `note_${getIdFromGraphQLId(id)}`,
        }).toString(),
      };
    },
    roleFor(author) {
      if (!author) return null;
      if (author.bot) return { text: __('Agent'), variant: 'tier' };
      if (author.id === this.mergeRequest.author?.id) {
        return { text: __('Author'), variant: 'info' };
      }
      if (this.reviewerIds.includes(author.id)) return { text: __('Reviewer'), variant: 'info' };

      return { text: __('Human'), variant: 'info' };
    },
    async loadMore() {
      this.isLoadingMore = true;
      try {
        await this.$apollo.queries.connection.fetchMore({
          variables: { after: this.connection.pageInfo.endCursor },
          updateQuery: (previous, { fetchMoreResult }) =>
            produce(fetchMoreResult, (draft) => {
              draft.project.mergeRequest.discussionsWithActivity.nodes.unshift(
                ...previous.project.mergeRequest.discussionsWithActivity.nodes,
              );
            }),
        });
      } catch (error) {
        createAlert({ message: this.$options.i18n.loadError, captureError: true, error });
      } finally {
        this.isLoadingMore = false;
      }
    },
    async toggleResolve({ id, resolved }) {
      this.resolvingIds = [...this.resolvingIds, id];
      try {
        const { data } = await this.$apollo.mutate({
          mutation: toggleResolveMutation,
          variables: { id, resolve: !resolved },
        });
        const [message] = data.discussionToggleResolve.errors;
        if (message) throw new Error(message);
      } catch (error) {
        createAlert({ message: this.$options.i18n.resolveError, captureError: true, error });
      } finally {
        this.resolvingIds = this.resolvingIds.filter((resolvingId) => resolvingId !== id);
      }
    },
    async createNote({ body, discussionId }) {
      this.submittingTo = discussionId ?? NEW_COMMENT;
      try {
        const { data } = await this.$apollo.mutate({
          mutation: createNoteMutation,
          variables: { input: { noteableId: this.mergeRequest.id, body, discussionId } },
          update: (cache, { data: { createNote } }) => this.addToCache(cache, createNote),
        });
        const [message] = data.createNote.errors;
        if (message) throw new Error(message);

        if (discussionId) this.replyingTo = null;
        else this.isCommenting = false;
      } catch (error) {
        createAlert({ message: this.$options.i18n.commentError, captureError: true, error });
      } finally {
        this.submittingTo = null;
      }
    },
    // A new thread belongs after pages that are not loaded yet, so only then is the list fetched again.
    addToCache(cache, { note }) {
      if (!note) return;

      const { discussion } = note;
      const variables = { projectPath: this.projectPath, iid: this.iid };
      const previous = cache.readQuery({ query: discussionsQuery, variables });
      const { nodes, pageInfo } = previous.project.mergeRequest.discussionsWithActivity;
      const index = nodes.findIndex(({ id }) => id === discussion.id);

      if (index === -1 && pageInfo.hasNextPage) {
        this.$apollo.queries.connection.refetch();
        return;
      }

      const data = produce(previous, (draft) => {
        const list = draft.project.mergeRequest.discussionsWithActivity.nodes;
        if (index === -1) list.push(discussion);
        else list[index] = discussion;
      });
      cache.writeQuery({ query: discussionsQuery, variables, data });
    },
    // As in the classic thread list: apply the suggestions, then resolve the thread they came from.
    async applySuggestions(discussion) {
      this.applyingIds = [...this.applyingIds, discussion.id];
      try {
        const ids = discussion.pendingSuggestionIds.map(getIdFromGraphQLId);
        await (ids.length === 1 ? Api.applySuggestion(ids[0]) : Api.applySuggestionBatch(ids));

        if (discussion.canResolve) {
          await this.$apollo
            .mutate({
              mutation: toggleResolveMutation,
              variables: { id: discussion.id, resolve: true },
            })
            .catch(() => {});
        }
        await this.$apollo.queries.connection.refetch();
      } catch (error) {
        createAlert({
          message: error.response?.data?.message || this.$options.i18n.applyError,
          captureError: true,
          error,
        });
      } finally {
        this.applyingIds = this.applyingIds.filter((applyingId) => applyingId !== discussion.id);
      }
    },
  },
  filterOptions: [
    { value: 'action', text: __('Needs action'), props: { size: 'small' } },
    { value: 'people', text: __('People'), props: { size: 'small' } },
    { value: 'agents', text: __('Agents'), props: { size: 'small' } },
    { value: 'all', text: __('All'), props: { size: 'small' } },
  ],
  i18n: {
    loadError: __('Could not load conversations.'),
    resolveError: __('Could not update the thread.'),
    commentError: __('Could not post your comment.'),
    applyError: __('Something went wrong while applying the suggestion. Please try again.'),
  },
};
</script>

<template>
  <section
    class="gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-default"
  >
    <div class="gl-flex gl-flex-col gl-gap-3 gl-px-4 gl-py-3">
      <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-3">
        <h3 class="gl-m-0 gl-text-sm gl-font-bold">{{ __('Conversations') }}</h3>
        <gl-badge v-if="openCount" variant="danger" data-testid="conversations-open-count">
          {{ openText }}
        </gl-badge>
        <gl-segmented-control
          v-if="discussions.length"
          v-model="activeFilter"
          :options="$options.filterOptions"
          :aria-label="__('Filter conversations')"
          class="gl-ml-auto"
          data-testid="conversations-filter"
        />
      </div>
      <div
        v-if="discussions.length"
        class="gl-flex gl-flex-wrap gl-items-center gl-gap-4 gl-text-sm gl-text-subtle"
        data-testid="conversations-legend"
      >
        <span class="gl-inline-flex gl-items-center gl-gap-2">
          <span
            class="gl-h-3 gl-w-3 gl-rounded-sm gl-bg-current gl-text-status-info"
            aria-hidden="true"
          ></span>
          {{ __('Human') }}
        </span>
        <span class="gl-inline-flex gl-items-center gl-gap-2">
          <span
            class="gl-h-3 gl-w-3 gl-rounded-sm gl-bg-current gl-text-status-brand"
            aria-hidden="true"
          ></span>
          {{ __('Agent') }}
        </span>
      </div>
    </div>

    <p
      v-if="hasError"
      class="gl-m-0 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-sm gl-text-danger gl-border-t-solid"
    >
      {{ $options.i18n.loadError }}
    </p>
    <div
      v-else-if="isInitialLoading"
      class="gl-border-t-1 gl-border-t-default gl-px-4 gl-py-4 gl-border-t-solid"
    >
      <gl-loading-icon />
    </div>
    <ul v-else-if="filteredDiscussions.length" class="gl-m-0 gl-list-none gl-p-0">
      <li
        v-for="discussion in filteredDiscussions"
        :key="discussion.id"
        class="gl-relative gl-flex gl-flex-col gl-gap-3 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-sm gl-border-t-solid"
        :class="{ 'gl-opacity-7': discussion.resolved }"
        data-testid="conversation-row"
      >
        <span
          class="gl-absolute gl-bottom-0 gl-left-0 gl-top-0 gl-w-2 gl-bg-current"
          :class="discussion.isAgent ? 'gl-text-status-brand' : 'gl-text-status-info'"
          aria-hidden="true"
          data-testid="conversation-origin"
        ></span>
        <conversation-note :note="discussion.note" :role="discussion.role">
          <template #badges>
            <gl-badge
              v-if="discussion.isUnresolved"
              variant="danger"
              data-testid="conversation-state"
            >
              <span class="gl-inline-flex gl-items-center gl-gap-2">
                <span class="gl-h-3 gl-w-3 gl-rounded-full gl-bg-current" aria-hidden="true"></span>
                {{ __('Unresolved') }}
              </span>
            </gl-badge>
            <gl-badge
              v-else-if="discussion.resolved"
              variant="success"
              icon="check-circle-filled"
              data-testid="conversation-state"
            >
              {{ __('Resolved') }}
            </gl-badge>
            <gl-badge v-else variant="neutral" data-testid="conversation-state">
              {{ __('Comment') }}
            </gl-badge>
          </template>

          <gl-badge
            v-if="discussion.diffHref"
            :href="discussion.diffHref"
            icon="doc-code"
            icon-size="sm"
            class="gl-self-start gl-font-monospace"
            data-testid="conversation-location"
          >
            {{ discussion.location }}
          </gl-badge>
          <div
            v-else-if="discussion.isOutdated"
            class="gl-flex gl-flex-wrap gl-items-center gl-gap-2"
            data-testid="conversation-location"
          >
            <gl-badge icon="doc-code" icon-size="sm" class="gl-font-monospace gl-text-subtle">
              {{ discussion.location }}
            </gl-badge>
            <gl-badge>{{ __('Outdated') }}</gl-badge>
          </div>
          <div
            v-if="discussion.snippet.length"
            class="code-syntax-highlight-theme gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-font-monospace"
            data-testid="conversation-snippet"
          >
            <div
              v-for="(line, index) in discussion.snippet"
              :key="index"
              class="gl-flex gl-px-3"
              :class="line.classes"
            >
              <span class="gl-w-5 gl-shrink-0" aria-hidden="true">{{ line.sign }}</span>
              <span class="gl-truncate gl-whitespace-pre">{{ line.text }}</span>
            </div>
          </div>
        </conversation-note>

        <div
          v-if="discussion.canApply"
          class="gl-flex gl-items-center gl-justify-between gl-gap-3 gl-rounded-lg gl-bg-status-info gl-px-3 gl-py-2"
          data-testid="conversation-suggestion"
        >
          <span class="gl-inline-flex gl-items-center gl-gap-2 gl-font-bold gl-text-status-info">
            <gl-icon name="doc-changes" :size="14" />
            {{ __('Suggested change ready') }}
          </span>
          <gl-button
            size="small"
            variant="confirm"
            category="secondary"
            :loading="discussion.isApplying"
            data-testid="conversation-apply"
            @click="applySuggestions(discussion)"
          >
            {{ __('Apply') }}
          </gl-button>
        </div>

        <ul
          v-if="discussion.replies.length"
          class="gl-m-0 gl-flex gl-list-none gl-flex-col gl-gap-3 gl-border-l-2 gl-border-l-default gl-p-0 gl-pl-4 gl-border-l-solid"
          data-testid="conversation-replies"
        >
          <li v-for="reply in discussion.replies" :key="reply.note.id">
            <conversation-note :note="reply.note" :role="reply.role" compact />
          </li>
        </ul>

        <conversation-form
          v-if="replyingTo === discussion.id"
          :placeholder="__('Reply…')"
          :submit-text="__('Reply')"
          :loading="submittingTo === discussion.replyId"
          @submit="createNote({ body: $event, discussionId: discussion.replyId })"
          @cancel="replyingTo = null"
        />
        <div v-else-if="discussion.hasActions" class="gl-flex gl-flex-wrap gl-gap-2">
          <gl-button
            v-if="canCreateNote"
            size="small"
            category="tertiary"
            icon="comment"
            data-testid="conversation-reply"
            @click="replyingTo = discussion.id"
          >
            {{ __('Reply') }}
          </gl-button>
          <gl-button
            v-if="discussion.canResolve"
            size="small"
            category="tertiary"
            icon="check"
            :loading="discussion.isResolving"
            data-testid="conversation-resolve"
            @click="toggleResolve(discussion)"
          >
            {{ __('Resolve') }}
          </gl-button>
        </div>
        <div v-else-if="discussion.canReopen">
          <gl-button
            size="small"
            category="tertiary"
            icon="redo"
            :loading="discussion.isResolving"
            data-testid="conversation-reopen"
            @click="toggleResolve(discussion)"
          >
            {{ __('Reopen thread') }}
          </gl-button>
        </div>
      </li>
    </ul>
    <p
      v-else
      class="gl-m-0 gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-sm gl-text-subtle gl-border-t-solid"
    >
      {{ __('No conversations to show.') }}
    </p>

    <div
      v-if="!hasError && connection && connection.pageInfo.hasNextPage"
      class="gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-center gl-border-t-solid"
    >
      <gl-button
        size="small"
        :loading="isLoadingMore"
        data-testid="conversations-load-more"
        @click="loadMore"
      >
        {{ __('Load more') }}
      </gl-button>
    </div>

    <div
      v-if="canCreateNote"
      class="gl-border-t-1 gl-border-t-default gl-px-4 gl-py-3 gl-text-sm gl-border-t-solid"
    >
      <conversation-form
        v-if="isCommenting"
        :placeholder="__('Write a comment…')"
        :submit-text="__('Comment')"
        :loading="submittingTo === $options.NEW_COMMENT"
        @submit="createNote({ body: $event })"
        @cancel="isCommenting = false"
      />
      <gl-button
        v-else
        size="small"
        category="tertiary"
        icon="comment"
        data-testid="conversations-add-comment"
        @click="isCommenting = true"
      >
        {{ __('Add a comment') }}
      </gl-button>
    </div>
  </section>
</template>
