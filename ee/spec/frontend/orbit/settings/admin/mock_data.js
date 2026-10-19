export const ENABLED_AT = '2026-10-01T10:00:00Z';

export const buildOrbit = (phase) => ({
  __typename: 'OrbitNamespace',
  enabledAt: ENABLED_AT,
  indexingStatus: phase ? { __typename: 'OrbitIndexingStatus', phase } : null,
});

export const buildGroup = ({ name = 'acme', ...overrides } = {}) => ({
  __typename: 'Group',
  id: `gid://gitlab/Group/${name}`,
  name,
  fullPath: name,
  webPath: `/${name}`,
  avatarUrl: null,
  knowledgeGraphEnabled: false,
  orbit: null,
  ...overrides,
});

export const buildOnGroup = (name, phase = 'READY') =>
  buildGroup({ name, knowledgeGraphEnabled: true, orbit: buildOrbit(phase) });

export const buildRow = ({ name = 'acme', ...overrides } = {}) => ({
  id: `gid://gitlab/Group/${name}`,
  name,
  fullPath: name,
  webPath: `/${name}`,
  avatarUrl: null,
  isOn: false,
  isExcluded: false,
  phase: null,
  enabledAt: null,
  failure: null,
  ...overrides,
});

export const groupsResponse = (nodes, pageInfo = {}) => ({
  data: {
    groups: {
      __typename: 'GroupConnection',
      nodes,
      pageInfo: {
        __typename: 'PageInfo',
        hasNextPage: false,
        hasPreviousPage: false,
        startCursor: null,
        endCursor: null,
        ...pageInfo,
      },
    },
  },
});

export const excludedGroupsResponse = (nodes, pageInfo = {}) => ({
  data: {
    knowledgeGraphExcludedNamespaces: {
      __typename: 'GroupConnection',
      nodes,
      pageInfo: { __typename: 'PageInfo', hasNextPage: false, endCursor: null, ...pageInfo },
    },
  },
});

export const orbitUpdateResponse = (errors = []) => ({
  data: { orbitUpdate: { __typename: 'OrbitUpdatePayload', group: null, errors } },
});

export const excludeResponse = (errors = []) => ({
  data: {
    knowledgeGraphExcludedNamespaceCreate: {
      __typename: 'KnowledgeGraphExcludedNamespaceCreatePayload',
      group: null,
      errors,
    },
  },
});

export const includeResponse = (errors = []) => ({
  data: {
    knowledgeGraphExcludedNamespaceDestroy: {
      __typename: 'KnowledgeGraphExcludedNamespaceDestroyPayload',
      group: null,
      errors,
    },
  },
});

export const orbitStatusResponse = {
  user: { available: true },
  system: {
    status: 'healthy',
    version: '0.128.0',
    components: [{ name: 'clickhouse', status: 'healthy', replicas: { ready: 1, desired: 1 } }],
  },
};
