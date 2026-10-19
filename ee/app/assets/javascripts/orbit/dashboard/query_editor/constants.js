import { HTTP_STATUS_BAD_REQUEST, HTTP_STATUS_UNPROCESSABLE_ENTITY } from '~/lib/utils/http_status';
import { s__ } from '~/locale';

export const ORBIT_GQL_LANGUAGE = 'orbit-gql';

/* eslint-disable @gitlab/require-i18n-strings -- GQL keywords, not UI text */
export const GQL_KEYWORDS = [
  'MATCH',
  'WHERE',
  'RETURN',
  'ORDER BY',
  'LIMIT',
  'AS',
  'AND',
  'IN',
  'IS NULL',
  'IS NOT NULL',
  'TRUE',
  'FALSE',
  'ASC',
  'DESC',
  'COUNT',
  'CONTAINS',
  'STARTS WITH',
  'ENDS WITH',
];
/* eslint-enable @gitlab/require-i18n-strings */

export const QUERY_ERROR_KIND = {
  INVALID_QUERY: 'invalid_query',
  BILLING_GROUP_REQUIRED: 'billing_group_required',
  REQUEST_REJECTED: 'request_rejected',
  NO_ACCESS: 'no_access',
  SERVER: 'server',
};

export const INVALID_QUERY_STATUSES = [HTTP_STATUS_BAD_REQUEST, HTTP_STATUS_UNPROCESSABLE_ENTITY];

export const QUERY_STORAGE_KEY_PREFIX = 'orbit-query-editor-text';

// The code of the 422 that the Orbit API returns when the user has no Orbit default group.
export const BILLING_NAMESPACE_REQUIRED_CODE = 'billing_namespace_required';

export const COMPLETION_KIND = {
  ENTITY: 'entity',
  RELATIONSHIP: 'relationship',
  PROPERTY: 'property',
  KEYWORD: 'keyword',
};

/* eslint-disable @gitlab/require-i18n-strings -- GQL and JSON code samples, not UI text */
export const GQL_STARTER = [
  {
    code: 'MATCH (u:User)-[:AUTHORED]->(mr:MergeRequest)',
    description: s__('Orbit|Find entities and how they connect.'),
  },
  {
    code: "WHERE mr.state = 'merged'",
    description: s__('Orbit|Keep the matches that meet a condition. Join conditions with AND.'),
  },
  {
    code: 'RETURN u.username, mr.title',
    description: s__('Orbit|Choose the columns.'),
  },
  {
    code: 'RETURN u.username, count(mr) AS merged',
    description: s__(
      'Orbit|Count, or use sum, avg, min, and max. The other columns become groups.',
    ),
  },
  {
    code: 'ORDER BY mr.merged_at DESC',
    description: s__('Orbit|Sort by one column.'),
  },
  {
    code: 'LIMIT 25',
    description: s__('Orbit|Return at most this many rows, up to 1,000.'),
  },
];

export const GQL_MORE_SYNTAX = [
  {
    title: s__('Orbit|Patterns'),
    items: [
      {
        code: '(mr:MergeRequest)-[:CLOSES|MENTIONS]->(wi:WorkItem)',
        description: s__('Orbit|Match one of several relationships.'),
      },
      {
        code: "(g:Group {full_path: 'gitlab-org'})-[:CONTAINS*1..3]->(s:Group)",
        description: s__('Orbit|Follow a relationship for one to three hops.'),
      },
      {
        code: '(n)--(wi:WorkItem {id: 42})',
        description: s__('Orbit|Find everything linked to one node.'),
      },
      {
        code: 'p = ANY SHORTEST (u:User {id: 1})-[*1..3]->(pr:Project {id: 2})',
        description: s__('Orbit|Find the shortest path between two nodes.'),
      },
    ],
  },
  {
    title: s__('Orbit|Filters'),
    items: [
      {
        code: "WHERE mr.state IN ['opened', 'merged']",
        description: s__('Orbit|Match one of several values.'),
      },
      {
        code: "WHERE p.full_path STARTS WITH 'gitlab-org/'",
        description: s__('Orbit|Match part of a text. Also ENDS WITH and CONTAINS.'),
      },
      {
        code: 'WHERE mr.merged_at IS NOT NULL',
        description: s__('Orbit|Find present values, or missing values with IS NULL.'),
      },
      {
        code: "WHERE mr.created_at >= date('2026-10-01')",
        description: s__('Orbit|Compare with a date, or a time with datetime().'),
      },
      {
        code: "WHERE any_tokens(wi.title, 'flaky spec')",
        description: s__('Orbit|Search words in text. Also all_tokens and token_match.'),
      },
    ],
  },
  {
    title: s__('Orbit|Columns'),
    items: [
      {
        code: 'RETURN u{.username, .name}, properties(mr)',
        description: s__('Orbit|Choose some properties of a node, or all of them.'),
      },
      {
        code: "RETURN date_trunc('month', mr.merged_at) AS month, count(mr)",
        description: s__('Orbit|Group by minute, hour, day, week, month, quarter, or year.'),
      },
    ],
  },
];

export const JSON_QUERY_EXAMPLES = [
  {
    title: s__('Orbit|Traversal: entities and their relationships'),
    query: {
      query_type: 'traversal',
      nodes: [
        { id: 'u', entity: 'User' },
        { id: 'mr', entity: 'MergeRequest', filters: { state: 'merged' } },
      ],
      relationships: [{ type: 'AUTHORED', from: 'u', to: 'mr' }],
      limit: 25,
    },
  },
  {
    title: s__('Orbit|Aggregation: count by a group'),
    query: {
      query_type: 'aggregation',
      nodes: [{ id: 'v', entity: 'Vulnerability', filters: { report_type: 'sast' } }],
      group_by: ['v.severity'],
      aggregations: [{ count: 'v', as: 'total' }],
      limit: 10,
    },
  },
  {
    title: s__('Orbit|Neighbors: everything linked to one node'),
    query: {
      query_type: 'neighbors',
      nodes: [{ id: 'u', entity: 'User', node_ids: [100] }],
      neighbors: { direction: 'both' },
      limit: 20,
    },
  },
  {
    title: s__('Orbit|Path finding: shortest path'),
    query: {
      query_type: 'path_finding',
      nodes: [
        { id: 'a', entity: 'User', node_ids: [100] },
        { id: 'b', entity: 'Project', node_ids: [200] },
      ],
      path: {
        type: 'shortest',
        from: 'a',
        to: 'b',
        max_depth: 3,
        rel_types: ['MEMBER_OF', 'CONTAINS'],
      },
    },
  },
];
/* eslint-enable @gitlab/require-i18n-strings */

export const GQL_REFERENCE_URL =
  'https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/blob/main/docs/design-documents/querying/orbit_query_frontend.md';

export const JSON_QUERY_REFERENCE_URL =
  'https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/blob/main/docs/design-documents/querying/intermediary_llm_query_language.md';

export const OPEN_CYPHER_URL = 'https://opencypher.org/resources/';

export const EDITOR_OPTIONS = {
  minimap: { enabled: false },
  scrollBeyondLastLine: false,
  lineNumbers: 'on',
  renderLineHighlight: 'none',
  glyphMargin: false,
  folding: false,
  lineDecorationsWidth: 10,
  lineNumbersMinChars: 3,
  fontSize: 13,
  tabSize: 2,
};
