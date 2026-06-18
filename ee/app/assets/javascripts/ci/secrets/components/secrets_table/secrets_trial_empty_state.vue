<script>
import { GlButton, GlEmptyState } from '@gitlab/ui';
import TrialIllustrationSvg from '@gitlab/svgs/dist/illustrations/golden_tanuki.svg?url';
import { helpPagePath } from '~/helpers/help_page_helper';

export default {
  name: 'SecretsTrialEmptyState',
  components: {
    GlButton,
    GlEmptyState,
  },
  inject: ['enrollmentSettingsPath', 'isOpenbaoHealthy', 'isSaas'],
  computed: {
    showConfigureOpenbaoLink() {
      return !this.isOpenbaoHealthy && !this.isSaas;
    },
  },
  methods: {
    startTrial() {
      // TODO: call mutation to enable trial once the endpoint is available.
      // See https://gitlab.com/groups/gitlab-org/-/work_items/21755
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
