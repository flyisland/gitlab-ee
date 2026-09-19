import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlAlert } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import App from 'ee/policy_store/components/list/app.vue';
import ListWrapper from 'ee/policy_store/components/list/list_wrapper.vue';
import getPolicyStorePolicies from 'ee/policy_store/graphql/get_policy_store_policies.query.graphql';
import { MOCK_EVALUATIONS_THIS_WEEK } from 'ee/policy_store/mock_data';

Vue.use(VueApollo);
jest.mock('~/sentry/sentry_browser_wrapper');

describe('PolicyStoreListRoot', () => {
  let wrapper;

  const apiPolicy = (overrides = {}) => ({
    __typename: 'GovernPolicy',
    id: 1,
    // The query document is shared with the detail read, so a mocked response
    // has to carry its whole selection set or Apollo cannot fulfil the query.
    organizationId: 1,
    namespaceId: null,
    name: 'Production gate',
    description: 'Gates production deployments',
    version: 1,
    triggerType: 'deployment_requested',
    rules: [{ type: 'custom', value: 'package governance' }],
    policyRego: 'package governance\n',
    actions: [{ type: 'block' }],
    mode: 'enforce',
    lifecycleState: 'active',
    policyScope: { projects: { including: [1, 2] } },
    scopeRego: 'package gitlab.scope\n',
    scopeDimensions: null,
    createdAt: '2026-08-10T10:00:00Z',
    updatedAt: '2026-08-11T10:00:00Z',
    ...overrides,
  });

  // The list renders the derived fields on top of the raw policy fields, which
  // keep the snake_case shape the REST wrapper produced because the row details
  // (config_info.vue) deserialize trigger_type, rules and actions from them.
  const listPolicy = (overrides = {}) => ({
    id: 1,
    name: 'Production gate',
    mode: 'enforce',
    trigger_type: 'deployment_requested',
    rules: [{ type: 'custom', value: 'package governance' }],
    actions: [{ type: 'block' }],
    updated_at: '2026-08-11T10:00:00Z',
    type: 'Deployment requested',
    status: 'active',
    scopedProjectsCount: 2,
    detailPath: '',
    ...overrides,
  });

  const remoteTriggers = [
    {
      __typename: 'PolicyStoreTrigger',
      id: 'merge_requested',
      name: 'Merge Request',
    },
  ];

  const policiesResponse = (policies, triggers = remoteTriggers) => ({
    data: {
      organization: {
        __typename: 'Organization',
        id: 'gid://gitlab/Organizations::Organization/1',
        policyStore: {
          __typename: 'PolicyStore',
          policies,
          triggers,
        },
      },
    },
  });

  const findList = () => wrapper.findComponent(ListWrapper);
  const findError = () => wrapper.findComponent(GlAlert);

  const createComponent = ({ handler, provide = {} } = {}) => {
    wrapper = shallowMount(App, {
      apolloProvider: createMockApollo([[getPolicyStorePolicies, handler]]),
      provide: { organizationId: '1', ...provide },
    });
  };

  it('fetches the organization policies and passes them to the list with a detail path', async () => {
    const handler = jest
      .fn()
      .mockResolvedValue(policiesResponse([apiPolicy(), apiPolicy({ id: 2, name: 'Merge gate' })]));

    createComponent({ handler, provide: { listPath: '/-/security/policy_store' } });
    await waitForPromises();

    expect(handler).toHaveBeenCalledWith({ id: 'gid://gitlab/Organizations::Organization/1' });
    expect(findList().props('policies')).toEqual([
      listPolicy({ detailPath: '/-/security/policy_store/1' }),
      listPolicy({ id: 2, name: 'Merge gate', detailPath: '/-/security/policy_store/2' }),
    ]);
    expect(findList().props('evaluationsThisWeek')).toBe(MOCK_EVALUATIONS_THIS_WEEK);
    expect(findList().props('loading')).toBe(false);
    expect(findError().exists()).toBe(false);
  });

  it('labels a trigger the local catalog does not know with the API-provided name, then the raw id', async () => {
    const handler = jest
      .fn()
      .mockResolvedValue(
        policiesResponse([
          apiPolicy({ triggerType: 'merge_requested' }),
          apiPolicy({ id: 2, triggerType: 'unknown_trigger' }),
        ]),
      );

    createComponent({ handler });
    await waitForPromises();

    expect(findList().props('policies')).toEqual([
      listPolicy({ trigger_type: 'merge_requested', type: 'Merge Request' }),
      listPolicy({ id: 2, trigger_type: 'unknown_trigger', type: 'unknown_trigger' }),
    ]);
  });

  it('falls back to the local catalog label when the response carries no triggers', async () => {
    const handler = jest
      .fn()
      .mockResolvedValue(
        policiesResponse([apiPolicy(), apiPolicy({ id: 2, triggerType: 'merge_requested' })], null),
      );

    createComponent({ handler });
    await waitForPromises();

    expect(findList().props('policies')).toEqual([
      listPolicy(),
      listPolicy({ id: 2, trigger_type: 'merge_requested', type: 'merge_requested' }),
    ]);
  });

  it('counts no scoped projects when the policy scope has none', async () => {
    const handler = jest
      .fn()
      .mockResolvedValue(policiesResponse([apiPolicy({ policyScope: null })]));

    createComponent({ handler });
    await waitForPromises();

    expect(findList().props('policies')).toEqual([listPolicy({ scopedProjectsCount: 0 })]);
  });

  it('marks the list as loading while the query is in flight', () => {
    createComponent({ handler: jest.fn().mockReturnValue(new Promise(() => {})) });

    expect(findList().props('loading')).toBe(true);
  });

  it('leaves the detail path blank when no list path is provided', async () => {
    createComponent({ handler: jest.fn().mockResolvedValue(policiesResponse([apiPolicy()])) });
    await waitForPromises();

    expect(findList().props('policies')).toEqual([listPolicy()]);
  });

  it('passes the new policy path to the list', async () => {
    createComponent({
      handler: jest.fn().mockResolvedValue(policiesResponse([])),
      provide: { newPolicyPath: '/-/security/policy_store/new' },
    });
    await waitForPromises();

    expect(findList().props('newPolicyPath')).toBe('/-/security/policy_store/new');
  });

  it('shows the error alert and reports to Sentry when the query fails', async () => {
    createComponent({ handler: jest.fn().mockRejectedValue(new Error('API is down')) });
    await waitForPromises();

    expect(findError().text()).toContain(
      'The policies could not be fetched from the Policy Store API.',
    );
    expect(findList().props('policies')).toEqual([]);
    expect(findList().props('error')).toBe(true);
    expect(findList().props('loading')).toBe(false);
    expect(Sentry.captureException).toHaveBeenCalledTimes(1);
    expect(Sentry.captureException).toHaveBeenCalledWith(
      expect.objectContaining({ message: expect.stringContaining('API is down') }),
    );
  });

  it('clears previously loaded rows when a refetch fails', async () => {
    const handler = jest
      .fn()
      .mockResolvedValueOnce(policiesResponse([apiPolicy()]))
      .mockRejectedValue(new Error('API is down'));

    createComponent({ handler });
    await waitForPromises();

    expect(findList().props('policies')).toEqual([listPolicy()]);

    wrapper.vm.$apollo.queries.policies.refetch().catch(() => {});
    await waitForPromises();

    expect(findList().props('policies')).toEqual([]);
    expect(findList().props('error')).toBe(true);
  });

  it('refetches when the retry button on the error alert is clicked', async () => {
    const handler = jest
      .fn()
      .mockRejectedValueOnce(new Error('API is down'))
      .mockResolvedValue(policiesResponse([apiPolicy()]));

    createComponent({ handler });
    await waitForPromises();

    expect(findError().props('primaryButtonText')).toBe('Retry');

    findError().vm.$emit('primary-action');
    await waitForPromises();

    expect(handler).toHaveBeenCalledTimes(2);
    expect(findList().props('policies')).toEqual([listPolicy()]);
    expect(findError().exists()).toBe(false);
  });

  // The resolver nulls the field instead of raising when the viewer lacks
  // read_govern_policy or the experiment is off, so a null payload is the only
  // permission signal the read API gives.
  it.each([
    ['the policies are null', policiesResponse(null)],
    [
      'the policy store is null',
      {
        data: {
          organization: {
            __typename: 'Organization',
            id: 'gid://gitlab/Organizations::Organization/1',
            policyStore: null,
          },
        },
      },
    ],
    ['the organization is null', { data: { organization: null } }],
  ])('shows a permission message and skips Sentry when %s', async (_, response) => {
    createComponent({ handler: jest.fn().mockResolvedValue(response) });
    await waitForPromises();

    expect(findError().text()).toContain(
      'You do not have permission to view the policies of this organization.',
    );
    expect(findError().props('primaryButtonText')).toBe(null);
    expect(findList().props('policies')).toEqual([]);
    expect(Sentry.captureException).not.toHaveBeenCalled();
  });
});
