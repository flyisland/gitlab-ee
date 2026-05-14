<script>
import { GlAlert, GlLink, GlToggle } from '@gitlab/ui';
import { s__ } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';
import {
  ACTION_ENABLE_SECRET_MANAGER,
  ACTION_DISABLE_SECRET_MANAGER,
  SECRET_MANAGER_STATUS_ACTIVE,
  SECRET_MANAGER_STATUS_INACTIVE,
  SECRET_MANAGER_STATUS_PROVISIONING,
  SECRET_MANAGER_STATUS_DEPROVISIONING,
  ENTITY_PROJECT,
  ENTITY_GROUP,
} from 'ee/ci/secrets/constants';
import getOpenbaoHealthQuery from 'ee/ci/secrets/graphql/queries/get_openbao_health.query.graphql';
import { SECRETS_MANAGER_PERMISSIONS_CONTEXT_CONFIG } from './context_config';
import PermissionsSettings from './components/secrets_manager_permissions_settings.vue';

export const POLL_INTERVAL = 2000;

const PROVISIONED_MESSAGES = {
  [ENTITY_PROJECT]: s__(
    'SecretsManagerPermissions|Secrets manager has been provisioned for this project.',
  ),
  [ENTITY_GROUP]: s__(
    'SecretsManagerPermissions|Secrets manager has been provisioned for this group.',
  ),
};

const DEPROVISIONED_MESSAGES = {
  [ENTITY_PROJECT]: s__(
    'SecretsManagerPermissions|Secrets manager has been deprovisioned for this project.',
  ),
  [ENTITY_GROUP]: s__(
    'SecretsManagerPermissions|Secrets manager has been deprovisioned for this group.',
  ),
};

const DESCRIPTION_MESSAGES = {
  [ENTITY_PROJECT]: s__(
    'SecretsManagerPermissions|Enable the secrets manager to securely store and manage sensitive information for this project.',
  ),
  [ENTITY_GROUP]: s__(
    'SecretsManagerPermissions|Enable the secrets manager to securely store and manage sensitive information for this group.',
  ),
};

