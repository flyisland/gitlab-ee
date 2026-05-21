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
