import { shallowMount } from '@vue/test-utils';
import { GlAlert, GlLink } from '@gitlab/ui';
import AiCatalogItemConsumerWarning from 'ee/ai/catalog/components/ai_catalog_item_consumer_warning.vue';
import {
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
  AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS,
} from 'ee/ai/catalog/constants';

describe('AiCatalogItemConsumerWarning', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    return shallowMount(AiCatalogItemConsumerWarning, {
      propsData: {
        itemType: AI_CATALOG_TYPE_AGENT,
        canEnable: true,
        ...props,
      },
      stubs: {
        GlAlert,
        GlLink,
      },
    });
  };

  describe('rendering', () => {
    it('renders GlAlert component', () => {
      wrapper = createComponent();
      expect(wrapper.findComponent(GlAlert).exists()).toBe(true);
    });

    it('renders alert with warning variant', () => {
      wrapper = createComponent();
      expect(wrapper.findComponent(GlAlert).props('variant')).toBe('warning');
    });

    it('renders alert as non-dismissible', () => {
      wrapper = createComponent();
      expect(wrapper.findComponent(GlAlert).props('dismissible')).toBe(false);
    });
  });

  describe('agent warning', () => {
    beforeEach(() => {
      wrapper = createComponent({ itemType: AI_CATALOG_TYPE_AGENT });
    });

    it('displays agent warning intro text', () => {
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_AGENT].fullWarningIntro;
      expect(wrapper.text()).toContain(text);
    });

    it('displays agent access warning text', () => {
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_AGENT].fullWarningAccess;
      expect(wrapper.text()).toContain(text);
    });

    it('displays caution text with learn more link', () => {
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_AGENT].fullWarningCaution;
      expect(wrapper.text()).toContain(text);
      expect(wrapper.findComponent(GlLink).exists()).toBe(true);
    });

    it('renders warning as list format', () => {
      const lists = wrapper.findAll('ul');
      expect(lists.length).toBeGreaterThan(0);
    });

    it('does not display flow warning intro text', () => {
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_FLOW].fullWarningIntro;
      expect(wrapper.text()).not.toContain(text);
    });

    it('does not display third-party flow warning intro text', () => {
      const text =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_THIRD_PARTY_FLOW].fullWarningIntro;
      expect(wrapper.text()).not.toContain(text);
    });
  });

  describe('flow warning', () => {
    beforeEach(() => {
      wrapper = createComponent({ itemType: AI_CATALOG_TYPE_FLOW });
    });

    it('displays flow warning intro text', () => {
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_FLOW].fullWarningIntro;
      expect(wrapper.text()).toContain(text);
    });

    it('displays flow bullet points', () => {
      const bullet1 =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_FLOW].fullWarningBullet1;
      const bullet2 =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_FLOW].fullWarningBullet2;
      expect(wrapper.text()).toContain(bullet1);
      expect(wrapper.text()).toContain(bullet2);
    });

    it('displays composite identity text', () => {
      const text =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_FLOW].fullWarningCompositeIdentity;
      expect(wrapper.text()).toContain(text);
    });

    it('displays access intro and bullets', () => {
      const accessIntro =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_FLOW].fullWarningAccessIntro;
      const accessBullet1 =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_FLOW].fullWarningAccessBullet1;
      expect(wrapper.text()).toContain(accessIntro);
      expect(wrapper.text()).toContain(accessBullet1);
    });

    it('renders warning with detailed format', () => {
      const lists = wrapper.findAll('ul');
      expect(lists.length).toBeGreaterThan(1);
    });

    it('does not display agent warning intro text', () => {
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_AGENT].fullWarningIntro;
      expect(wrapper.text()).not.toContain(text);
    });

    it('does not display third-party flow warning intro text', () => {
      const text =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_THIRD_PARTY_FLOW].fullWarningIntro;
      expect(wrapper.text()).not.toContain(text);
    });
  });

  describe('third-party flow warning', () => {
    beforeEach(() => {
      wrapper = createComponent({ itemType: AI_CATALOG_TYPE_THIRD_PARTY_FLOW });
    });

    it('displays third-party flow warning intro text', () => {
      const text =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_THIRD_PARTY_FLOW].fullWarningIntro;
      expect(wrapper.text()).toContain(text);
    });

    it('displays third-party flow bullet points', () => {
      const bullet1 =
        AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_THIRD_PARTY_FLOW].fullWarningBullet1;
      expect(wrapper.text()).toContain(bullet1);
    });

    it('does not display agent warning intro text', () => {
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_AGENT].fullWarningIntro;
      expect(wrapper.text()).not.toContain(text);
    });

    it('does not display flow warning intro text', () => {
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_FLOW].fullWarningIntro;
      expect(wrapper.text()).not.toContain(text);
    });
  });

  describe('permission restrictions', () => {
    it('shows full warning when canEnable is true', () => {
      wrapper = createComponent({
        itemType: AI_CATALOG_TYPE_AGENT,
        canEnable: true,
      });
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_AGENT].fullWarningIntro;
      expect(wrapper.text()).toContain(text);
    });

    it('shows restricted warning when canEnable is false', () => {
      wrapper = createComponent({
        itemType: AI_CATALOG_TYPE_AGENT,
        canEnable: false,
      });
      const text = AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[AI_CATALOG_TYPE_AGENT].restrictedWarning;
      expect(wrapper.text()).toContain(text);
    });
  });

  describe('link rendering', () => {
    it('renders learn more link', () => {
      wrapper = createComponent({ itemType: AI_CATALOG_TYPE_AGENT });
      const link = wrapper.findComponent(GlLink);
      expect(link.exists()).toBe(true);
      expect(link.text()).toContain('Learn more');
    });
  });
});
