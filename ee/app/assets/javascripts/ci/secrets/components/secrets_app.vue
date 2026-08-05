<script>
import { computed } from 'vue';
import { GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { fetchPolicies } from '~/lib/graphql';
import { formatGraphQLError } from 'ee/ci/secrets/utils';
import {
  ENTITLEMENT_STATE_TRIAL_ELIGIBLE,
  INDEX_ROUTE_NAME,
  POLL_INTERVAL,
  SECRET_MANAGER_STATUS_ERROR,
  SECRET_MANAGER_STATUS_PROVISIONING,
} from '../constants';
import getEntitlementQuery from '../graphql/queries/get_secrets_manager_entitlement.graphql';
import getOpenbaoHealthQuery from '../graphql/queries/get_openbao_health.query.graphql';

export default {
  name: 'SecretsApp',
  components: {
    GlLoadingIcon,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: ['contextConfig', 'fullPath', 'topLevelGroupFullPath'],
  provide() {
    return {
      entitlement: computed(() => this.entitlement),
      isOpenbaoHealthy: computed(() => this.isOpenbaoHealthy),
      isReadOnly: computed(() => this.isReadOnly),
    };
  },
  data() {
    return {
      entitlement: null,
      secretManagerStatus: undefined,
      isReadOnly: false,
      isOpenbaoHealthy: true,
    };
  },
  apollo: {
    entitlement: {
      query: getEntitlementQuery,
      fetchPolicy: fetchPolicies.NETWORK_ONLY,
      skip() {
        return !this.isPaidExperienceEnabled || !this.topLevelGroupFullPath;
      },
      variables() {
        return {
          fullPath: this.topLevelGroupFullPath,
        };
      },
      update(data) {
        return data.group?.secretsManagerEntitlement;
      },
      error(e) {
        createAlert({
          message: formatGraphQLError(e.message),
          captureError: true,
          error: e,
        });
      },
    },
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

      // need Boolean wrapper here because isPaidExperienceEnabled can be undefined
      // and Apollo treats non-boolean falsy values differently from false
      skip() {
        return Boolean(
          this.isPaidExperienceEnabled && (this.isEntitlementLoading || this.isTrialEligible),
        );
      },
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      update(data) {
        // when not provisioned, secretsManagerStatus will return null
        if (data.secretsManager == null) {
          this.$apollo.queries.secretManagerStatus.stopPolling();
          return null;
        }

        const {
          status,
          entity: { archived, markedForDeletion },
        } = data.secretsManager;

        this.isReadOnly = archived || markedForDeletion;

        if (status !== SECRET_MANAGER_STATUS_PROVISIONING) {
          this.$apollo.queries.secretManagerStatus.stopPolling();
        }

        return status;
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
    hasStatusError() {
      return this.secretManagerStatus && this.secretManagerStatus === SECRET_MANAGER_STATUS_ERROR;
    },
    isEntitlementLoading() {
      return this.$apollo.queries.entitlement.loading;
    },
    isPaidExperienceEnabled() {
      return this.glFeatures.secretsManagerPaidExperience;
    },
    isProvisioning() {
      return this.secretManagerStatus === SECRET_MANAGER_STATUS_PROVISIONING;
    },
    isSecretsManagerStatusLoading() {
      return this.$apollo.queries.secretManagerStatus.loading;
    },
    isTrialEligible() {
      return this.entitlement?.state === ENTITLEMENT_STATE_TRIAL_ELIGIBLE;
    },
    showLoading() {
      if (this.isPaidExperienceEnabled) {
        return (
          this.isEntitlementLoading || (!this.isTrialEligible && this.isSecretsManagerStatusLoading)
        );
      }

      // when secretManagerStatus is null, the query has finished
      // and the secrets manager is just unprovisioned
      // but when it's undefined, it means the query hasn't run (waiting for entitlement state)
      // OR hasn't finished running yet
      return this.secretManagerStatus === undefined;
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
    v-if="showLoading"
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
