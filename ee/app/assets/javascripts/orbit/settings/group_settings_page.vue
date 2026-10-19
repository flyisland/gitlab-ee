<script>
import { GlAlert, GlIcon, GlSkeletonLoader, GlToggle } from '@gitlab/ui';
import { createAlert } from '~/alert';
import { ERROR_POLICY_ALL } from '~/lib/graphql';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { s__, sprintf } from '~/locale';
import { InternalEvents } from '~/tracking';
import groupSettingsQuery from '../graphql/queries/group_settings.query.graphql';
import orbitStartTrialMutation from '../graphql/mutations/orbit_start_trial.mutation.graphql';
import orbitUpdateMutation from '../graphql/mutations/orbit_update.mutation.graphql';
import { isOrbitReady, isIndexingQueued } from '../utils/orbit_group_state';
import StartTrialModal from '../components/trial/start_trial_modal.vue';
import GroupSettingsAlert from './group_settings_alert.vue';
import { ACCESS_STATE, ACCESS_REASON, PAGE_STATE } from './constants';

const INDEXING_POLL_INTERVAL = 15000;

const toggleErrorTitle = (enabled) =>
  enabled ? s__('Orbit|Could not turn on Orbit') : s__('Orbit|Could not turn off Orbit');

export default {
  name: 'OrbitGroupSettingsPage',
  components: {
    GlAlert,
    GlIcon,
    GlSkeletonLoader,
    GlToggle,
    GroupSettingsAlert,
    StartTrialModal,
  },
  mixins: [InternalEvents.mixin()],
  props: {
    groupFullPath: { type: String, required: true },
    saas: { type: Boolean, required: true },
    duoAvailable: { type: Boolean, required: true },
    orbitPath: { type: String, required: true },
    usageQuotasPath: { type: String, required: true },
    duoSettingsPath: { type: String, required: true },
  },
  apollo: {
    group: {
      query: groupSettingsQuery,
      variables() {
        return { fullPath: this.groupFullPath };
      },
      // The indexing status comes from the Orbit service. When it fails, still show the
      // group, so the Owner can turn Orbit off.
      errorPolicy: ERROR_POLICY_ALL,
      result({ data, error, errors }) {
        if (!data?.group) {
          if (error || errors?.length) {
            createAlert({
              message: s__('Orbit|Failed to load group. Please try again.'),
              error: error ?? errors[0],
              captureError: true,
            });
          }
          return;
        }

        this.statusUnavailable = Boolean(errors?.length);
        this.updatePolling();
      },
      // `result` handles errors, because it also gets the partial data. Without this hook,
      // vue-apollo logs every error to the console.
      error() {},
    },
  },
  data() {
    return {
      group: null,
      startTrialModalVisible: false,
      startingTrial: false,
      togglingOrbit: false,
      actionError: null,
      statusUnavailable: false,
    };
  },
  computed: {
    accessState() {
      return this.group.orbitAccess.state;
    },
    blockedAlert() {
      const { reason } = this.group.orbitAccess;

      switch (this.accessState) {
        case ACCESS_STATE.NOT_CONFIGURED:
          return PAGE_STATE.UNLICENSED;
        case ACCESS_STATE.UNLICENSED:
          return reason === ACCESS_REASON.FREE_PLAN ? PAGE_STATE.FREE_PLAN : PAGE_STATE.UNLICENSED;
        case ACCESS_STATE.TRIAL_STATUS_UNAVAILABLE:
          return PAGE_STATE.CDOT_UNAVAILABLE;
        case ACCESS_STATE.TRIAL_NOT_ELIGIBLE:
          return PAGE_STATE.NOT_ELIGIBLE;
        case ACCESS_STATE.TRIAL_ENDED:
          return reason === ACCESS_REASON.CREDITS_EXHAUSTED
            ? PAGE_STATE.CREDITS_USED_UP
            : PAGE_STATE.TRIAL_ENDED;
        default:
          return null;
      }
    },
    isBlocked() {
      return Boolean(this.blockedAlert);
    },
    showActionError() {
      return (
        Boolean(this.actionError) && this.accessState !== ACCESS_STATE.TRIAL_STATUS_UNAVAILABLE
      );
    },
    isEligible() {
      return this.accessState === ACCESS_STATE.TRIAL_ELIGIBLE && !this.group.knowledgeGraphEnabled;
    },
    // A blocked group can still be on (the end-of-trial worker runs hourly), so the Owner can still turn it off.
    showToggle() {
      return !this.isBlocked || this.group.knowledgeGraphEnabled;
    },
    trialBannerText() {
      return sprintf(
        s__(
          'Orbit|By turning on Orbit today, %{groupName} automatically gets 100 free GitLab credits for Orbit, valid for 30 days. When they run out or the 30 days end, contact sales to keep using Orbit.',
        ),
        { groupName: this.group.name },
      );
    },
    isTrialActive() {
      return this.accessState === ACCESS_STATE.TRIAL_ACTIVE;
    },
    showTrialBanner() {
      return this.isEligible || this.isTrialActive;
    },
    isReady() {
      return isOrbitReady(this.group);
    },
    showDuoAlert() {
      return this.group.knowledgeGraphEnabled && !this.duoAvailable;
    },
    statusAlertButtonText() {
      return this.isReady ? s__('Orbit|Go to Orbit') : '';
    },
    statusAlertTitle() {
      if (this.statusUnavailable)
        return s__('Orbit|Orbit status is not available. Try again later.');

      const message = this.isReady
        ? s__('Orbit|Orbit is ready for %{groupName}')
        : s__('Orbit|Orbit is indexing %{groupName}');
      return sprintf(message, { groupName: this.group.name });
    },
  },
  beforeDestroy() {
    this.$apollo.queries.group.stopPolling();
  },
  methods: {
    updatePolling() {
      const indexing = this.group.knowledgeGraphEnabled && !this.isReady;

      if (indexing && !isIndexingQueued(this.group)) {
        this.$apollo.queries.group.startPolling(INDEXING_POLL_INTERVAL);
      } else {
        this.$apollo.queries.group.stopPolling();
      }
    },
    onToggleChange(enabled) {
      if (this.isEligible) {
        this.startTrialModalVisible = true;
        return;
      }

      this.setOrbitEnabled(enabled);
    },
    async startTrial() {
      this.startingTrial = true;
      this.actionError = null;

      try {
        const { data } = await this.$apollo.mutate({
          mutation: orbitStartTrialMutation,
          variables: { groupPath: this.groupFullPath },
        });
        const [message] = data.orbitStartTrial.errors;
        if (message)
          this.actionError = { title: s__('Orbit|Could not start your free trial'), message };
      } catch (error) {
        this.actionError = {
          title: s__('Orbit|Could not start your free trial'),
          message: error.message,
        };
        Sentry.captureException(error);
      } finally {
        this.startTrialModalVisible = false;
        this.startingTrial = false;
        await this.$apollo.queries.group.refetch();
      }
    },
    async setOrbitEnabled(enabled) {
      this.togglingOrbit = true;
      this.actionError = null;
      if (!enabled) this.trackEvent('click_orbit_turn_off_indexing');

      try {
        const { data } = await this.$apollo.mutate({
          mutation: orbitUpdateMutation,
          variables: { input: { groupPath: this.groupFullPath, enabled } },
        });
        const [message] = data.orbitUpdate.errors;
        if (message) this.actionError = { title: toggleErrorTitle(enabled), message };
      } catch (error) {
        this.actionError = { title: toggleErrorTitle(enabled), message: error.message };
        Sentry.captureException(error);
      } finally {
        this.togglingOrbit = false;
        await this.$apollo.queries.group.refetch();
      }
    },
  },
};
</script>

