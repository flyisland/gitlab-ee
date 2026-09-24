<script>
import { GlAlert } from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { __, s__ } from '~/locale';
import { joinPaths } from '~/lib/utils/url_utility';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPE_ORGANIZATION } from '~/graphql_shared/constants';
// TODO: Replace the evaluations mock once the Policy Store exposes evaluation
// stats. Tracked in https://gitlab.com/gitlab-org/gitlab/-/work_items/604312
import { MOCK_EVALUATIONS_THIS_WEEK } from '../../mock_data';
import { toListPolicies } from '../../policies';
import getPolicyStorePolicies from '../../graphql/get_policy_store_policies.query.graphql';
import ListWrapper from './list_wrapper.vue';

export default {
  name: 'PolicyStoreListRoot',
  components: {
    GlAlert,
    ListWrapper,
  },
  MOCK_EVALUATIONS_THIS_WEEK,
  i18n: {
    policiesError: s__('PolicyStore|The policies could not be fetched from the Policy Store API.'),
    retry: __('Retry'),
    policiesPermissionError: s__(
      'PolicyStore|You do not have permission to view the policies of this organization.',
    ),
  },
  // The per-policy detail path is derived from listPath and the policy id until the API exposes it.
  inject: {
    organizationId: {},
    newPolicyPath: { default: '' },
    listPath: { default: '' },
  },
  data() {
    return {
      policies: [],
      policiesError: false,
      policiesErrorPermission: false,
    };
  },
  apollo: {
    policies: {
      query: getPolicyStorePolicies,
      variables() {
        return { id: convertToGraphQLId(TYPE_ORGANIZATION, this.organizationId) };
      },
      update({ organization }) {
        return toListPolicies(organization?.policyStore);
      },
      result({ data, error }) {
        // A failed refetch re-emits the last cached data with the error
        // attached; skip it so the error state set by the hook below survives.
        if (!data || error) return;

        // Denied reads return null instead of an error — the resolver nulls the
        // field when the viewer lacks read_govern_policy or the experiment is
        // off — so a null list is the only permission signal the API gives.
        const denied = !data.organization?.policyStore?.policies;
        this.policiesError = denied;
        this.policiesErrorPermission = denied;
      },
      error(error) {
        Sentry.captureException(error);
        this.policiesError = true;
      },
    },
  },
  computed: {
    policiesLoading() {
      return this.$apollo.queries.policies.loading;
    },
    listPolicies() {
      // A failed refetch leaves Apollo re-emitting the last cached rows; guard
      // here so an error never shows stale data, matching the REST version.
      if (this.policiesError) return [];

      return this.policies.map((policy) => ({
        ...policy,
        detailPath: this.listPath ? joinPaths(this.listPath, String(policy.id)) : '',
      }));
    },
    policiesErrorMessage() {
      return this.policiesErrorPermission
        ? this.$options.i18n.policiesPermissionError
        : this.$options.i18n.policiesError;
    },
    // Retrying cannot fix missing permissions, so the button only shows for
    // failures that might be transient.
    policiesErrorRetryText() {
      return this.policiesErrorPermission ? null : this.$options.i18n.retry;
    },
  },
  methods: {
    retryPolicies() {
      this.policiesError = false;
      this.policiesErrorPermission = false;
      // A failed retry rejects the refetch promise; the error() hook already
      // handles it, so consume the rejection to avoid an unhandled one.
      this.$apollo.queries.policies.refetch().catch(() => {});
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="policiesError"
      variant="danger"
      :dismissible="false"
      :primary-button-text="policiesErrorRetryText"
      class="gl-mt-4"
      data-testid="policies-error"
      @primary-action="retryPolicies()"
    >
      {{ policiesErrorMessage }}
    </gl-alert>
    <list-wrapper
      :policies="listPolicies"
      :loading="policiesLoading"
      :error="policiesError"
      :evaluations-this-week="$options.MOCK_EVALUATIONS_THIS_WEEK"
      :new-policy-path="newPolicyPath"
    />
  </div>
</template>
