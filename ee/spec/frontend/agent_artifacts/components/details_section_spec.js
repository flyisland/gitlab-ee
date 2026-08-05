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

  const findBlock = (key) => wrapper.findByTestId(`details-block-${key}`);
  const findField = (key) => wrapper.findByTestId(`details-field-${key}`);
  const findEmpty = () => wrapper.findByTestId('details-empty');
  const findCollapsibleTexts = () => wrapper.findAllComponents(CollapsibleText);

  describe('with generic (non-large-text) keys', () => {
    beforeEach(() => {
      createComponent({
        status: 'finished',
        total_input_tokens: 1800,
        prompt_content: 'the prompt content',
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
      expect(findField('prompt_content').exists()).toBe(false);
      expect(findBlock('prompt_content').exists()).toBe(true);
    });
  });

  describe('with an object-valued key', () => {
    beforeEach(() => {
      createComponent({
        tool_input: { path: 'app/models/user.rb' },
        tool_args: { path: 'app/models/user.rb', line: 42 },
      });
    });

    it('serialises the object value', () => {
      expect(findField('tool_input').text()).toContain('app/models/user.rb');
      expect(findBlock('tool_args').findComponent(CollapsibleText).props('text')).toContain(
        'app/models/user.rb',
      );
    });
  });

  describe('when details is empty', () => {
    beforeEach(() => {
      createComponent({});
    });

    it('renders the empty state and no blocks or fields', () => {
      expect(findEmpty().exists()).toBe(true);
      expect(findCollapsibleTexts()).toHaveLength(0);
    });
  });

  describe('when keys are present but empty/null', () => {
    beforeEach(() => {
      createComponent({ prompt_content: '', response_content: null });
    });

    it('does not render blocks for empty values', () => {
      expect(findBlock('prompt_content').exists()).toBe(false);
      expect(findBlock('response_content').exists()).toBe(false);
      expect(findCollapsibleTexts()).toHaveLength(0);
    });
  });

  describe('large-text keys', () => {
    it.each([
      ['goal', 'the goal text'],
      ['prompt_content', 'the prompt content'],
      ['response_content', 'the response content'],
      ['content', 'the content'],
      ['error_message', 'the error message'],
      ['previous_error', 'the previous error'],
    ])('renders %s as a collapsible block', (key, value) => {
      createComponent({ [key]: value });

      expect(findBlock(key).exists()).toBe(true);
      expect(findField(key).exists()).toBe(false);
      expect(findBlock(key).findComponent(CollapsibleText).props('text')).toBe(value);
    });
  });
});
