import * as Sentry from '~/sentry/sentry_browser_wrapper';
import {
  apiErrorMessage,
  EMPTY_CATALOGS,
  isDuplicateNameError,
  PolicyStoreMutationError,
  toCatalogs,
} from 'ee/policy_store/utils';
import { ACTIONS } from 'ee/policy_store/catalog/actions';
import { RULES } from 'ee/policy_store/catalog/rules';
import { TRIGGERS } from 'ee/policy_store/catalog/triggers';

jest.mock('~/sentry/sentry_browser_wrapper');

describe('apiErrorMessage', () => {
  const errorWithData = (data) => ({ response: { data } });

  it.each`
    description                          | error                                                        | expected
    ${'the store message'}               | ${errorWithData({ message: 'Name has already been taken' })} | ${'Name has already been taken'}
    ${'the Grape validation error'}      | ${errorWithData({ error: 'name is missing' })}               | ${'name is missing'}
    ${'message over error when both'}    | ${errorWithData({ message: 'taken', error: 'missing' })}     | ${'taken'}
    ${'nothing for a non-string reason'} | ${errorWithData({ message: { nested: true } })}              | ${undefined}
    ${'nothing without response data'}   | ${new Error('network down')}                                 | ${undefined}
  `('returns $description', ({ error, expected }) => {
    expect(apiErrorMessage(error)).toBe(expected);
  });

  it('returns the store message a rejected mutation carries', () => {
    const error = new PolicyStoreMutationError('Name has already been taken');

    expect(apiErrorMessage(error)).toBe('Name has already been taken');
  });
});

describe('policy store catalogs', () => {
  const healthyPolicyStore = ({
    triggers = [{ id: 'deployment_requested', name: 'Deployment' }],
    rules = [{ id: 'custom', name: 'Custom' }],
    actions = [{ id: 'block', name: 'Block' }],
  } = {}) => ({ triggers, rules, actions });

  it('exposes empty catalogs for consumers to start from', () => {
    expect(EMPTY_CATALOGS).toEqual({ triggers: [], rules: [], actions: [] });
  });

  it('presents an id the local catalog knows with its full local entry', () => {
    const { catalogs, failedCatalogs } = toCatalogs(
      healthyPolicyStore({
        rules: [
          { id: 'calendar', name: 'Calendar' },
          { id: 'environment', name: 'Environment' },
        ],
      }),
    );

    expect(failedCatalogs).toEqual([]);
    expect(catalogs.triggers).toEqual([TRIGGERS.find(({ id }) => id === 'deployment_requested')]);
    expect(catalogs.rules).toEqual([
      RULES.find(({ id }) => id === 'calendar'),
      RULES.find(({ id }) => id === 'environment'),
    ]);
    expect(catalogs.actions).toEqual([ACTIONS.find(({ id }) => id === 'block')]);
  });

  it('presents an unknown id as a minimal entry named by the API', () => {
    const { catalogs } = toCatalogs(
      healthyPolicyStore({ rules: [{ id: 'holiday', name: 'Holiday' }] }),
    );

    expect(catalogs.rules).toEqual([
      { id: 'holiday', label: 'Holiday', description: '', icon: 'question-o', fields: [] },
    ]);
  });

  it('drops entries without an id, which cannot serve as the wire value', () => {
    const { catalogs } = toCatalogs(
      healthyPolicyStore({
        rules: [{}, { name: 'No id' }, { id: 'custom', name: 'Custom' }, null],
      }),
    );

    expect(catalogs.rules).toEqual([RULES.find(({ id }) => id === 'custom')]);
  });

  it('names an empty catalog as failed while the others keep their entries', () => {
    const { catalogs, failedCatalogs } = toCatalogs(healthyPolicyStore({ triggers: [] }));

    expect(failedCatalogs).toEqual(['triggers']);
    expect(catalogs.triggers).toEqual([]);
    expect(catalogs.rules).toEqual([RULES.find(({ id }) => id === 'custom')]);
    expect(catalogs.actions).toEqual([ACTIONS.find(({ id }) => id === 'block')]);
    expect(Sentry.captureException).toHaveBeenCalledWith(expect.any(Error), {
      tags: { policyStoreCatalog: 'triggers' },
    });
  });

  it('names every failing catalog when several are empty', () => {
    const { failedCatalogs } = toCatalogs(healthyPolicyStore({ triggers: [], actions: [] }));

    expect(failedCatalogs).toEqual(['triggers', 'actions']);
  });

  it('treats a catalog with only unusable entries as failed', () => {
    const { failedCatalogs } = toCatalogs(healthyPolicyStore({ actions: [{}, { name: 'No id' }] }));

    expect(failedCatalogs).toEqual(['actions']);
  });

  it('treats a malformed catalog as failed', () => {
    const { failedCatalogs } = toCatalogs(healthyPolicyStore({ triggers: { not: 'an array' } }));

    expect(failedCatalogs).toEqual(['triggers']);
    expect(Sentry.captureException).toHaveBeenCalledWith(expect.any(Error), {
      tags: { policyStoreCatalog: 'triggers' },
    });
  });

  it('fails every catalog for a null policyStore, as when the experiment is off', () => {
    const { catalogs, failedCatalogs } = toCatalogs(null);

    expect(failedCatalogs).toEqual(['triggers', 'rules', 'actions']);
    expect(catalogs).toEqual(EMPTY_CATALOGS);
  });
});

describe('isDuplicateNameError', () => {
  it.each`
    description                                          | message                                                                    | expected
    ${'the bare message both backends raise'}            | ${'Name has already been taken'}                                           | ${true}
    ${'the bare message regardless of case and padding'} | ${' name HAS already been taken '}                                         | ${true}
    ${'a sentence combining it with other failures'}     | ${'Name has already been taken and Namespace must match the organization'} | ${false}
    ${'an unrelated validation message'}                 | ${'rule 0: unsupported rule type "calendar"'}                              | ${false}
    ${'no message at all'}                               | ${undefined}                                                               | ${false}
  `('recognises $description as $expected', ({ message, expected }) => {
    expect(isDuplicateNameError(message)).toBe(expected);
  });
});
