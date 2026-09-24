import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_INTERNAL_SERVER_ERROR, HTTP_STATUS_OK } from '~/lib/utils/http_status';
import { fetchPolicy, createPolicy, updatePolicy } from 'ee/policy_store/policies';
import { gqlClient } from 'ee/policy_store/apollo';
import getPolicyStorePolicies from 'ee/policy_store/graphql/get_policy_store_policies.query.graphql';
import governPolicyCreateMutation from 'ee/policy_store/graphql/govern_policy_create.mutation.graphql';
import { PolicyStoreMutationError } from 'ee/policy_store/utils';

jest.mock('ee/policy_store/apollo', () => {
  const query = jest.fn();
  const mutate = jest.fn();
  return { __esModule: true, default: jest.fn(), gqlClient: () => ({ query, mutate }) };
});

const POLICY_URL = '/api/v4/organizations/1/security/policy_store/7';

const triggersResponse = {
  data: {
    organization: {
      id: 'gid://gitlab/Organizations::Organization/1',
      policyStore: {
        triggers: [
          { id: 'deployment_requested', name: 'Deployment requested' },
          { id: 'merge_requested', name: 'Merge Request' },
        ],
      },
    },
  },
};

describe('policy store policies', () => {
  let mock;

  beforeEach(() => {
    window.gon = { api_version: 'v4' };
    mock = new MockAdapter(axios);
    gqlClient().query.mockResolvedValue(triggersResponse);
  });

  afterEach(() => {
    mock.restore();
  });

  const apiPolicy = {
    id: 7,
    name: 'Production gate',
    description: 'Gates production deployments',
    trigger_type: 'deployment_requested',
    rules: [{ type: 'custom', value: 'package governance' }],
    actions: [{ type: 'block' }],
    policy_scope: { projects: { including: [1, 2, 3] } },
    mode: 'enforce',
    lifecycle_state: 'active',
    updated_at: '2026-08-11T10:00:00Z',
  };

  describe('fetchPolicy', () => {
    // The GraphQL mirror of apiPolicy, as the policies query returns it.
    const graphqlPolicy = {
      __typename: 'GovernPolicy',
      id: 7,
      organizationId: 1,
      namespaceId: null,
      name: 'Production gate',
      description: 'Gates production deployments',
      version: 1,
      triggerType: 'deployment_requested',
      rules: [{ type: 'custom', value: 'package governance' }],
      policyRego: 'package governance\n',
      actions: [{ type: 'block' }],
      policyScope: { projects: { including: [1, 2, 3] } },
      scopeRego: 'package gitlab.scope\n',
      scopeDimensions: null,
      mode: 'enforce',
      lifecycleState: 'active',
      createdAt: '2026-08-10T10:00:00+00:00',
      updatedAt: '2026-08-11T10:00:00+00:00',
    };

    const policiesResponse = (policies) => ({
      data: {
        organization: {
          id: 'gid://gitlab/Organizations::Organization/1',
          policyStore: { policies },
        },
      },
    });

    // Both the policies query and the degradable triggers query go through the
    // same client, so the mock dispatches on the query document like Apollo does.
    const mockPolicyQuery = ({ policies = [graphqlPolicy], triggersFail = false } = {}) => {
      gqlClient().query.mockImplementation(({ query }) => {
        if (query === getPolicyStorePolicies) {
          return Promise.resolve(policiesResponse(policies));
        }

        return triggersFail
          ? Promise.reject(new Error('query failed'))
          : Promise.resolve(triggersResponse);
      });
    };

    it('fetches the policy through the policies query and maps it like the list', async () => {
      mockPolicyQuery();

      const policy = await fetchPolicy(1, '7');

      expect(gqlClient().query).toHaveBeenCalledWith(
        expect.objectContaining({
          query: getPolicyStorePolicies,
          variables: { id: 'gid://gitlab/Organizations::Organization/1', ids: [7] },
          fetchPolicy: 'network-only',
        }),
      );
      expect(policy).toMatchObject({
        id: 7,
        name: 'Production gate',
        type: 'Deployment requested',
        trigger_type: 'deployment_requested',
        status: 'active',
        scopedProjectsCount: 3,
        policy_rego: 'package governance\n',
        scope_rego: 'package gitlab.scope\n',
        created_at: '2026-08-10T10:00:00+00:00',
        updated_at: '2026-08-11T10:00:00+00:00',
      });
      expect(policy).not.toHaveProperty('__typename');
    });

    it('keeps the stored shape of the free-form JSON fields', async () => {
      mockPolicyQuery();

      const policy = await fetchPolicy(1, 7);

      expect(policy.rules).toEqual([{ type: 'custom', value: 'package governance' }]);
      expect(policy.policy_scope).toEqual({ projects: { including: [1, 2, 3] } });
    });

    it('rejects when the organization does not have the policy', async () => {
      mockPolicyQuery({ policies: [] });

      await expect(fetchPolicy(1, 7)).rejects.toThrow('not found');
    });

    it('rejects when the policies are not readable', async () => {
      mockPolicyQuery({ policies: null });

      await expect(fetchPolicy(1, 7)).rejects.toThrow('not found');
    });

    it('rejects when the policy store is not available', async () => {
      gqlClient().query.mockResolvedValue({
        data: {
          organization: { id: 'gid://gitlab/Organizations::Organization/1', policyStore: null },
        },
      });

      await expect(fetchPolicy(1, 7)).rejects.toThrow('not found');
    });

    it('rejects with the request error when the query fails', async () => {
      gqlClient().query.mockRejectedValue(new Error('query failed'));

      await expect(fetchPolicy(1, 7)).rejects.toThrow('query failed');
    });

    it('still resolves the policy when the triggers query fails', async () => {
      mockPolicyQuery({
        policies: [{ ...graphqlPolicy, triggerType: 'merge_requested' }],
        triggersFail: true,
      });

      const policy = await fetchPolicy(1, 7);

      expect(policy.type).toBe('merge_requested');
    });
  });

  describe('createPolicy', () => {
    const params = {
      name: 'Production gate',
      description: 'Gates production deployments',
      mode: 'enforce',
      policy_scope: { projects: { including: [3] } },
      trigger_type: 'deployment_requested',
      rules: [{ type: 'custom', value: 'package governance' }],
      actions: [],
    };

    const mutationResponse = ({
      policy = { __typename: 'GovernPolicy', id: 7 },
      errors = [],
    } = {}) => ({
      data: { governPolicyCreate: { policy, errors } },
    });

    it('creates the policy through the mutation, adapting the params to its arguments', async () => {
      gqlClient().mutate.mockResolvedValue(mutationResponse());

      const policy = await createPolicy(1, params);

      expect(gqlClient().mutate).toHaveBeenCalledWith({
        mutation: governPolicyCreateMutation,
        variables: {
          organizationId: 'gid://gitlab/Organizations::Organization/1',
          name: 'Production gate',
          description: 'Gates production deployments',
          mode: 'enforce',
          triggerType: 'deployment_requested',
          policyScope: { projects: { including: [3] } },
          rules: [{ type: 'custom', value: 'package governance' }],
          actions: [],
        },
      });
      expect(policy).toMatchObject({ id: 7 });
    });

    it('rejects with the bare store message when the params fail validation', async () => {
      gqlClient().mutate.mockResolvedValue(
        mutationResponse({ policy: null, errors: ['Name has already been taken'] }),
      );

      const promise = createPolicy(1, params);

      await expect(promise).rejects.toThrow(PolicyStoreMutationError);
      await expect(promise).rejects.toThrow('Name has already been taken');
    });

    it('joins multiple store messages so none is silently dropped', async () => {
      gqlClient().mutate.mockResolvedValue(
        mutationResponse({ policy: null, errors: ['Name is too long', 'Rules is invalid'] }),
      );

      await expect(createPolicy(1, params)).rejects.toThrow('Name is too long, Rules is invalid');
    });

    it('rejects with the request error when the mutation fails', async () => {
      gqlClient().mutate.mockRejectedValue(new Error('network down'));

      await expect(createPolicy(1, params)).rejects.toThrow('network down');
    });
  });

  describe('updatePolicy', () => {
    const params = { name: 'Renamed gate' };

    it('patches the params and maps the updated policy like the list', async () => {
      mock.onPatch(POLICY_URL).reply(HTTP_STATUS_OK, { ...apiPolicy, name: 'Renamed gate' });

      const policy = await updatePolicy(1, 7, params);

      expect(JSON.parse(mock.history.patch[0].data)).toEqual(params);
      expect(policy).toMatchObject({ id: 7, name: 'Renamed gate', type: 'Deployment requested' });
    });

    it('rejects with the request error when the API fails', async () => {
      mock.onPatch(POLICY_URL).reply(HTTP_STATUS_INTERNAL_SERVER_ERROR);

      await expect(updatePolicy(1, 7, params)).rejects.toThrow();
    });
  });
});
