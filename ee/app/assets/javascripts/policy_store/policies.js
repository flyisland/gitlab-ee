import Api from 'ee/api';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPE_ORGANIZATION } from '~/graphql_shared/constants';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import { gqlClient } from './apollo';
import getPolicyStoreCatalogs from './graphql/get_policy_store_catalogs.query.graphql';
import getPolicyStorePolicies from './graphql/get_policy_store_policies.query.graphql';
import governPolicyCreateMutation from './graphql/govern_policy_create.mutation.graphql';
import { presentable, PolicyStoreMutationError } from './utils';
import { TRIGGERS } from './catalog/triggers';

// Same resolution the wizard uses: the local catalog supplies the label for ids
// it knows, the API-provided name covers newer triggers, the raw id is the last
// resort. Keeps the list and the editor rendering the same trigger the same way.
const triggerLabel = (triggerType, remoteTriggers) =>
  presentable(remoteTriggers.find(({ id }) => id === triggerType) ?? { id: triggerType }, TRIGGERS)
    .label;

// A stored criterion is a plain array of ids or `{ id }` hashes.
const scopedProjectsCount = (policyScope) => {
  const including = policyScope?.projects?.including;

  return Array.isArray(including) ? including.length : 0;
};

// The list renders `type`, `status` and `scopedProjectsCount` columns on top
// of the policy as the API returns it; the editor reads the raw fields back
// through deserializePolicyData and deserializeScope.
const toListPolicy = (policy, remoteTriggers) => ({
  ...policy,
  type: triggerLabel(policy.trigger_type, remoteTriggers),
  status: policy.lifecycle_state,
  scopedProjectsCount: scopedProjectsCount(policy.policy_scope),
});

/**
 * Maps the `organization.policyStore` GraphQL payload to the rows the list
 * renders — the same derived columns as toListPolicy, but from the camelCase
 * GraphQL fields. trigger_type, rules and actions keep the snake_case shape
 * the REST wrapper produced, because config_info.vue deserializes them from
 * the row.
 *
 * @param {Object|null} policyStore - The `organization.policyStore` query
 *   result; null when the experiment is not active for the organization.
 * @returns {Array} The list rows.
 */
export const toListPolicies = (policyStore) => {
  const triggers = (policyStore?.triggers ?? []).filter((trigger) => trigger?.id);

  return (policyStore?.policies ?? []).map((policy) => ({
    id: policy.id,
    name: policy.name,
    mode: policy.mode,
    trigger_type: policy.triggerType,
    rules: policy.rules,
    actions: policy.actions,
    updated_at: policy.updatedAt,
    type: triggerLabel(policy.triggerType, triggers),
    status: policy.lifecycleState,
    scopedProjectsCount: scopedProjectsCount(policy.policyScope),
  }));
};

// The triggers catalog only affects labels, so its failure degrades them
// instead of failing the policy fetch.
const fetchRemoteTriggers = (organizationId) =>
  gqlClient()
    .query({
      query: getPolicyStoreCatalogs,
      variables: { id: convertToGraphQLId(TYPE_ORGANIZATION, organizationId) },
    })
    .then(({ data }) =>
      (data?.organization?.policyStore?.triggers ?? []).filter((trigger) => trigger?.id),
    )
    .catch(() => []);

// Unknown ids and unauthorized reads come back as an empty (or null) list
// rather than an error, so rejecting here is what keeps the not-found
// contract the detail and editor error states rely on.
const fetchStorePolicy = (organizationId, policyId) =>
  gqlClient()
    .query({
      query: getPolicyStorePolicies,
      variables: {
        id: convertToGraphQLId(TYPE_ORGANIZATION, organizationId),
        ids: [Number(policyId)],
      },
      // The policy is mutable through the still-REST write paths, which never
      // touch the Apollo cache, so a cached read could serve a stale policy.
      fetchPolicy: 'network-only',
    })
    .then(({ data }) => {
      const policy = data.organization?.policyStore?.policies?.[0];

      if (!policy) {
        // Constant Sentry-facing message, never rendered: an interpolated id
        // would split one ordinary not-found into an issue per policy.
        // eslint-disable-next-line @gitlab/require-i18n-strings
        throw new Error('Policy not found in the policy store');
      }

      // Shallow on purpose: the free-form JSON fields keep their stored shape.
      return convertObjectPropsToSnakeCase(policy, { dropKeys: ['__typename'] });
    });

/**
 * Fetches one policy through the GraphQL policies query, mapped the same way
 * as the list so the editor can read it back. Rejects on failure, including
 * for a policy the organization does not have or the user cannot read.
 *
 * @param {string|number} organizationId
 * @param {string|number} policyId
 * @returns {Promise<Object>}
 */
export const fetchPolicy = async (organizationId, policyId) => {
  const [policy, remoteTriggers] = await Promise.all([
    fetchStorePolicy(organizationId, policyId),
    fetchRemoteTriggers(organizationId),
  ]);

  return toListPolicy(policy, remoteTriggers);
};

/**
 * Creates a policy through the governPolicyCreate GraphQL mutation. Rejects
 * with a PolicyStoreMutationError carrying the store's message when the
 * params fail validation, or with the request error on other failures.
 *
 * @param {string|number} organizationId
 * @param {Object} params - Params from serializePolicyParams.
 * @returns {Promise<{id: number}>} The mutation payload's policy, which
 *   currently only carries `id` per the selection set.
 */
export const createPolicy = async (organizationId, params) => {
  const { data } = await gqlClient().mutate({
    mutation: governPolicyCreateMutation,
    // The serializer keeps the REST endpoints' snake_case shape while update
    // and delete are still REST, so the camelCase adaptation happens here.
    variables: {
      organizationId: convertToGraphQLId(TYPE_ORGANIZATION, organizationId),
      name: params.name,
      description: params.description,
      mode: params.mode,
      triggerType: params.trigger_type,
      policyScope: params.policy_scope,
      rules: params.rules,
      actions: params.actions,
    },
  });

  const { policy, errors } = data.governPolicyCreate;

  if (errors.length) throw new PolicyStoreMutationError(errors.join(', '));

  return policy;
};

/**
 * Updates one policy through the Policy Store API. Rejects with the request
 * error on failure, including a 400 when the params fail validation.
 *
 * @param {string|number} organizationId
 * @param {string|number} policyId
 * @param {Object} params - Params from serializePolicyParams.
 * @returns {Promise<Object>} The updated policy, mapped like the list.
 */
export const updatePolicy = async (organizationId, policyId, params) => {
  const [{ data }, remoteTriggers] = await Promise.all([
    Api.updatePolicyStorePolicy(organizationId, policyId, params),
    fetchRemoteTriggers(organizationId),
  ]);

  return toListPolicy(data, remoteTriggers);
};
