<script>
import { GlButton, GlBadge, GlLink } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import { s__, __ } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import { formatAgentStatus, getAgentStatusBadge } from '../../utils';
import { AGENTS_PLATFORM_SHOW_ROUTE } from '../../router/constants';

const SKIP_REASONS = {
  already_present: s__('DuoAgentsPlatform|Already set up'),
  prerequisite_missing: s__('DuoAgentsPlatform|Prerequisite missing'),
};

const RETRYABLE_STATUSES = ['failed', 'stopped'];

export default {
  name: 'ProjectContextOnboardingPage',
  components: {
    GlButton,
    GlBadge,
    GlLink,
    PageHeading,
  },
  data() {
    return {
      setupPath: window.gon?.onboarding_setup_path,
      initializers: (window.gon?.onboarding_initializers || []).map((item) => ({ ...item })),
      busy: {},
    };
  },
  methods: {
    sessionUrl(workflowId) {
      if (!workflowId) return null;

      return this.$router.resolve({
        name: AGENTS_PLATFORM_SHOW_ROUTE,
        params: { id: workflowId },
      }).href;
    },
    statusVariant(status) {
      return getAgentStatusBadge(String(status).toUpperCase()).variant;
    },
    statusLabel(status) {
      return formatAgentStatus(status);
    },
    skipLabel(reason) {
      return SKIP_REASONS[reason] || s__('DuoAgentsPlatform|Skipped');
    },
    isRetryable(status) {
      return RETRYABLE_STATUSES.includes(status);
    },
    showActionButton(row) {
      return row.applicable && (!row.status || this.isRetryable(row.status));
    },
    actionLabel(row) {
      return row.status ? this.$options.i18n.retry : this.$options.i18n.run;
    },
    async run(eventType) {
      if (!this.setupPath) {
        createAlert({ message: s__('DuoAgentsPlatform|Onboarding setup path not configured.') });
        return;
      }

      this.busy = { ...this.busy, [eventType]: true };

      try {
        const { data } = await axios.post(this.setupPath, { event_type: eventType });
        const row = this.initializers.find((item) => item.event_type === eventType);

        if (row) {
          row.status = 'created';
          row.workflow_id = data?.workflow_id;
        }
      } catch (error) {
        createAlert({
          message:
            error.response?.data?.message ||
            s__('DuoAgentsPlatform|Something went wrong while running the initializer.'),
          captureError: true,
          error,
        });
      } finally {
        this.busy = { ...this.busy, [eventType]: false };
      }
    },
  },
  i18n: {
    run: s__('DuoAgentsPlatform|Run'),
    retry: __('Retry'),
    viewSession: s__('DuoAgentsPlatform|View session'),
  },
};
</script>
<template>
  <div>
    <page-heading>
      <template #heading>
        {{ s__('DuoAgentsPlatform|Set up your project for GitLab Duo Agent Platform') }}
      </template>
      <template #description>
        {{
          s__(
            'DuoAgentsPlatform|Run the available initializers to prepare this repository for GitLab Duo Agent Platform. Each one opens a draft merge request you can review.',
          )
        }}
      </template>
    </page-heading>

    <ul class="gl-mt-5 gl-list-none gl-p-0">
      <li
        v-for="row in initializers"
        :key="row.event_type"
        class="gl-border-b gl-flex gl-items-start gl-justify-between gl-py-4"
        :data-testid="`initializer-row-${row.event_type}`"
      >
        <div class="gl-pr-5">
          <h3 class="gl-heading-4 gl-mb-1">{{ row.display_name }}</h3>
          <p class="gl-mb-2 gl-text-subtle">{{ row.description }}</p>
          <code class="gl-text-sm">{{ row.target_file }}</code>
        </div>

        <div class="gl-flex gl-items-center gl-gap-3 gl-whitespace-nowrap">
          <gl-badge v-if="!row.applicable" variant="neutral" data-testid="skipped-badge">
            {{ skipLabel(row.skipped_reason) }}
          </gl-badge>

          <template v-else>
            <gl-badge
              v-if="row.status"
              :variant="statusVariant(row.status)"
              data-testid="status-badge"
            >
              {{ statusLabel(row.status) }}
            </gl-badge>
            <gl-link
              v-if="row.workflow_id"
              :href="sessionUrl(row.workflow_id)"
              data-testid="session-link"
            >
              {{ $options.i18n.viewSession }}
            </gl-link>
            <gl-button
              v-if="showActionButton(row)"
              variant="confirm"
              size="small"
              :loading="busy[row.event_type]"
              data-testid="action-button"
              @click="run(row.event_type)"
            >
              {{ actionLabel(row) }}
            </gl-button>
          </template>
        </div>
      </li>
    </ul>
  </div>
</template>
