import { GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import TodoChecklist from 'ee/ai/duo_agents_platform/components/common/todo_checklist.vue';

describe('TodoChecklist', () => {
  let wrapper;

  const findContainer = () => wrapper.find('[data-testid="todo-checklist-container"]');
  const findAllItems = () => wrapper.findAll('li');
  const findAllIcons = () => wrapper.findAllComponents(GlIcon);

  const createWrapper = (toolInfo = {}) => {
    wrapper = shallowMount(TodoChecklist, {
      propsData: { toolInfo },
    });
  };

  const mockTodos = [
    { status: 'completed', description: 'Set up repository' },
    { status: 'in_progress', description: 'Write tests' },
    { status: 'pending', description: 'Deploy to staging' },
    { status: 'cancelled', description: 'Old task' },
    { status: 'unknown_status', description: 'Mystery task' },
  ];

  describe('when todos are present', () => {
    beforeEach(() => {
      createWrapper({ args: { todos: mockTodos } });
    });

    it('renders correct number of list items', () => {
      expect(findAllItems()).toHaveLength(mockTodos.length);
    });

    it('renders check icon for completed status', () => {
      expect(findAllIcons().at(0).props('name')).toBe('check');
    });

    it('renders status-running icon for in_progress status', () => {
      expect(findAllIcons().at(1).props('name')).toBe('status-running');
    });

    it('renders status-waiting icon for pending status', () => {
      expect(findAllIcons().at(2).props('name')).toBe('status-waiting');
    });

    it('renders close icon for cancelled status', () => {
      expect(findAllIcons().at(3).props('name')).toBe('close');
    });

    it('renders status-waiting icon for unknown status string', () => {
      expect(findAllIcons().at(4).props('name')).toBe('status-waiting');
    });

    it('renders description text for each todo', () => {
      mockTodos.forEach((todo, index) => {
        expect(findAllItems().at(index).text()).toContain(todo.description);
      });
    });
  });

  describe('when todos array is empty', () => {
    it('renders nothing', () => {
      createWrapper({ args: { todos: [] } });
      expect(findContainer().exists()).toBe(false);
    });
  });

  describe('when args is missing', () => {
    it('handles missing args gracefully (renders nothing)', () => {
      createWrapper({});
      expect(findContainer().exists()).toBe(false);
    });
  });

  describe('when args.todos is missing', () => {
    it('handles missing args.todos gracefully (renders nothing)', () => {
      createWrapper({ args: {} });
      expect(findContainer().exists()).toBe(false);
    });
  });
});
