/* eslint-disable @gitlab/require-i18n-strings */

const MOCK_TOOL_RULES = [
  {
    id: 'list_issues',
    name: 'list_issues',
    actionType: 'READ',
    category: 'Project management',
    source: 'gitlab',
    webAccess: 'ALLOW',
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'get_issue',
    name: 'get_issue',
    actionType: 'READ',
    category: 'Project management',
    source: 'gitlab',
    webAccess: null,
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'get_repository_file',
    name: 'get_repository_file',
    actionType: 'READ',
    category: 'Repository',
    source: 'gitlab',
    webAccess: null,
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'create_issue',
    name: 'create_issue',
    actionType: 'WRITE',
    category: 'Project management',
    source: 'gitlab',
    webAccess: 'ASK',
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'update_issue',
    name: 'update_issue',
    actionType: 'WRITE',
    category: 'Project management',
    source: 'gitlab',
    webAccess: null,
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'create_merge_request',
    name: 'create_merge_request',
    actionType: 'WRITE',
    category: 'Merge requests',
    source: 'gitlab',
    webAccess: null,
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'read_file',
    name: 'read_file',
    actionType: 'WRITE',
    category: 'Repository',
    source: 'gitlab',
    webAccess: 'ALLOW',
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'edit_file',
    name: 'edit_file',
    actionType: 'WRITE',
    category: 'Repository',
    source: 'gitlab',
    webAccess: 'ASK',
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'run_git_command',
    name: 'run_git_command',
    actionType: 'DESTROY',
    category: 'Repository',
    source: 'gitlab',
    webAccess: null,
    localAccess: null,
    __typename: 'AiToolRule',
  },
  {
    id: 'run_command',
    name: 'run_command',
    actionType: 'DESTROY',
    category: 'Repository',
    source: 'gitlab',
    webAccess: 'DENY',
    localAccess: null,
    __typename: 'AiToolRule',
  },
];

const PAGE_SIZE = 5;

const mockToolRules = MOCK_TOOL_RULES.map((rule) => ({ ...rule }));

export const resolvers = {
  Query: {
    aiToolRules: (_, { first = PAGE_SIZE, last, after, before }) => {
      let startIndex = 0;
      let endIndex = mockToolRules.length;

      if (after) {
        const afterIndex = mockToolRules.findIndex((r) => r.id === after);
        if (afterIndex !== -1) startIndex = afterIndex + 1;
      }

      if (before) {
        const beforeIndex = mockToolRules.findIndex((r) => r.id === before);
        if (beforeIndex !== -1) endIndex = beforeIndex;
      }

      let nodes;
      let hasNextPage;
      let hasPreviousPage;

      if (last) {
        const sliceStart = Math.max(startIndex, endIndex - last);
        nodes = mockToolRules.slice(sliceStart, endIndex);
        hasNextPage = endIndex < mockToolRules.length;
        hasPreviousPage = sliceStart > 0;
      } else {
        const sliceEnd = Math.min(startIndex + first, endIndex);
        nodes = mockToolRules.slice(startIndex, sliceEnd);
        hasNextPage = sliceEnd < mockToolRules.length;
        hasPreviousPage = startIndex > 0;
      }

      return {
        nodes,
        pageInfo: {
          startCursor: nodes[0]?.id || null,
          endCursor: nodes[nodes.length - 1]?.id || null,
          hasNextPage,
          hasPreviousPage,
          __typename: 'PageInfo',
        },
        __typename: 'AiToolRuleConnection',
      };
    },
  },
  Mutation: {
    updateAiToolRule: (_, { input }) => {
      const { toolId, webAccess, localAccess } = input;
      const rule = mockToolRules.find((r) => r.id === toolId);

      if (!rule) {
        return {
          id: null,
          webAccess: null,
          localAccess: null,
          errors: [`Tool '${toolId}' not found`],
          __typename: 'UpdateAiToolRulePayload',
        };
      }

      if (webAccess !== undefined) rule.webAccess = webAccess;
      if (localAccess !== undefined) rule.localAccess = localAccess;

      return {
        id: rule.id,
        webAccess: rule.webAccess,
        localAccess: rule.localAccess,
        errors: [],
        __typename: 'UpdateAiToolRulePayload',
      };
    },
  },
};

export default resolvers;