<template>
  <div
    class="gl-flex gl-max-w-limited gl-flex-col gl-gap-6 gl-py-5"
    data-testid="orbit-group-settings"
  >
    <gl-skeleton-loader v-if="!group" :lines="4" />

    <template v-else>
      <gl-alert
        v-if="showActionError"
        variant="danger"
        :title="actionError.title"
        data-testid="orbit-action-error"
        @dismiss="actionError = null"
      >
        {{ actionError.message }}
      </gl-alert>

      <group-settings-alert
        v-if="isBlocked"
        :state="blockedAlert"
        :group-name="group.name"
        :saas="saas"
        :usage-quotas-path="usageQuotasPath"
      />

      <gl-alert
        v-else-if="group.knowledgeGraphEnabled"
        :variant="isReady ? 'success' : 'info'"
        :title="statusAlertTitle"
        :primary-button-text="statusAlertButtonText"
        :primary-button-link="orbitPath"
        :dismissible="false"
        data-testid="orbit-status-alert"
      >
        <template v-if="!isReady && !statusUnavailable">
          {{ s__('Orbit|You can leave this page. A message appears here when Orbit is ready.') }}
        </template>
      </gl-alert>

      <div class="gl-flex gl-flex-col gl-gap-2">
        <h1 class="gl-heading-1 gl-mb-0">
          {{ s__('Orbit|Orbit') }}
        </h1>
        <p class="gl-mb-0 gl-text-subtle">
          {{
            s__(
              'Orbit|Orbit connects work items, merge requests, pipelines, and code, so GitLab Duo and other AI tools can answer questions across projects.',
            )
          }}
        </p>
      </div>

      <div
        v-if="showTrialBanner"
        class="gl-border gl-flex gl-items-center gl-gap-5 gl-rounded-lg gl-border-feedback-info gl-bg-feedback-info gl-p-5"
        data-testid="orbit-trial-banner"
      >
        <div
          class="gl-hidden gl-h-9 gl-w-9 gl-shrink-0 gl-items-center gl-justify-center gl-rounded-full gl-bg-default gl-text-feedback-info @sm:gl-flex"
        >
          <gl-icon name="orbit" :size="24" />
        </div>
        <div>
          <h2 class="gl-heading-4 gl-mb-2">{{ s__('Orbit|Free trial for Orbit') }}</h2>
          <p class="gl-mb-0 gl-text-subtle">{{ trialBannerText }}</p>
        </div>
      </div>

      <template v-if="showToggle">
        <gl-toggle
          :value="group.knowledgeGraphEnabled"
          :label="s__('Orbit|Turn on Orbit')"
          :help="
            s__(
              'Orbit|Required to use Orbit. Indexes this group, its subgroups, and projects. Can take up to a few hours.',
            )
          "
          :is-loading="togglingOrbit || startingTrial"
          data-testid="orbit-toggle"
          @change="onToggleChange"
        />

        <gl-alert
          v-if="showDuoAlert"
          variant="info"
          :title="s__('Orbit|GitLab Duo is not available for this group')"
          :primary-button-text="s__('Orbit|Go to GitLab Duo settings')"
          :primary-button-link="duoSettingsPath"
          :dismissible="false"
          data-testid="orbit-duo-alert"
        >
          {{ s__('Orbit|Turn on GitLab Duo to let Duo Chat and agents use Orbit.') }}
        </gl-alert>
      </template>

      <start-trial-modal
        :visible="startTrialModalVisible"
        :group-name="group.name"
        :starting="startingTrial"
        @start-trial="startTrial"
        @hide="startTrialModalVisible = false"
      />
    </template>
  </div>
</template>
