export const makeVersion = (overrides = {}) => ({
  id: 'v-1',
  name: 'v1.0.0',
  digest: 'sha256:abc123def456',
  reference: 'registry.example.com/image:v1',
  createdAt: '2024-06-01T12:00:00Z',
  ...overrides,
});

export const makeArtifactSource = (overrides = {}) => ({
  id: 'source-1',
  sourceRef: 'registry.example.com/api-server',
  sourceConfig: '{}',
  versions: {
    nodes: [makeVersion()],
  },
  ...overrides,
});

export const makeEnvironment = (overrides = {}) => ({
  name: 'production-1',
  tier: 'prod',
  version: 'v1.2.3',
  pods: 3,
  restarts: null,
  sync: 'synced',
  ...overrides,
});

export const makeService = (overrides = {}) => ({
  id: 'gid://gitlab/Cd::Service/1',
  name: 'api-server',
  health: 'ok',
  sync: 'synced',
  lastDeployed: '2024-06-10T08:00:00Z',
  deployedBy: 'admin',
  serviceType: 'http-api',
  updatedAt: '2024-06-10T08:00:00Z',
  artifactSources: {
    nodes: [makeArtifactSource()],
  },
  ...overrides,
});

export const makeApplication = (overrides = {}) => ({
  id: 'gid://gitlab/Cd::Application/5',
  name: 'My Application',
  description: 'An application',
  updatedAt: '2024-06-01T00:00:00Z',
  services: {
    nodes: [
      makeService({ id: 'gid://gitlab/Cd::Service/10', name: 'api-server' }),
      makeService({ id: 'gid://gitlab/Cd::Service/20', name: 'worker' }),
    ],
  },
  versionSets: {
    nodes: [
      {
        id: 'gid://gitlab/Cd::VersionSet/1',
        name: 'v1_1_0',
        createdAt: '2024-06-01T00:00:00Z',
        application: { name: 'My Application' },
        rollouts: { nodes: [{ state: 'IN_PROGRESS', id: 'gid://gitlab/Cd::Rollout/1' }] },
        versionSetEntries: {
          count: 2,
          nodes: [
            {
              service: { id: 'gid://gitlab/Cd::Service/10', name: 'api-server' },
              version: { id: 'gid://gitlab/Cd::Version/1', name: 'v2_4_1' },
            },
            {
              service: { id: 'gid://gitlab/Cd::Service/20', name: 'worker' },
              version: { id: 'gid://gitlab/Cd::Version/2', name: 'v1_9_0' },
            },
          ],
        },
      },
      {
        id: 'gid://gitlab/Cd::VersionSet/2',
        name: 'v1_0_0',
        createdAt: '2024-05-01T00:00:00Z',
        application: { name: 'My Application' },
        rollouts: { nodes: [{ state: 'COMPLETED', id: 'gid://gitlab/Cd::Rollout/2' }] },
        versionSetEntries: {
          count: 1,
          nodes: [
            {
              service: { id: 'gid://gitlab/Cd::Service/10', name: 'api-server' },
              version: { id: 'gid://gitlab/Cd::Version/3', name: 'v2_3_0' },
            },
          ],
        },
      },
    ],
  },
  ...overrides,
});

export const buildApplicationQueryResponse = (application = makeApplication()) => ({
  data: {
    organization: {
      id: 'gid://gitlab/Organization/1',
      cdApplication: application,
    },
  },
});

export const buildVersionSetQueryResponse = (versionSet) => ({
  data: {
    organization: {
      id: 'gid://gitlab/Organization/1',
      cdVersionSet: versionSet ?? null,
    },
  },
});

export const buildQueryResponse = (cdEnvironmentTiers) => ({
  data: {
    organization: {
      __typename: 'Organization',
      id: 'gid://gitlab/Organizations::Organization/1',
      cdEnvironmentTiers,
    },
  },
});

export const buildEnvironmentsQueryResponse = (nodes = []) => ({
  data: {
    organization: {
      __typename: 'Organization',
      id: 'gid://gitlab/Organizations::Organization/1',
      cdEnvironments: {
        __typename: 'CdEnvironmentConnection',
        nodes,
      },
    },
  },
});
