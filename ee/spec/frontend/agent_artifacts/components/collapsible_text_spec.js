import { GlButton, GlCollapse } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import CollapsibleText from 'ee/agent_artifacts/components/collapsible_text.vue';

describe('CollapsibleText', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = mountExtended(CollapsibleText, {
      propsData: {
        ...props,
      },
    });
  };

  const findPreview = () => wrapper.findByTestId('collapsible-text-preview');
  const findFull = () => wrapper.findByTestId('collapsible-text-full');
  const findToggle = () => wrapper.findByTestId('collapsible-text-toggle');
  const findCollapse = () => wrapper.findComponent(GlCollapse);

  describe('when text is shorter than the threshold', () => {
    beforeEach(() => {
      createComponent({ text: 'short text', threshold: 500 });
    });

    it('renders the text inline', () => {
      expect(wrapper.text()).toContain('short text');
    });

    it('does not render the preview, collapse or toggle', () => {
      expect(findPreview().exists()).toBe(false);
      expect(findCollapse().exists()).toBe(false);
      expect(findToggle().exists()).toBe(false);
    });
  });

  describe('when text is longer than the threshold', () => {
    const longText = 'a'.repeat(20);

    beforeEach(() => {
      createComponent({ text: longText, threshold: 5 });
    });

    it('renders the preview truncated to the threshold', () => {
      expect(findPreview().exists()).toBe(true);
      expect(findPreview().text()).toBe('a'.repeat(5));
    });

    it('renders the full text inside a collapse', () => {
      expect(findCollapse().exists()).toBe(true);
      expect(findFull().text()).toBe(longText);
    });

    it('renders a toggle button labelled Show more', () => {
      expect(findToggle().exists()).toBe(true);
      expect(findToggle().text()).toBe('Show more');
    });

    it('collapse is not visible by default', () => {
      expect(findCollapse().props('visible')).toBe(false);
    });

    describe('when the toggle is clicked', () => {
      beforeEach(async () => {
        await findToggle().trigger('click');
      });

      it('expands the collapse and hides the preview', () => {
        expect(findCollapse().props('visible')).toBe(true);
        expect(findPreview().exists()).toBe(false);
      });

      it('flips the toggle label to Show less', () => {
        expect(findToggle().text()).toBe('Show less');
      });

      it('collapses again when clicked a second time', async () => {
        await findToggle().trigger('click');

        expect(findCollapse().props('visible')).toBe(false);
        expect(findToggle().text()).toBe('Show more');
      });
    });
  });

  it('uses the default threshold of 500', () => {
    createComponent({ text: 'a'.repeat(501) });

    expect(wrapper.findComponent(GlButton).exists()).toBe(true);
  });
});
