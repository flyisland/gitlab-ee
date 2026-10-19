import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlAlert } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import waitForPromises from 'helpers/wait_for_promises';
import { useFakeDate } from 'helpers/fake_date';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import * as evaluations from 'ee/policy_store/evaluations';
import App from 'ee/policy_store/components/list/app.vue';
import ListWrapper from 'ee/policy_store/components/list/list_wrapper.vue';
import getPolicyStorePolicies from 'ee/policy_store/graphql/get_policy_store_policies.query.graphql';
import getGroupPolicyStorePolicies from 'ee/policy_store/graphql/get_group_policy_store_policies.query.graphql';
import getPolicyEvaluationsCount from 'ee/policy_store/graphql/get_policy_evaluations_count.query.graphql';
import getGroupPolicyEvaluationsCount from 'ee/policy_store/graphql/get_group_policy_evaluations_count.query.graphql';
import { createPolicyStoreMockApollo } from '../../mock_apollo';

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

  const pageInfo = (overrides = {}) => ({
    __typename: 'PageInfo',
    hasNextPage: false,
    endCursor: null,
    ...overrides,
  });

  // A null connection, not an empty one, is the resolver's permission signal.
  const policiesConnection = (nodes, pageInfoOverrides) =>
    nodes === null
      ? null
      : { __typename: 'GovernPolicyConnection', nodes, pageInfo: pageInfo(pageInfoOverrides) };

  const policiesResponse = (policies, triggers = remoteTriggers, pageInfoOverrides = {}) => ({
    data: {
      organization: {
        __typename: 'Organization',
        id: 'gid://gitlab/Organizations::Organization/1',
        policyStore: {
          __typename: 'PolicyStore',
          policies: policiesConnection(policies, pageInfoOverrides),
          triggers,
        },
      },
    },
  });

  // A null count stands for a null connection, the resolver's permission signal.
  const evaluationsConnection = (count) =>
    count === null ? null : { __typename: 'GovernPolicyEvaluationConnection', count };

  const evaluationsCountResponse = (count) => ({
    data: {
      organization: {
        __typename: 'Organization',
        id: 'gid://gitlab/Organizations::Organization/1',
        policyStore: { __typename: 'PolicyStore', policyEvaluations: evaluationsConnection(count) },
      },
    },
  });

  const groupPoliciesResponse = (policies, triggers = remoteTriggers, pageInfoOverrides = {}) => ({
    data: {
      group: {
        __typename: 'Group',
        id: 'gid://gitlab/Group/42',
        policyStore: {
          __typename: 'PolicyStore',
          policies: policiesConnection(policies, pageInfoOverrides),
          triggers,
        },
      },
    },
  });

  const groupEvaluationsCountResponse = (count) => ({
    data: {
      group: {
        __typename: 'Group',
        id: 'gid://gitlab/Group/42',
        policyStore: { __typename: 'PolicyStore', policyEvaluations: evaluationsConnection(count) },
      },
    },
  });

  const findList = () => wrapper.findComponent(ListWrapper);
  const findError = () => wrapper.findComponent(GlAlert);

  const createComponent = ({
    handler,
    evaluationsHandler = jest.fn().mockResolvedValue(evaluationsCountResponse(0)),
    provide = {},
  } = {}) => {
    wrapper = shallowMount(App, {
      apolloProvider: createPolicyStoreMockApollo([
        [getPolicyStorePolicies, handler],
        [getPolicyEvaluationsCount, evaluationsHandler],
      ]),
      provide: { organizationId: '1', namespaceType: 'organization', ...provide },
    });
  };

  const createGroupComponent = ({
    handler,
    evaluationsHandler = jest.fn().mockResolvedValue(groupEvaluationsCountResponse(0)),
    provide = {},
  } = {}) => {
    wrapper = shallowMount(App, {
      apolloProvider: createPolicyStoreMockApollo([
        [getGroupPolicyStorePolicies, handler],
        [getGroupPolicyEvaluationsCount, evaluationsHandler],
      ]),
      provide: {
        organizationId: '1',
        namespacePath: 'my-org/my-group',
        namespaceType: 'group',
        ...provide,
      },
    });
  };

  it('fetches the organization policies and passes them to the list with a detail path', async () => {
    const handler = jest
      .fn()
      .mockResolvedValue(policiesResponse([apiPolicy(), apiPolicy({ id: 2, name: 'Merge gate' })]));

    createComponent({ handler, provide: { listPath: '/-/security/policy_store' } });
    await waitForPromises();

    expect(handler).toHaveBeenCalledWith({
      id: 'gid://gitlab/Organizations::Organization/1',
      first: 20,
    });
    expect(findList().props('policies')).toEqual([
      listPolicy({ detailPath: '/-/security/policy_store/1' }),
      listPolicy({ id: 2, name: 'Merge gate', detailPath: '/-/security/policy_store/2' }),
    ]);
    expect(findList().props('recentEvaluations')).toBe(0);
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

  describe('load more', () => {
    const firstPage = policiesResponse([apiPolicy()], remoteTriggers, {
      hasNextPage: true,
      endCursor: 'cursor-1',
    });
    const secondPage = policiesResponse([apiPolicy({ id: 2, name: 'Merge gate' })]);

    it('offers to load more only while the connection reports a next page', async () => {
      createComponent({ handler: jest.fn().mockResolvedValue(secondPage) });
      await waitForPromises();

      expect(findList().props('hasNextPage')).toBe(false);
    });

    it('appends the next page to the loaded rows when the list asks for more', async () => {
      const handler = jest.fn().mockResolvedValueOnce(firstPage).mockResolvedValueOnce(secondPage);

      createComponent({ handler });
      await waitForPromises();

      expect(findList().props('hasNextPage')).toBe(true);

      findList().vm.$emit('load-more');
      await nextTick();

      expect(findList().props('loadingMore')).toBe(true);
      expect(findList().props('loading')).toBe(false);

      await waitForPromises();

      expect(handler).toHaveBeenLastCalledWith({
        id: 'gid://gitlab/Organizations::Organization/1',
        first: 20,
        after: 'cursor-1',
      });
      expect(findList().props('policies')).toEqual([
        listPolicy(),
        listPolicy({ id: 2, name: 'Merge gate' }),
      ]);
      expect(findList().props('hasNextPage')).toBe(false);
      expect(findList().props('loadingMore')).toBe(false);
    });

    it('requests each further page from the cursor the previous one returned', async () => {
      const handler = jest
        .fn()
        .mockResolvedValueOnce(firstPage)
        .mockResolvedValueOnce(
          policiesResponse([apiPolicy({ id: 2, name: 'Merge gate' })], remoteTriggers, {
            hasNextPage: true,
            endCursor: 'cursor-2',
          }),
        )
        .mockResolvedValueOnce(policiesResponse([apiPolicy({ id: 3, name: 'Release gate' })]));

      createComponent({ handler });
      await waitForPromises();

      findList().vm.$emit('load-more');
      await waitForPromises();
      findList().vm.$emit('load-more');
      await waitForPromises();

      expect(handler).toHaveBeenCalledTimes(3);
      expect(handler).toHaveBeenLastCalledWith({
        id: 'gid://gitlab/Organizations::Organization/1',
        first: 20,
        after: 'cursor-2',
      });
      expect(findList().props('policies')).toEqual([
        listPolicy(),
        listPolicy({ id: 2, name: 'Merge gate' }),
        listPolicy({ id: 3, name: 'Release gate' }),
      ]);
      expect(findList().props('hasNextPage')).toBe(false);
    });

    it('drops a row the shifting page boundary repeats', async () => {
      const handler = jest
        .fn()
        .mockResolvedValueOnce(firstPage)
        .mockResolvedValueOnce(
          policiesResponse([apiPolicy(), apiPolicy({ id: 2, name: 'Merge gate' })]),
        );

      createComponent({ handler });
      await waitForPromises();

      findList().vm.$emit('load-more');
      await waitForPromises();

      expect(findList().props('policies')).toEqual([
        listPolicy(),
        listPolicy({ id: 2, name: 'Merge gate' }),
      ]);
    });

    it('starts over from the first page when the list is retried after loading more', async () => {
      const handler = jest
        .fn()
        .mockResolvedValueOnce(firstPage)
        .mockResolvedValueOnce(secondPage)
        .mockResolvedValueOnce(firstPage);

      createComponent({ handler });
      await waitForPromises();

      findList().vm.$emit('load-more');
      await waitForPromises();

      expect(findList().props('policies')).toHaveLength(2);

      wrapper.vm.$apollo.queries.policies.refetch();
      await waitForPromises();

      expect(handler).toHaveBeenLastCalledWith({
        id: 'gid://gitlab/Organizations::Organization/1',
        first: 20,
      });
      expect(findList().props('policies')).toEqual([listPolicy()]);
      expect(findList().props('hasNextPage')).toBe(true);
    });

    it('keeps the loaded rows and retries the same page when loading more fails', async () => {
      const handler = jest
        .fn()
        .mockResolvedValueOnce(firstPage)
        .mockRejectedValueOnce(new Error('API is down'))
        .mockResolvedValueOnce(
          policiesResponse([apiPolicy({ id: 2, name: 'Merge gate' })], remoteTriggers, {
            hasNextPage: true,
            endCursor: 'cursor-2',
          }),
        );

      createComponent({ handler });
      await waitForPromises();

      findList().vm.$emit('load-more');
      await waitForPromises();

      expect(findError().text()).toContain(
        'The policies could not be fetched from the Policy Store API.',
      );
      expect(findList().props('policies')).toEqual([listPolicy()]);
      // The alert's Retry owns the retry while it shows, so the button steps aside.
      expect(findList().props('hasNextPage')).toBe(false);
      expect(findList().props('loadingMore')).toBe(false);
      expect(Sentry.captureException).toHaveBeenCalledTimes(1);

      findError().vm.$emit('primary-action');
      await waitForPromises();

      expect(handler).toHaveBeenLastCalledWith({
        id: 'gid://gitlab/Organizations::Organization/1',
        first: 20,
        after: 'cursor-1',
      });
      expect(findError().exists()).toBe(false);
      expect(findList().props('policies')).toEqual([
        listPolicy(),
        listPolicy({ id: 2, name: 'Merge gate' }),
      ]);
      expect(findList().props('hasNextPage')).toBe(true);
    });
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

    expect(findError().text()).toContain('You do not have permission to view the policies.');
    expect(findError().props('primaryButtonText')).toBe(null);
    expect(findList().props('policies')).toEqual([]);
    expect(Sentry.captureException).not.toHaveBeenCalled();
  });

  // Both containers share the stat's behaviour; the table keeps the two suites
  // from drifting apart.
  describe.each`
    context           | create                  | response                 | countResponse                    | scope
    ${'organization'} | ${createComponent}      | ${policiesResponse}      | ${evaluationsCountResponse}      | ${{ id: 'gid://gitlab/Organizations::Organization/1' }}
    ${'group'}        | ${createGroupComponent} | ${groupPoliciesResponse} | ${groupEvaluationsCountResponse} | ${{ fullPath: 'my-org/my-group' }}
  `('recent evaluations in $context context', ({ create, response, countResponse, scope }) => {
    useFakeDate(2026, 8, 9);

    const createWithEvaluations = (evaluationsHandler) => {
      create({ handler: jest.fn().mockResolvedValue(response([apiPolicy()])), evaluationsHandler });

      return waitForPromises();
    };

    it('reads the count of evaluations recorded in the last seven days', async () => {
      const evaluationsHandler = jest.fn().mockResolvedValue(countResponse(3));

      await createWithEvaluations(evaluationsHandler);

      expect(evaluationsHandler).toHaveBeenCalledWith({
        ...scope,
        evaluatedAfter: '2026-09-03T00:00:00.000Z',
        limit: 1000,
      });
      expect(findList().props('recentEvaluations')).toBe(3);
    });

    it('marks the stat loading until the count arrives', async () => {
      create({
        handler: jest.fn().mockResolvedValue(response([apiPolicy()])),
        evaluationsHandler: jest.fn().mockResolvedValue(countResponse(3)),
      });

      expect(findList().props('recentEvaluationsLoading')).toBe(true);

      await waitForPromises();

      expect(findList().props('recentEvaluationsLoading')).toBe(false);
    });

    it('reads an unreadable connection as unknown rather than zero', async () => {
      await createWithEvaluations(jest.fn().mockResolvedValue(countResponse(null)));

      expect(findList().props('recentEvaluations')).toBe(null);
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });

    // The stat must not take the page down with it, and must not answer with a
    // confident zero: the policies query owns the error state.
    it('leaves the list intact and reports to Sentry when the count fails', async () => {
      const error = new Error('Evaluations are down');

      await createWithEvaluations(jest.fn().mockRejectedValue(error));

      expect(Sentry.captureException).toHaveBeenCalledWith(error);
      expect(findList().props('recentEvaluations')).toBe(null);
      expect(findList().props('policies')).toEqual([listPolicy()]);
      expect(findError().exists()).toBe(false);
    });

    it('refetches the count when the user retries', async () => {
      const evaluationsHandler = jest
        .fn()
        .mockRejectedValueOnce(new Error('Evaluations are down'))
        .mockResolvedValue(countResponse(5));

      create({
        handler: jest
          .fn()
          .mockRejectedValueOnce(new Error('down'))
          .mockResolvedValue(response([apiPolicy()])),
        evaluationsHandler,
      });
      await waitForPromises();

      findError().vm.$emit('primary-action');
      await waitForPromises();

      expect(evaluationsHandler).toHaveBeenCalledTimes(2);
      expect(findList().props('recentEvaluations')).toBe(5);
    });

    // A bare refetch() reuses the variables computed at mount, so without
    // passing them again a tab left open overnight keeps asking for yesterday.
    it('recomputes the window on retry rather than reusing the one from mount', async () => {
      let windowStart = '2026-09-03T00:00:00.000Z';
      jest.spyOn(evaluations, 'startOfReportingWindow').mockImplementation(() => windowStart);

      const evaluationsHandler = jest
        .fn()
        .mockRejectedValueOnce(new Error('Evaluations are down'))
        .mockResolvedValue(countResponse(5));

      create({
        handler: jest
          .fn()
          .mockRejectedValueOnce(new Error('down'))
          .mockResolvedValue(response([apiPolicy()])),
        evaluationsHandler,
      });
      await waitForPromises();

      windowStart = '2026-09-04T00:00:00.000Z';
      findError().vm.$emit('primary-action');
      await waitForPromises();

      expect(evaluationsHandler).toHaveBeenLastCalledWith({
        ...scope,
        evaluatedAfter: '2026-09-04T00:00:00.000Z',
        limit: 1000,
      });
    });

    // Apollo re-emits the last good count after a failed refetch, so the error
    // hook has to clear it rather than leave a number nobody can vouch for.
    it('drops a count it already showed when a later read fails', async () => {
      create({
        handler: jest
          .fn()
          .mockRejectedValueOnce(new Error('down'))
          .mockResolvedValue(response([apiPolicy()])),
        evaluationsHandler: jest
          .fn()
          .mockResolvedValueOnce(countResponse(5))
          .mockRejectedValue(new Error('Evaluations are down')),
      });
      await waitForPromises();

      expect(findList().props('recentEvaluations')).toBe(5);

      findError().vm.$emit('primary-action');
      await waitForPromises();

      expect(findList().props('recentEvaluations')).toBe(null);
    });

    // Retry serves a failed page first; the stat must not be left behind.
    it('refetches a failed count when the user retries a failed Load more', async () => {
      const evaluationsHandler = jest
        .fn()
        .mockRejectedValueOnce(new Error('Evaluations are down'))
        .mockResolvedValue(countResponse(5));
      const handler = jest
        .fn()
        .mockResolvedValueOnce(
          response([apiPolicy()], remoteTriggers, { hasNextPage: true, endCursor: 'cursor-1' }),
        )
        .mockRejectedValueOnce(new Error('API is down'))
        .mockResolvedValue(response([apiPolicy({ id: 2, name: 'Merge gate' })]));

      create({ handler, evaluationsHandler });
      await waitForPromises();

      findList().vm.$emit('load-more');
      await waitForPromises();

      expect(findList().props('recentEvaluations')).toBe(null);

      findError().vm.$emit('primary-action');
      await waitForPromises();

      expect(evaluationsHandler).toHaveBeenCalledTimes(2);
      expect(findList().props('recentEvaluations')).toBe(5);
      expect(findList().props('policies')).toEqual([
        listPolicy(),
        listPolicy({ id: 2, name: 'Merge gate' }),
      ]);
    });
  });

  describe('when in group context', () => {
    it('fetches the group policies using the group query', async () => {
      const handler = jest.fn().mockResolvedValue(groupPoliciesResponse([apiPolicy()]));

      createGroupComponent({ handler, provide: { listPath: '/-/security/policy_store' } });
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith({ fullPath: 'my-org/my-group', first: 20 });
      expect(findList().props('policies')).toEqual([
        listPolicy({ detailPath: '/-/security/policy_store/1' }),
      ]);
      expect(findError().exists()).toBe(false);
    });

    // The triggers arrive with the policies write and the count with the
    // evaluations write; without the Group merge policy in apollo.js the later
    // write drops the triggers, which costs a second policies read and, until
    // it lands, the raw id as the label. Only an id the local catalog can never
    // know proves the label came from the store.
    it('keeps the store-provided trigger label once the evaluations count lands', async () => {
      const handler = jest
        .fn()
        .mockResolvedValue(
          groupPoliciesResponse(
            [apiPolicy({ triggerType: 'remote_only_trigger' })],
            [{ __typename: 'PolicyStoreTrigger', id: 'remote_only_trigger', name: 'Remote only' }],
          ),
        );

      createGroupComponent({
        handler,
        evaluationsHandler: jest.fn().mockResolvedValue(groupEvaluationsCountResponse(3)),
      });
      await waitForPromises();
      // Apollo notifies the other watcher of a cache change on a zero timer.
      jest.runOnlyPendingTimers();
      await waitForPromises();

      expect(handler).toHaveBeenCalledTimes(1);
      expect(findList().props('recentEvaluations')).toBe(3);
      expect(findList().props('policies')).toEqual([
        listPolicy({ trigger_type: 'remote_only_trigger', type: 'Remote only' }),
      ]);
    });

    const deniedResponse = {
      data: {
        group: {
          __typename: 'Group',
          id: 'gid://gitlab/Group/42',
          policyStore: null,
        },
      },
    };

    // One resolver nulls group.policyStore for every query on the page, so the
    // policies and evaluations responses are normally denied together.
    it('shows a permission message and an unknown count when the group policy store is null', async () => {
      createGroupComponent({
        handler: jest.fn().mockResolvedValue(deniedResponse),
        evaluationsHandler: jest.fn().mockResolvedValue(deniedResponse),
      });
      await waitForPromises();

      expect(findError().text()).toContain('You do not have permission to view the policies.');
      expect(findList().props('policies')).toEqual([]);
      expect(findList().props('recentEvaluations')).toBe(null);
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });

    // The experiment flag is read per request, so a flip between the two reads
    // can deny only the later one. Both write the same policyStore; the cache
    // merge rule must not let that null replace the policies the earlier read
    // returned. The denial is held back so it is the later write.
    it('keeps the policies when only a later evaluations read is denied', async () => {
      let denyEvaluations;
      const evaluationsHandler = jest.fn().mockReturnValue(
        new Promise((resolve) => {
          denyEvaluations = () => resolve(deniedResponse);
        }),
      );

      createGroupComponent({
        handler: jest.fn().mockResolvedValue(groupPoliciesResponse([apiPolicy()])),
        evaluationsHandler,
      });
      await waitForPromises();

      expect(findList().props('policies')).toEqual([listPolicy()]);

      denyEvaluations();
      await waitForPromises();
      // Apollo notifies the other watcher of a cache change on a zero timer.
      jest.runOnlyPendingTimers();
      await nextTick();

      expect(findError().exists()).toBe(false);
      expect(findList().props('policies')).toEqual([listPolicy()]);
      expect(findList().props('recentEvaluations')).toBe(null);
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });

    describe('load more', () => {
      const firstPage = groupPoliciesResponse([apiPolicy()], remoteTriggers, {
        hasNextPage: true,
        endCursor: 'cursor-1',
      });
      const secondPage = groupPoliciesResponse([apiPolicy({ id: 2, name: 'Merge gate' })]);

      it('appends the next page to the loaded rows when the list asks for more', async () => {
        const handler = jest
          .fn()
          .mockResolvedValueOnce(firstPage)
          .mockResolvedValueOnce(secondPage);

        createGroupComponent({ handler });
        await waitForPromises();

        expect(findList().props('hasNextPage')).toBe(true);

        findList().vm.$emit('load-more');
        await waitForPromises();

        expect(handler).toHaveBeenLastCalledWith({
          fullPath: 'my-org/my-group',
          first: 20,
          after: 'cursor-1',
        });
        expect(findList().props('policies')).toEqual([
          listPolicy(),
          listPolicy({ id: 2, name: 'Merge gate' }),
        ]);
        expect(findList().props('hasNextPage')).toBe(false);
        expect(findList().props('loadingMore')).toBe(false);
      });

      it('drops a row the shifting page boundary repeats', async () => {
        const handler = jest
          .fn()
          .mockResolvedValueOnce(firstPage)
          .mockResolvedValueOnce(
            groupPoliciesResponse([apiPolicy(), apiPolicy({ id: 2, name: 'Merge gate' })]),
          );

        createGroupComponent({ handler });
        await waitForPromises();

        findList().vm.$emit('load-more');
        await waitForPromises();

        expect(findList().props('policies')).toEqual([
          listPolicy(),
          listPolicy({ id: 2, name: 'Merge gate' }),
        ]);
      });

      it('keeps the loaded rows and shows the error alert when loading more fails', async () => {
        const handler = jest
          .fn()
          .mockResolvedValueOnce(firstPage)
          .mockRejectedValueOnce(new Error('API is down'));

        createGroupComponent({ handler });
        await waitForPromises();

        findList().vm.$emit('load-more');
        await waitForPromises();

        expect(findError().text()).toContain(
          'The policies could not be fetched from the Policy Store API.',
        );
        expect(findList().props('policies')).toEqual([listPolicy()]);
        expect(findList().props('hasNextPage')).toBe(false);
        expect(findList().props('loadingMore')).toBe(false);
        expect(Sentry.captureException).toHaveBeenCalledTimes(1);
      });
    });
  });
});
