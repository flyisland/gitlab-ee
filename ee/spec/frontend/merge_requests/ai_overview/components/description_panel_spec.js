import { GlAvatar, GlLink } from '@gitlab/ui';
import { trimText } from 'helpers/text_helper';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { renderGFM } from '~/behaviors/markdown/render_gfm';
import DescriptionPanel from 'ee/merge_requests/ai_overview/components/description_panel.vue';
import { makeMergeRequest } from '../mock_data';

jest.mock('~/behaviors/markdown/render_gfm');

describe('AI Overview description panel', () => {
  let wrapper;

  const createComponent = (overrides = {}) => {
    wrapper = mountExtended(DescriptionPanel, {
      propsData: { mergeRequest: makeMergeRequest(overrides) },
    });
  };

  const findContent = () => wrapper.findByTestId('description-content');
  const findAuthor = () => wrapper.findByTestId('description-author');
  const findAuthorLink = () => findAuthor().findComponent(GlLink);

  describe('with a description', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the description HTML as markdown', () => {
      expect(findContent().classes()).toContain('md');
      expect(findContent().html()).toContain('<p data-sourcepos="1:1-1:19" dir="auto">');
      expect(findContent().text()).toBe('Adds rate limiting.');
    });

    it('runs the GFM renderer over the description', () => {
      expect(renderGFM).toHaveBeenCalledWith(findContent().element);
    });

    it('names the author', () => {
      expect(trimText(findAuthor().text())).toBe('Created by Priya Nair');
    });

    it('links the author to their profile with a user popover', () => {
      expect(findAuthorLink().attributes()).toMatchObject({
        href: '/priya',
        'data-user-id': '1',
        'data-username': 'priya',
      });
      expect(findAuthorLink().classes()).toContain('js-user-link');
      expect(findAuthorLink().findComponent(GlAvatar).props('src')).toBe('/priya.png');
    });
  });

  describe('without a description', () => {
    beforeEach(() => {
      createComponent({ descriptionHtml: '' });
    });

    it('says there is no description', () => {
      expect(findContent().exists()).toBe(false);
      expect(wrapper.text()).toContain('No description');
    });

    it('does not run the GFM renderer', () => {
      expect(renderGFM).not.toHaveBeenCalled();
    });
  });

  it('leaves the author out when there is none', () => {
    createComponent({ author: null });

    expect(findAuthor().exists()).toBe(false);
    expect(findContent().exists()).toBe(true);
  });

  describe('collapsing', () => {
    const findBody = () => findContent().element.parentElement;
    const findToggle = () => wrapper.findByTestId('description-toggle');

    beforeEach(() => {
      createComponent();
    });

    it('is collapsed by default, leaving the header on show', () => {
      expect(findBody().style.display).toBe('none');
      expect(findAuthor().exists()).toBe(true);
      expect(findToggle().attributes()).toMatchObject({
        'aria-label': 'Expand',
        'aria-expanded': 'false',
        'aria-controls': findBody().id,
      });
    });

    it('expands and collapses from the toggle', async () => {
      await findToggle().trigger('click');

      expect(findBody().style.display).toBe('');
      expect(findToggle().attributes()).toMatchObject({
        'aria-label': 'Collapse',
        'aria-expanded': 'true',
      });

      await findToggle().trigger('click');

      expect(findBody().style.display).toBe('none');
    });
  });

  it('offers no toggle when there is no description', () => {
    createComponent({ descriptionHtml: '' });

    expect(wrapper.findByTestId('description-toggle').exists()).toBe(false);
  });
});
