// Everything the wizard emits on save, as StepWizard builds it.
export const mockWizardState = {
  name: 'Prod gate',
  description: 'Gates production deployments',
  mode: 'enforce',
  scope: { mode: 'all', projects: [], exclusions: [] },
  scopeChanged: true,
  policyData: {
    trigger: 'deployment_requested',
    triggerConfig: {},
    rules: ['custom'],
    ruleConfigs: { custom: { policy: 'package governance' } },
    actions: [],
    actionConfigs: {},
  },
};

// The request params serializePolicyParams builds from mockWizardState.
export const mockPolicyParams = {
  name: 'Prod gate',
  description: 'Gates production deployments',
  mode: 'enforce',
  policy_scope: {},
  trigger_type: 'deployment_requested',
  rules: [{ type: 'custom', value: 'package governance' }],
  actions: [],
};

// A policy as the policies query returns it: the whole GovernPolicy selection
// set, with __typename and id so Apollo normalizes it. The one builder every
// policy store spec derives its policies from, so the selection set lives here (the list spec keeps its own list-only `apiPolicy`).
export const mockGraphqlPolicy = (overrides = {}) => ({
  __typename: 'GovernPolicy',
  id: 7,
  organizationId: 1,
  namespaceId: null,
  name: 'Production gate',
  description: 'Gates production deployments',
  version: 3,
  triggerType: 'deployment_requested',
  rules: [{ type: 'custom', value: 'package governance' }],
  policyRego: null,
  actions: [{ type: 'block' }],
  policyScope: { projects: { including: [1, 2, 3] } },
  scopeRego: null,
  scopeDimensions: null,
  mode: 'enforce',
  lifecycleState: 'active',
  createdAt: '2026-08-19T23:41:12.686Z',
  updatedAt: '2026-08-20T09:12:44.120Z',
  ...overrides,
});

export const mockRemoteTriggers = [
  { __typename: 'PolicyStoreTrigger', id: 'deployment_requested', name: 'Deployment requested' },
];

// mockGraphqlPolicy() as toPolicy maps it for the detail and editor pages:
// snake_case fields plus the derived type, status and scopedProjectsCount.
// Shallow-frozen: blocks top-level reassignment only; nested rules and actions stay mutable.
export const mockMappedPolicy = Object.freeze({
  id: 7,
  organization_id: 1,
  namespace_id: null,
  name: 'Production gate',
  description: 'Gates production deployments',
  version: 3,
  trigger_type: 'deployment_requested',
  rules: [{ type: 'custom', value: 'package governance' }],
  policy_rego: null,
  actions: [{ type: 'block' }],
  policy_scope: { projects: { including: [1, 2, 3] } },
  scope_rego: null,
  scope_dimensions: null,
  mode: 'enforce',
  lifecycle_state: 'active',
  created_at: '2026-08-19T23:41:12.686Z',
  updated_at: '2026-08-20T09:12:44.120Z',
  type: 'Deployment requested',
  status: 'active',
  scopedProjectsCount: 3,
});

// A null connection, not an empty one, is the resolver's permission signal.
export const mockPolicyStore = (policies, triggers) => ({
  __typename: 'PolicyStore',
  policies:
    policies === null
      ? null
      : {
          __typename: 'GovernPolicyConnection',
          nodes: policies,
          pageInfo: { __typename: 'PageInfo', hasNextPage: false, endCursor: null },
        },
  triggers,
});

const organizationResponse = (policyStore) => ({
  data: {
    organization: {
      __typename: 'Organization',
      id: 'gid://gitlab/Organizations::Organization/1',
      policyStore,
    },
  },
});

const groupResponse = (policyStore) => ({
  data: { group: { __typename: 'Group', id: 'gid://gitlab/Group/42', policyStore } },
});

export const mockOrganizationPoliciesResponse = (
  policies = [mockGraphqlPolicy()],
  triggers = mockRemoteTriggers,
) => organizationResponse(mockPolicyStore(policies, triggers));

export const mockGroupPoliciesResponse = (
  policies = [mockGraphqlPolicy()],
  triggers = mockRemoteTriggers,
) => groupResponse(mockPolicyStore(policies, triggers));

// The resolver nulls the whole field when the experiment is off.
export const mockOrganizationInactiveStoreResponse = () => organizationResponse(null);
export const mockGroupInactiveStoreResponse = () => groupResponse(null);
