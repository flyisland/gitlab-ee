<script>
import { GlAlert, GlBadge, GlLoadingIcon, GlTooltipDirective as GlTooltip } from '@gitlab/ui';

import Note from 'ee/external_issues_show/components/note.vue';
import ExternalIssueAlert from 'ee/external_issues_show/components/external_issue_alert.vue';
import { fetchLigaaiIssue } from 'jh/rest_api';
import LigaaiIssueSidebar from 'jh/integrations/ligaai/issues_show/components/sidebar/ligaai_issues_sidebar_root.vue';
import { STATUS_OPEN, issuableStatusText } from '~/issues/constants';

import IssuableShow from '~/vue_shared/issuable/show/components/issuable_show_root.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { s__ } from '~/locale';

export default {
  name: 'LigaaiIssuesShow',
  components: {
    GlAlert,
    GlBadge,
    GlLoadingIcon,
    ExternalIssueAlert,
    IssuableShow,
    LigaaiIssueSidebar,
    Note,
  },
  directives: {
    GlTooltip,
  },
  inject: {
    issuesShowPath: {
      default: '',
    },
  },
  data() {
    return {
      isLoading: true,
      errorMessage: null,
      issue: {},
    };
  },
  computed: {
    isIssueOpen() {
      return this.issue.state === STATUS_OPEN;
    },
    statusBadgeText() {
      return issuableStatusText[this.issue?.state];
    },
    statusIcon() {
      return this.isIssueOpen ? 'issue-open-m' : 'mobile-issue-close';
    },
  },
  mounted() {
    this.loadIssue();
  },
  methods: {
    async loadIssue() {
      try {
        const issue = await fetchLigaaiIssue(this.issuesShowPath);
        if (!issue) {
          throw new Error(this.$options.i18n.defaultErrorMessage);
        } else {
          this.issue = convertObjectPropsToCamelCase(issue, { deep: true });
        }
      } catch {
        this.errorMessage = this.$options.i18n.defaultErrorMessage;
      } finally {
        this.isLoading = false;
      }
    },
    externalIssueCommentId(id) {
      return `external_note_${id}`;
    },
  },
  i18n: {
    defaultErrorMessage: s__(
      'JH|LigaaiIntegration|Failed to load LigaAI issue. View the issue in LigaAI, or reload the page.',
    ),
    thisIsALigaaiUser: s__('JH|LigaaiIntegration|This is a LigaAI user.'),
    ligaaiUser: s__('JH|LigaaiIntegration|LigaAI user'),
  },
};
</script>

<template>
  <div class="gl-mt-5">
    <gl-loading-icon v-if="isLoading" size="lg" />
    <gl-alert v-else-if="errorMessage" variant="danger" :dismissible="false">
      {{ errorMessage }}
    </gl-alert>
    <template v-else>
      <!-- eslint-disable local-rules/vue-no-web-url -->
      <external-issue-alert issue-tracker-name="Ligaai" :issue-url="issue.webUrl" />
      <!-- eslint-enable local-rules/vue-no-web-url -->

      <issuable-show :issuable="issue" :enable-edit="false" :status-icon="statusIcon">
        <template v-if="statusBadgeText" #status-badge>{{ statusBadgeText }}</template>

        <template #right-sidebar-items>
          <ligaai-issue-sidebar :issue="issue" />
        </template>

        <template #discussion>
          <!-- eslint-disable local-rules/vue-no-web-url -->
          <note
            v-for="comment in issue.comments"
            :id="externalIssueCommentId(comment.id)"
            :key="comment.id"
            :author-avatar-url="comment.author.avatarUrl"
            :author-web-url="comment.author.webUrl"
            :author-name="comment.author.name"
            :author-username="comment.author.username"
            :note-body-html="comment.bodyHtml"
            :note-created-at="comment.createdAt"
          >
            <!-- eslint-enable local-rules/vue-no-web-url -->
            <template #badges>
              <gl-badge v-gl-tooltip="{ title: $options.i18n.thisIsALigaaiUser }">
                {{ $options.i18n.ligaaiUser }}
              </gl-badge>
            </template>
          </note>
        </template>
      </issuable-show>
    </template>
  </div>
</template>
