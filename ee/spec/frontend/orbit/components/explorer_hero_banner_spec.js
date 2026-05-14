import { shallowMount } from '@vue/test-utils';
import ExplorerHeroBanner from 'ee/orbit/components/explorer_hero_banner.vue';

describe('ExplorerHeroBanner', () => {
  let wrapper;

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(ExplorerHeroBanner, {
      propsData: {
        logoSrc: '/logo.svg',
        ...props,
      },
    });
  };

  describe('rendering', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders the banner', () => {
      expect(wrapper.find('[data-testid="explorer-hero-banner"]').exists()).toBe(true);
    });

    it('displays hero title', () => {
      expect(wrapper.find('[data-testid="banner-title"]').text()).toContain(
        'Get started with Orbit',
      );
    });

    it('displays hero subtitle', () => {
      expect(wrapper.find('[data-testid="banner-subtitle"]').text()).toContain(
        'Ask your GitLab anything',
      );
    });

    it('renders resource links', () => {
      const bannerText = wrapper.find('[data-testid="explorer-hero-banner"]').text();

      expect(bannerText).toContain('CLI');
      expect(bannerText).toContain('REST API');
      expect(bannerText).toContain('MCP');
      expect(bannerText).toContain('Docs');
    });
  });

  describe('dismiss', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('emits dismiss on close button click', () => {
      wrapper.find('[data-testid="dismiss-banner-btn"]').vm.$emit('click');

      expect(wrapper.emitted('dismiss')).toHaveLength(1);
    });
  });
});
