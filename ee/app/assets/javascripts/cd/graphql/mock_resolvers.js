/* eslint-disable @gitlab/require-i18n-strings -- Mock data only; file will be deleted when backend ships. */
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

// Type policies for CD Service fields the backend does not expose yet. Each read
// returns the cached server value when present and otherwise a deterministic mock
// keyed off the service id. To remove when the backend ships these fields: delete
// this file, drop the cacheConfig in cd/index.js, and remove @client from the
// query files.

const mockByServiceId = (gid, options) => options[(getIdFromGraphQLId(gid) || 0) % options.length];

const MOCK_HEALTH = ['ok', 'alert', 'degraded', 'deploying'];
const MOCK_SYNC = ['synced', 'out-of-sync'];
const MOCK_SERVICE_TYPES = ['http-api', 'worker', 'frontend'];
const MOCK_DEPLOYED_BY = ['@taylor.smith', '@alice.chen', '@morgan.ray'];
const MOCK_ENV_TIERS = ['dev', 'qa', 'preprod', 'prod'];

const mockEnvironments = (gid) => {
  const n = getIdFromGraphQLId(gid) || 0;
  const tiers = MOCK_ENV_TIERS.slice(0, 2 + (n % 3));

  return tiers.map((tier, index) => ({
    tier,
    name: `${tier}-cluster-${n}`,
    version: `v${1 + (n % 5)}.${index}.0`,
    pods: `${index + 2}/${index + 2}`,
    restarts: tier === 'prod' && n % 2 === 1 ? '1 restart/h' : null,
    sync: index === tiers.length - 1 ? mockByServiceId(gid, MOCK_SYNC) : 'synced',
  }));
};

export const cdMockTypePolicies = {
  CdService: {
    fields: {
      sync: {
        read: (existing, { readField }) => existing ?? mockByServiceId(readField('id'), MOCK_SYNC),
      },
      health: {
        read: (existing, { readField }) =>
          existing ?? mockByServiceId(readField('id'), MOCK_HEALTH),
      },
      serviceType: {
        read: (existing, { readField }) =>
          existing ?? mockByServiceId(readField('id'), MOCK_SERVICE_TYPES),
      },
      deployedBy: {
        read: (existing, { readField }) =>
          existing ?? mockByServiceId(readField('id'), MOCK_DEPLOYED_BY),
      },
      lastDeployed: {
        read: (existing) => existing ?? '2026-06-01T10:00:00Z',
      },
      environments: {
        read: (existing, { readField }) => existing ?? mockEnvironments(readField('id')),
      },
    },
  },
};
