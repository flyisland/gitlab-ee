import TodoChecklist from './todo_checklist.vue';

export const TOOL_CONTENT_RENDERERS = {
  todo_write: TodoChecklist,
};

export const getToolContentRenderer = (toolName) => TOOL_CONTENT_RENDERERS[toolName] || null;
