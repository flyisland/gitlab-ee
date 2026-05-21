<script>
import { computed } from 'vue';
import { GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import { formatGraphQLError } from 'ee/ci/secrets/utils';
import {
  INDEX_ROUTE_NAME,
  POLL_INTERVAL,
  SECRET_MANAGER_STATUS_ERROR,
  SECRET_MANAGER_STATUS_PROVISIONING,
} from '../constants';
import getOpenbaoHealthQuery from '../graphql/queries/get_openbao_health.query.graphql';

export default {
  name: 'SecretsApp',
  components: {
    GlLoadingIcon,
  },
  inject: ['contextConfig', 'fullPath'],
  provide() {
    return {
      isOpenbaoHealthy: computed(() => this.isOpenbaoHealthy),
    };
  },
  data() {
    return {
      secretManagerStatus: null,
      isOpenbaoHealthy: true,
    };
  },
  apollo: {
    isOpenbaoHealthy: {
      query: getOpenbaoHealthQuery,
      update(data) {
        if (!data.openbaoHealth) {
          this.showOpenbaoUnhealthyAlert();
          this.redirectToIndex();
        }
        return data.openbaoHealth;
      },
      error() {
        this.isOpenbaoHealthy = false;
        this.showOpenbaoUnhealthyAlert();
        this.redirectToIndex();
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
        const newStatus = data.secretsManager?.status;

        if (newStatus !== SECRET_MANAGER_STATUS_PROVISIONING) {
          this.$apollo.queries.secretManagerStatus.stopPolling();
        }

        return newStatus;
      },
      error(e) {
        this.$apollo.queries.secretManagerStatus.stopPolling();
        this.secretManagerStatus = SECRET_MANAGER_STATUS_ERROR;
        createAlert({
          message: formatGraphQLError(e.message),
          captureError: true,
          error: e,
        });
      },
      pollInterval: POLL_INTERVAL,
    },
  },
  computed: {
    isProvisioning() {
      return this.secretManagerStatus === SECRET_MANAGER_STATUS_PROVISIONING;
    },
    hasStatusError() {
      return this.secretManagerStatus && this.secretManagerStatus === SECRET_MANAGER_STATUS_ERROR;
    },
  },
  methods: {
    showOpenbaoUnhealthyAlert() {
      createAlert({
        title: s__('SecretsManager|Cannot connect to OpenBao'),
        message: s__(
          'SecretsManager|Failed to connect with OpenBao. Secrets are currently unavailable, please try again later.',
        ),
      });
    },
    redirectToIndex() {
      if (this.$route?.name !== INDEX_ROUTE_NAME) {
        this.$router.push({ name: INDEX_ROUTE_NAME });
      }
    },
    showSecretsToast(message) {
      this.$toast.show(message);
    },
  },
};
</script>
<template>
  <gl-loading-icon
    v-if="!secretManagerStatus"
    data-testid="secrets-manager-loading-status"
    class="gl-mt-5"
  />
  <div
    v-else-if="isProvisioning"
    data-testid="secrets-manager-provisioning-text"
    class="gl-mt-5 gl-text-center"
  >
    <div class="gl-flex gl-items-center gl-justify-center">
      <gl-loading-icon class="gl-mr-3 gl-mt-1" />
      <p class="gl-mb-0 gl-inline gl-text-size-h1 gl-font-semibold">
        {{ s__('SecretsManager|Provisioning in progress') }}
      </p>
    </div>
    <p class="gl-mt-4 gl-text-subtle">
      {{
        s__(
          'SecretsManager|Please wait while the secrets manager is provisioned. You can refresh at any time.',
        )
      }}
    </p>
  </div>
  <router-view
    v-else-if="!hasStatusError"
    ref="router-view"
    @show-secrets-toast="showSecretsToast"
  />
</template>
