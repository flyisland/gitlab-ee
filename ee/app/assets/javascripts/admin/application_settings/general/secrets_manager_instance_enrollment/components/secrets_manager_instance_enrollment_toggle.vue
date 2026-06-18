<script>
import { GlAlert, GlBadge, GlLink, GlSprintf, GlToggle } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import { logError } from '~/lib/logger';
import { __, s__ } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import getInstanceSecretsManagerEnrollmentQuery from '../graphql/queries/get_instance_secrets_manager_enrollment.query.graphql';
import enrollInstanceSecretsManagerMutation from '../graphql/mutations/enroll_instance_secrets_manager.mutation.graphql';
import unenrollInstanceSecretsManagerMutation from '../graphql/mutations/unenroll_instance_secrets_manager.mutation.graphql';

export default {
  name: 'SecretsManagerInstanceEnrollmentToggle',
  components: {
    GlAlert,
    GlBadge,
    GlLink,
    GlSprintf,
    GlToggle,
  },
  i18n: {
    label: s__('SecretsManager|Secrets Manager'),
    helpText: s__(
      'SecretsManager|Enable Secrets Manager for this instance. When enabled, the secrets manager can be turned on for any project or group in the instance.',
    ),
    beta: __('Beta'),
    loadError: s__('SecretsManager|Failed to load Secrets Manager enrollment state.'),
    updateError: s__('SecretsManager|Failed to update Secrets Manager enrollment.'),
    enrollSuccess: s__('SecretsManager|Secrets Manager is enabled.'),
    unenrollSuccess: s__('SecretsManager|Secrets Manager is disabled.'),
    openBetaAlert: {
      title: s__('SecretsManager|Charges may be incurred at the end of open beta'),
      description: s__(
        "SecretsManager|GitLab Secrets Manager is free during open beta, but will consume %{linkStart}GitLab Credits%{linkEnd} when released as generally available (GA). Credits will only be consumed if you opt in, and we'll give you advance notice before GA.",
      ),
    },
  },
  GITLAB_CREDITS_DOCS_LINK: helpPagePath('subscriptions/gitlab_credits'),
  data() {
    return {
      isEnrolled: false,
      isMutating: false,
      errorMessage: '',
    };
  },
  apollo: {
    isEnrolled: {
      query: getInstanceSecretsManagerEnrollmentQuery,
      fetchPolicy: 'network-only',
      update(data) {
        return Boolean(data?.instanceSecretsManagerEnrollment);
      },
      error(error) {
        this.reportError(this.$options.i18n.loadError, error);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.isEnrolled.loading || this.isMutating;
    },
  },
  methods: {
    reportError(message, error) {
      this.errorMessage = message;
      logError(message, error);
      Sentry.captureException(error);
    },
    toggleEnrollment(shouldEnroll) {
      return shouldEnroll ? this.enroll() : this.unenroll();
    },
    enroll() {
      return this.performMutation({
        mutation: enrollInstanceSecretsManagerMutation,
        responseKey: 'instanceSecretsManagerEnroll',
        nextValue: true,
        successMessage: this.$options.i18n.enrollSuccess,
      });
    },
    unenroll() {
      return this.performMutation({
        mutation: unenrollInstanceSecretsManagerMutation,
        responseKey: 'instanceSecretsManagerUnenroll',
        nextValue: false,
        successMessage: this.$options.i18n.unenrollSuccess,
      });
    },
    async performMutation({ mutation, responseKey, nextValue, successMessage }) {
      this.isMutating = true;
      this.errorMessage = '';

      try {
        const { data } = await this.$apollo.mutate({ mutation });
        const errors = data?.[responseKey]?.errors ?? [];

        if (errors.length) {
          throw new Error(errors.join(', '));
        }

        this.isEnrolled = nextValue;
        this.$toast.show(successMessage);
      } catch (error) {
        this.reportError(this.$options.i18n.updateError, error);
      } finally {
        this.isMutating = false;
      }
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="errorMessage"
      class="gl-mb-4"
      variant="danger"
      data-testid="enrollment-error-alert"
      @dismiss="errorMessage = ''"
    >
      {{ errorMessage }}
    </gl-alert>
    <div class="gl-flex gl-items-center gl-gap-2">
      <strong>{{ $options.i18n.label }}</strong>
      <gl-badge>{{ $options.i18n.beta }}</gl-badge>
    </div>
    <p class="gl-mb-3 gl-mt-2 gl-text-subtle">{{ $options.i18n.helpText }}</p>
    <gl-toggle
      :value="isEnrolled"
      :disabled="isLoading"
      :is-loading="isLoading"
      :label="$options.i18n.label"
      label-position="hidden"
      data-testid="secrets-manager-instance-enrollment-toggle"
      @change="toggleEnrollment"
    />
    <gl-alert
      variant="warning"
      class="gl-mb-4 gl-mt-6"
      data-testid="open-beta-billing-alert"
      :dismissible="false"
      :title="$options.i18n.openBetaAlert.title"
    >
      <gl-sprintf :message="$options.i18n.openBetaAlert.description">
        <template #link="{ content }">
          <gl-link
            class="gl-inline-block"
            :href="$options.GITLAB_CREDITS_DOCS_LINK"
            target="_blank"
          >
            {{ content }}
          </gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>
  </div>
</template>
