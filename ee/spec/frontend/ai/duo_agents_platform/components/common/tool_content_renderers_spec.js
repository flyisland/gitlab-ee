import TodoChecklist from 'ee/ai/duo_agents_platform/components/common/todo_checklist.vue';
import { getToolContentRenderer } from 'ee/ai/duo_agents_platform/components/common/tool_content_renderers';

describe('getToolContentRenderer', () => {
  it('returns TodoChecklist for todo_write', () => {
    expect(getToolContentRenderer('todo_write')).toBe(TodoChecklist);
  });

  it('returns null for an unregistered tool name', () => {
    expect(getToolContentRenderer('read_file')).toBeNull();
  });

  it('returns null for undefined', () => {
    expect(getToolContentRenderer(undefined)).toBeNull();
  });

  it('returns null for null', () => {
    expect(getToolContentRenderer(null)).toBeNull();
  });
});
