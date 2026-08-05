<script>
import { GlButton, GlEmptyState } from '@gitlab/ui';
import TrialIllustrationSvg from '@gitlab/svgs/dist/illustrations/empty-state/empty-secrets-md.svg?url';
import { helpPagePath } from '~/helpers/help_page_helper';
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import { refreshCurrentPage } from '~/lib/utils/url_utility';
import startTrialMutation from '../../graphql/mutations/start_secrets_manager_trial.mutation.graphql';

export default {
  name: 'SecretsTrialEmptyState',
  components: {
    GlButton,
    GlEmptyState,
  },
  inject: ['enrollmentSettingsPath', 'isOpenbaoHealthy', 'isSaas', 'topLevelGroupFullPath'],
  data() {
    return {
      isEnablingTrial: false,
    };
  },
  computed: {
    showConfigureOpenbaoLink() {
      return !this.isOpenbaoHealthy && !this.isSaas;
    },
  },
  methods: {
    async startTrial() {
      this.isEnablingTrial = true;

      try {
        const { data } = await this.$apollo.mutate({
          mutation: startTrialMutation,
          variables: {
            groupPath: this.topLevelGroupFullPath,
          },
        });

        const { errors } = data.secretsManagerStartTrial;

        if (errors?.length) {
          createAlert({ message: errors[0] });
        } else {
          this.$toast.show(s__('SecretsManager|Trial enabled. Redirecting to secrets manager...'));
          refreshCurrentPage();
        }
      } catch (e) {
        createAlert({
          message: s__('SecretsManager|An error occurred while starting the trial.'),
          captureError: true,
          error: e,
        });
      } finally {
        this.isEnablingTrial = false;
      }
    },
  },
  TrialIllustrationSvg,
  CONFIGURE_OPENBAO_LINK: helpPagePath('administration/secrets_manager/_index'),
};
</script>
<template>
  <gl-empty-state
    :title="s__('SecretsManager|Introducing GitLab Secrets Manager')"
    :description="
      s__(
        'SecretsManager|Use the GitLab Secrets Manager to securely store and manage secrets and credentials for your projects and groups.',
      )
    "
    :svg-path="$options.TrialIllustrationSvg"
  >
    <template #actions>
      <gl-button
        v-if="showConfigureOpenbaoLink"
        :href="$options.CONFIGURE_OPENBAO_LINK"
        target="_blank"
        rel="noopener noreferrer"
        data-testid="configure-openbao-link"
      >
        {{ s__('SecretsManager|Configure OpenBao') }}
      </gl-button>
      <template v-else>
        <gl-button
          class="gl-mr-4"
          variant="confirm"
          :loading="isEnablingTrial"
          data-testid="start-trial-button"
          @click="startTrial"
        >
          {{ __('Start a trial') }}
        </gl-button>
        <gl-button
          :href="enrollmentSettingsPath"
          data-testid="enable-addon-button"
          variant="confirm"
          category="secondary"
        >
          {{ __('Enable the add-on') }}
        </gl-button>
      </template>
    </template>
  </gl-empty-state>
</template>
