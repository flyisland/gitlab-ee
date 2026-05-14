import { mount } from '@vue/test-utils';
import ToolCard from 'ee/orbit/components/tool_card.vue';

const mockToonDescription = `Execute graph queries using a DSL.

<toon>
query:
  type: string
  description: The query to execute
</toon>`;

describe('ToolCard', () => {
  let wrapper;

  const createComponent = ({ tool, samplePrompt = '' } = {}) => {
    wrapper = mount(ToolCard, {
      propsData: {
        tool: tool || { name: 'query_graph', description: mockToonDescription },
        samplePrompt,
      },
    });
  };

  const findToggleButton = () => wrapper.find('[data-testid="toggle-tool-schema"]');

  describe('tool display', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the tool name', () => {
      expect(wrapper.text()).toContain('query_graph');
    });

    it('displays tool summary without toon block content', () => {
      expect(wrapper.text()).toContain('Execute graph queries using a DSL.');
      expect(wrapper.text()).not.toContain('<toon>');
    });

    it('does not render schema pre block when collapsed', () => {
      expect(wrapper.find('pre').exists()).toBe(false);
    });
  });

  describe('schema expand/collapse', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders schema in pre block when expanded', async () => {
      await findToggleButton().trigger('click');

      const pre = wrapper.find('pre');
      expect(pre.exists()).toBe(true);
      expect(pre.text()).toContain('query:');
      expect(pre.text()).toContain('type: string');
    });

    it('collapses schema when clicking "Show less"', async () => {
      await findToggleButton().trigger('click');
      expect(wrapper.find('pre').exists()).toBe(true);

      await findToggleButton().trigger('click');
      expect(wrapper.find('pre').exists()).toBe(false);
    });
  });

  describe('when tool has no toon block', () => {
    it('does not render expand button', () => {
      createComponent({ tool: { name: 'simple_tool', description: 'A simple tool' } });
      expect(findToggleButton().exists()).toBe(false);
    });
  });

  describe('when tool has no description', () => {
    it('renders without errors', () => {
      createComponent({ tool: { name: 'empty_tool', description: null } });
      expect(wrapper.text()).toContain('empty_tool');
    });
  });

  describe('sample prompt', () => {
    it('renders sample prompt when provided', () => {
      createComponent({ samplePrompt: 'What issues are blocking the login feature?' });

      expect(wrapper.text()).toContain('Sample prompt');
      expect(wrapper.text()).toContain('What issues are blocking the login feature?');
    });

    it('does not render sample prompt when empty', () => {
      createComponent();
      expect(wrapper.text()).not.toContain('Sample prompt');
    });
  });
});