export default {
  name: 'SecretsManagerSettings',
  components: {
    GlAlert,
    GlLink,
    GlToggle,
    PermissionsSettings,
  },
  props: {
    canManageSecretsManager: {
      type: Boolean,
      required: true,
    },
    context: {
      type: String,
      required: true,
    },
    fullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      action: null,
      errorMessage: '',
      isOpenbaoHealthy: true,
      secretManagerStatus: SECRET_MANAGER_STATUS_INACTIVE,
    };
  },
  computed: {
    contextConfig() {
      return SECRETS_MANAGER_PERMISSIONS_CONTEXT_CONFIG[this.context];
    },
    isActive() {
      return this.secretManagerStatus === SECRET_MANAGER_STATUS_ACTIVE;
    },
    isEnablingSecretsManager() {
      return this.action === ACTION_ENABLE_SECRET_MANAGER;
    },
    isDisablingSecretsManager() {
      return this.action === ACTION_DISABLE_SECRET_MANAGER;
    },
    isInactive() {
      return this.secretManagerStatus === SECRET_MANAGER_STATUS_INACTIVE;
    },
    isLoading() {
      return this.$apollo.queries.secretManagerStatus?.loading ?? false;
    },
    isProvisioning() {
      return this.secretManagerStatus === SECRET_MANAGER_STATUS_PROVISIONING;
    },
    isDeprovisioning() {
      return this.secretManagerStatus === SECRET_MANAGER_STATUS_DEPROVISIONING;
    },
    isToggleDisabled() {
      return (
        !this.isOpenbaoHealthy ||
        this.isLoading ||
        this.isProvisioning ||
        this.isDeprovisioning ||
        this.hasError ||
        !this.canManageSecretsManager
      );
    },
    isToggleLoading() {
      return this.isLoading || this.isProvisioning || this.isDeprovisioning;
    },
    hasError() {
      return this.errorMessage.length > 0;
    },
    provisionedMessage() {
      return PROVISIONED_MESSAGES[this.context];
    },
    deprovisionedMessage() {
      return DEPROVISIONED_MESSAGES[this.context];
    },
    descriptionMessage() {
      return DESCRIPTION_MESSAGES[this.context];
    },
  },
  apollo: {
    isOpenbaoHealthy: {
      query: getOpenbaoHealthQuery,
      update(data) {
        return data.openbaoHealth;
      },
      error() {
        this.isOpenbaoHealthy = false;
      },
    },
    secretManagerStatus: {
      query() {
        return this.contextConfig.getStatus.query;
      },
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      update(data) {
        const { secretsManager } = data;
        const newStatus = secretsManager?.status || SECRET_MANAGER_STATUS_INACTIVE;

        if (this.isEnablingSecretsManager && newStatus === SECRET_MANAGER_STATUS_ACTIVE) {
          this.$apollo.queries.secretManagerStatus.stopPolling();
          this.$toast.show(this.provisionedMessage);
        }

        if (this.isDisablingSecretsManager && newStatus === SECRET_MANAGER_STATUS_INACTIVE) {
          this.$apollo.queries.secretManagerStatus.stopPolling();
          this.$toast.show(this.deprovisionedMessage);
        }

        if (
          newStatus === SECRET_MANAGER_STATUS_ACTIVE ||
          newStatus === SECRET_MANAGER_STATUS_INACTIVE
        ) {
          this.$apollo.queries.secretManagerStatus.stopPolling();
        }

        return newStatus;
      },
      error(e) {
        this.$apollo.queries.secretManagerStatus.stopPolling(POLL_INTERVAL);
        this.errorMessage =
          e.graphQLErrors?.[0]?.message ||
          s__(
            'SecretsManagerPermissions|An error occurred while fetching the secrets manager status.',
          );

        if (this.isEnablingSecretsManager) {
          this.secretManagerStatus = SECRET_MANAGER_STATUS_INACTIVE;
        }
      },
      pollInterval: POLL_INTERVAL,
    },
  },
  methods: {
    async enableSecretsManager() {
      this.errorMessage = '';
      try {
        const { data } = await this.$apollo.mutate({
          mutation: this.contextConfig.enable.mutation,
          variables: { fullPath: this.fullPath },
        });

        const result = this.contextConfig.enable.lookup(data);
        const { secretsManager, errors } = result;

        if (errors.length > 0) {
          throw new Error(errors[0]);
        }

        this.secretManagerStatus = secretsManager?.status || SECRET_MANAGER_STATUS_INACTIVE;
        this.$apollo.queries.secretManagerStatus.startPolling(POLL_INTERVAL);
      } catch (error) {
        this.errorMessage =
          error?.message ||
          s__('SecretsManagerPermissions|An error occurred while enabling the secrets manager.');
      }
    },
    async disableSecretsManager() {
      this.errorMessage = '';
      try {
        const { data } = await this.$apollo.mutate({
          mutation: this.contextConfig.disable.mutation,
          variables: { fullPath: this.fullPath },
        });

        const result = this.contextConfig.disable.lookup(data);
        const { secretsManager, errors } = result;

        if (errors.length > 0) {
          throw new Error(errors[0]);
        }

        this.secretManagerStatus = secretsManager?.status || SECRET_MANAGER_STATUS_INACTIVE;
        this.$apollo.queries.secretManagerStatus.startPolling(POLL_INTERVAL);
      } catch (error) {
        this.errorMessage =
          error?.message ||
          s__('SecretsManagerPermissions|An error occurred while disabling the secrets manager.');
      }
    },
    onToggleSecretManager() {
      if (this.isInactive) {
        this.action = ACTION_ENABLE_SECRET_MANAGER;
        this.enableSecretsManager();
      } else if (this.isActive) {
        this.action = ACTION_DISABLE_SECRET_MANAGER;
        this.disableSecretsManager();
      }
    },
  },
  LEARN_MORE_LINK: helpPagePath('ci/secrets/secrets_manager/_index'),
};
</script>

<template>
  <div data-testid="secret-manager">
    <label class="gl-mb-1 gl-mr-3">
      {{ s__('SecretsManagerPermissions|Secrets manager') }}
    </label>
    <p class="gl-mb-2">
      {{ descriptionMessage }}
      <gl-link :href="$options.LEARN_MORE_LINK">
        {{ __('Learn more.') }}
      </gl-link>
    </p>
    <gl-toggle
      :value="isActive"
      :label="s__('SecretsManagerPermissions|Secrets manager')"
      :disabled="isToggleDisabled"
      :is-loading="isToggleLoading"
      label-position="hidden"
      name="secret_manager_enabled"
      data-testid="secret-manager-toggle"
      @change="onToggleSecretManager"
    />
    <p v-if="hasError" class="gl-mt-2 gl-text-danger" data-testid="secret-manager-error">
      {{ errorMessage }}
    </p>
    <permissions-settings
      v-if="isActive && isOpenbaoHealthy"
      :can-manage-secrets-manager="canManageSecretsManager"
      :full-path="fullPath"
      :context="context"
    />
    <gl-alert
      v-if="!isOpenbaoHealthy"
      variant="danger"
      :dismissible="false"
      class="gl-mb-4 gl-mt-4"
      data-testid="openbao-unhealthy-alert"
    >
      {{
        s__(
          'SecretsManager|Failed to connect with OpenBao. Secrets are currently unavailable, please try again later.',
        )
      }}
    </gl-alert>
  </div>
</template>
