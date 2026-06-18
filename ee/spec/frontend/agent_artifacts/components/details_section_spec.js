import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import DetailsSection from 'ee/agent_artifacts/components/details_section.vue';
import CollapsibleText from 'ee/agent_artifacts/components/collapsible_text.vue';

describe('DetailsSection', () => {
  let wrapper;

  const createComponent = (details = {}) => {
    wrapper = shallowMountExtended(DetailsSection, {
      propsData: {
        details,
      },
    });
  };

  const findInputPromptBlock = () => wrapper.findByTestId('details-block-input_prompt');
  const findSystemPromptBlock = () => wrapper.findByTestId('details-block-system_prompt');
  const findAgentOutputBlock = () => wrapper.findByTestId('details-block-agent_output');
  const findField = (key) => wrapper.findByTestId(`details-field-${key}`);
  const findEmpty = () => wrapper.findByTestId('details-empty');
  const findCollapsibleTexts = () => wrapper.findAllComponents(CollapsibleText);

  describe('when all large-text keys are present', () => {
    beforeEach(() => {
      createComponent({
        input_prompt: 'the input prompt',
        system_prompt: 'the system prompt',
        agent_output: 'the agent output',
      });
    });

    it('renders a collapsible block for each large-text key', () => {
      expect(findInputPromptBlock().exists()).toBe(true);
      expect(findSystemPromptBlock().exists()).toBe(true);
      expect(findAgentOutputBlock().exists()).toBe(true);
      expect(findCollapsibleTexts()).toHaveLength(3);
    });

    it('passes the value to the CollapsibleText', () => {
      expect(findInputPromptBlock().findComponent(CollapsibleText).props('text')).toBe(
        'the input prompt',
      );
    });
  });

  describe('when only input_prompt is present', () => {
    beforeEach(() => {
      createComponent({ input_prompt: 'only the input prompt' });
    });

    it('renders only the input prompt block', () => {
      expect(findInputPromptBlock().exists()).toBe(true);
      expect(findSystemPromptBlock().exists()).toBe(false);
      expect(findAgentOutputBlock().exists()).toBe(false);
      expect(findCollapsibleTexts()).toHaveLength(1);
    });
  });

  describe('with generic (non-large-text) keys', () => {
    beforeEach(() => {
      createComponent({
        status: 'finished',
        total_input_tokens: 1800,
        agent_output: 'the output',
      });
    });

    it('renders a key/value row for each non-large-text key', () => {
      expect(findField('status').exists()).toBe(true);
      expect(findField('total_input_tokens').exists()).toBe(true);
    });

    it('humanizes the key as the label and renders the value', () => {
      expect(findField('total_input_tokens').text()).toContain('Total input tokens');
      expect(findField('total_input_tokens').text()).toContain('1800');
      expect(findField('status').text()).toContain('Status');
      expect(findField('status').text()).toContain('finished');
    });

    it('still renders large-text keys as collapsible blocks, not generic rows', () => {
      expect(findField('agent_output').exists()).toBe(false);
      expect(findAgentOutputBlock().exists()).toBe(true);
    });
  });

  describe('with an object-valued key', () => {
    beforeEach(() => {
      createComponent({ tool_input: { path: 'app/models/user.rb' } });
    });

    it('serialises the object value', () => {
      expect(findField('tool_input').text()).toContain('app/models/user.rb');
    });
  });

  describe('when details is empty', () => {
    beforeEach(() => {
      createComponent({});
    });

    it('renders the empty state and no blocks or fields', () => {
      expect(findEmpty().exists()).toBe(true);
      expect(findInputPromptBlock().exists()).toBe(false);
      expect(findCollapsibleTexts()).toHaveLength(0);
    });
  });

  describe('when keys are present but empty/null', () => {
    beforeEach(() => {
      createComponent({ input_prompt: '', system_prompt: null });
    });

    it('does not render blocks for empty values', () => {
      expect(findInputPromptBlock().exists()).toBe(false);
      expect(findSystemPromptBlock().exists()).toBe(false);
      expect(findCollapsibleTexts()).toHaveLength(0);
    });
  });
});
