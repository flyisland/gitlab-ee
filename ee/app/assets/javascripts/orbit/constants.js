import { s__ } from '~/locale';

export const STATUS_HEALTHY = 'healthy';
export const STATUS_UNKNOWN = 'unknown';
export const TOON_BLOCK_PATTERN = /<toon>([\s\S]*?)<\/toon>/;

// --- Entity styling ---

// Backup colors used before the schema endpoint responds.
// Authoritative colors are returned via GET /api/v4/orbit/schema?expand=*
// from the GKG ontology YAML definitions and override these at runtime.
export const DEFAULT_NODE_COLOR = '#6B7280';

export const ENTITY_TYPE_COLORS = {
  // core
  user: '#10B981',
  project: '#3B82F6',
  group: '#8B5CF6',
  note: '#64748B',
  // code_review
  mergerequest: '#F59E0B',
  mergerequestdiff: '#D97706',
  mergerequestdifffile: '#B45309',
  // ci
  pipeline: '#6366F1',
  stage: '#818CF8',
  job: '#8B5CF6',
  // security
  vulnerability: '#DC2626',
  vulnerabilityoccurrence: '#EF4444',
  finding: '#F87171',
  vulnerabilityscanner: '#FCA5A5',
  vulnerabilityidentifier: '#7F1D1D',
  securityscan: '#B91C1C',
  // plan
  workitem: '#EC4899',
  milestone: '#D946EF',
  label: '#A855F7',
  // source_code
  branch: '#14B8A6',
  file: '#22D3EE',
  directory: '#06B6D4',
  definition: '#2DD4BF',
  importedsymbol: '#5EEAD4',
  // code indexing subtypes (definition_type values, not separate ontology nodes)
  class: '#A78BFA',
  interface: '#A78BFA',
  enum: '#A855F7',
  method: '#EF4444',
  constructor: '#F97316',
  import: '#3B82F6',
  default: '#6B7280',
};

export const ENTITY_TYPE_NAMES = {
  group: s__('Orbit|Group'),
  user: s__('Orbit|User'),
  project: s__('Orbit|Project'),
  mergerequest: s__('Orbit|MergeRequest'),
  mergerequestdiff: s__('Orbit|MergeRequestDiff'),
  mergerequestdifffile: s__('Orbit|MergeRequestDiffFile'),
  note: s__('Orbit|Note'),
  pipeline: s__('Orbit|Pipeline'),
  stage: s__('Orbit|Stage'),
  job: s__('Orbit|Job'),
  workitem: s__('Orbit|WorkItem'),
  label: s__('Orbit|Label'),
  milestone: s__('Orbit|Milestone'),
  vulnerability: s__('Orbit|Vulnerability'),
  vulnerabilityoccurrence: s__('Orbit|VulnerabilityOccurrence'),
  vulnerabilityidentifier: s__('Orbit|VulnerabilityIdentifier'),
  vulnerabilityscanner: s__('Orbit|VulnerabilityScanner'),
  securityscan: s__('Orbit|SecurityScan'),
  finding: s__('Orbit|Finding'),
  file: s__('Orbit|File'),
  directory: s__('Orbit|Directory'),
  definition: s__('Orbit|Definition'),
  importedsymbol: s__('Orbit|ImportedSymbol'),
  branch: s__('Orbit|Branch'),
};

// --- Query templates ---

export const EXAMPLE_QUERIES = [
  {
    value: 'search_users',
    text: s__('Orbit|Search users'),
    query: {
      query_type: 'search',
      // eslint-disable-next-line @gitlab/require-i18n-strings
      node: { id: 'u', entity: 'User', columns: '*' },
      limit: 25,
    },
  },
  {
    value: 'search_merge_requests',
    text: s__('Orbit|Search merge requests'),
    query: {
      query_type: 'search',
      node: { id: 'mr', entity: 'MergeRequest', columns: '*' },
      limit: 25,
    },
  },
  {
    value: 'user_authored_mrs',
    text: s__('Orbit|User authored MRs'),
    query: {
      query_type: 'traversal',
      nodes: [
        // eslint-disable-next-line @gitlab/require-i18n-strings
        { id: 'u', entity: 'User', columns: ['id', 'username'] },
        { id: 'mr', entity: 'MergeRequest', columns: ['id', 'title', 'state'] },
      ],
      relationships: [{ type: 'AUTHORED', from: 'u', to: 'mr' }],
      limit: 25,
    },
  },
  {
    value: 'mr_count_by_user',
    text: s__('Orbit|MR count by user'),
    query: {
      query_type: 'aggregation',
      nodes: [
        // eslint-disable-next-line @gitlab/require-i18n-strings
        { id: 'u', entity: 'User', columns: ['id', 'username'] },
        { id: 'mr', entity: 'MergeRequest' },
      ],
      relationships: [{ type: 'AUTHORED', from: 'u', to: 'mr' }],
      aggregations: [{ function: 'count', target: 'mr', group_by: 'u', alias: 'mr_count' }],
      aggregation_sort: { agg_index: 0, direction: 'DESC' },
      limit: 25,
    },
  },
  {
    value: 'user_neighbors',
    text: s__('Orbit|User neighbors'),
    query: {
      query_type: 'neighbors',
      // eslint-disable-next-line @gitlab/require-i18n-strings
      node: { id: 'center', entity: 'User', node_ids: [1] },
      neighbors: { node: 'center', direction: 'both' },
      limit: 25,
    },
  },
];

// --- Graph rendering ---

export const GRAPH_DEFAULTS = {
  GLOBE_RADIUS: 5,
  NODE_HEIGHT: 1.06,
  ARC_MIN_HEIGHT: 1.1,
  CONNECTION_ARC_HEIGHT: 0.14,
  NODE_BASE_SIZE: 18,
  NODE_HOVER_EXTRA: 4,
  IMPULSE_SIZE: 3,
  IMPULSE_BASE_SPEED: 0.003,
  IMPULSE_SPEED_VARIANCE: 0.002,
  EDGE_OPACITY: 0.4,
  EDGE_CURVE_SEGMENTS: 50,
  HOVER_THRESHOLD: 0.05,
  CAMERA_FOV: 45,
  CAMERA_NEAR: 0.1,
  CAMERA_FAR: 1000,
  CAMERA_DEFAULT_Z: 15,
  CAMERA_MIN_ZOOM: 8,
  CAMERA_MAX_ZOOM: 25,
  BFS_OPACITY_DECAY: 0.2,
  BFS_MIN_OPACITY: 0.15,
  CLUSTER_SPREAD: 0.3,
  MIN_NODE_DISTANCE: 0.2,
  LAYOUT_ATTRACTION_ITERATIONS: 5,
  LAYOUT_REPULSION_ITERATIONS: 10,
  CITY_LIGHT_COUNT: 8000,
  IDLE_TIMEOUT_MS: 3000,
  AUTO_ROTATE_SPEED: 0.0003,
  ANIMATION_SPEED: 0.2,
};

export const VIEW_3D = '3d';
export const VIEW_2D = '2d';

export const TAB_GRAPH = 'graph';
export const TAB_TABLE = 'table';

export const DIMENSION_OPTIONS = [
  { value: VIEW_3D, text: '3D' },
  { value: VIEW_2D, text: '2D' },
];
