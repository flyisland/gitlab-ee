export const mockItemsWithToolResponse = [
  {
    id: 1,
    content: 'Get repository file README.md from project 1000000 at ref HEAD',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:00:00Z',
    toolInfo: JSON.stringify({
      name: 'get_repository_file',
      args: {
        project_id: 1000000,
        file_path: 'README.md',
        ref: 'HEAD',
      },
      tool_response: {
        content: '# Project README\n\nThis is the project readme.',
        status: 'success',
        type: 'ToolMessage',
        name: 'get_repository_file',
        tool_call_id: 'toolu_abc123',
        artifact: null,
      },
    }),
  },
  {
    id: 2,
    content: 'Write file src/index.js',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:05:00Z',
    toolInfo: JSON.stringify({
      name: 'write_file',
      args: {
        file_path: 'src/index.js',
        content: 'console.log("hello");',
      },
      tool_response: {
        content: 'File written successfully.',
        status: 'success',
        type: 'ToolMessage',
        name: 'write_file',
        tool_call_id: 'toolu_def456',
        artifact: null,
      },
    }),
  },
];

export const mockItems = [
  {
    id: 1,
    content: 'Starting workflow',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:00:00Z',
  },
  {
    id: 2,
    content: 'Processing data',
    messageType: 'assistant',
    status: 'success',
    timestamp: '2023-01-01T10:05:00Z',
  },
  {
    id: 3,
    content: 'Workflow completed',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:10:00Z',
  },
];

export const mockItemsWithTodos = [
  {
    id: 1,
    content: '2 todos remaining',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:00:00Z',
    toolInfo: JSON.stringify({
      name: 'todo_write',
      args: {
        todos: [
          { description: 'Read duo_base_tool.py', status: 'completed' },
          { description: 'Create branch from main', status: 'completed' },
          { description: 'Extract pagination logic', status: 'in_progress' },
          { description: 'Add pagination tests', status: 'pending' },
        ],
      },
      tool_response: '[{"type":"text","text":"Todos updated."}]',
    }),
  },
];

export const mockItemsWithFilepath = [
  {
    id: 1,
    content: 'Starting workflow',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:00:00Z',
    toolInfo: JSON.stringify({
      args: {
        file_path: 'src/components/example.vue',
      },
    }),
  },
  {
    id: 2,
    content: 'Processing data',
    messageType: 'assistant',
    status: 'success',
    timestamp: '2023-01-01T10:05:00Z',
  },
  {
    id: 3,
    content: 'File updated',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:10:00Z',
    toolInfo: JSON.stringify({
      args: {
        file_path: 'src/utils/helper.js',
      },
    }),
  },
];

export const mockItemsWithComponentAttribution = [
  {
    id: 10,
    content: 'Supervisor reviewed the result',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:20:00Z',
    componentName: 'supervisor',
    subsessionId: null,
    toolInfo: JSON.stringify({
      name: 'read_file',
      args: {
        file_path: 'README.md',
      },
    }),
  },
  {
    id: 11,
    content: 'Developer subagent updated src/index.js',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:21:00Z',
    componentName: 'developer',
    subsessionId: '789',
    toolInfo: JSON.stringify({
      name: 'write_file',
      args: {
        file_path: 'src/index.js',
      },
    }),
  },
  {
    id: 12,
    content: 'Entry without component attribution',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:22:00Z',
    componentName: null,
    subsessionId: null,
    toolInfo: JSON.stringify({
      name: 'grep',
      args: {
        query: 'TODO',
      },
    }),
  },
];

export const mockDelegationItem = {
  id: 20,
  messageType: 'agent',
  messageSubType: 'delegation',
  componentName: 'supervisor',
  subsessionId: null,
  content: '',
  status: 'success',
  timestamp: '2023-01-01T10:30:00Z',
  toolInfo: JSON.stringify({
    name: 'delegate_task',
    args: {
      subagent_name: 'developer',
      subsession_id: 1,
      prompt: 'Implement fix...',
    },
  }),
};

export const mockDelegationReturnItem = {
  id: 21,
  messageType: 'agent',
  messageSubType: 'delegation_returns',
  componentName: 'developer',
  subsessionId: '1',
  content: 'Fix applied, ready for review',
  status: 'success',
  timestamp: '2023-01-01T10:31:00Z',
};

export const mockDelegationReturnFailureItem = {
  ...mockDelegationReturnItem,
  id: 22,
  status: 'failure',
  timestamp: '2023-01-01T10:32:00Z',
};

export const mockMixedItemsWithDelegation = [
  { ...mockItemsWithToolResponse[0], id: 100 },
  mockDelegationItem,
  mockDelegationReturnItem,
  { ...mockItemsWithFilepath[0], id: 101 },
  mockDelegationReturnFailureItem,
];

export const mockDelegationSequence = [
  {
    id: 30,
    content: 'Starting Flow: test',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:00:00Z',
  },
  mockDelegationItem,
  {
    id: 31,
    content: 'Read file lib/auth.rb',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:01:00Z',
    componentName: 'developer',
    subsessionId: '1',
    toolInfo: JSON.stringify({ name: 'read_file', args: { file_path: 'lib/auth.rb' } }),
  },
  {
    id: 32,
    content: 'Edit file lib/auth.rb',
    messageType: 'tool',
    status: 'success',
    timestamp: '2023-01-01T10:02:00Z',
    componentName: 'developer',
    subsessionId: '1',
    toolInfo: JSON.stringify({ name: 'edit_file', args: { file_path: 'lib/auth.rb' } }),
  },
  mockDelegationReturnItem,
];

// Seeds the `getWorkflowPermissions` cache-only read. Mirrors the `edges { node }`
// shape the polling `getAgentFlow` query writes for the same normalized
// `DuoWorkflow` node — seeding as `nodes` would collide with that shape and
// trip Apollo's "Cache data may be lost" warning.
export const buildWorkflowPermissionsResponse = ({
  id = 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
  resumeDuoWorkflow = true,
  updateDuoWorkflow = true,
} = {}) => ({
  duoWorkflowWorkflows: {
    __typename: 'DuoWorkflowConnection',
    edges: [
      {
        __typename: 'DuoWorkflowEdge',
        node: {
          __typename: 'DuoWorkflow',
          id,
          userPermissions: {
            __typename: 'DuoWorkflowPermissions',
            updateDuoWorkflow,
            resumeDuoWorkflow,
          },
        },
      },
    ],
  },
});
