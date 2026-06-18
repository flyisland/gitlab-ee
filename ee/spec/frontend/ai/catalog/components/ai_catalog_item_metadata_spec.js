import { GlIcon } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { stubComponent } from 'helpers/stub_component';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import AiCatalogItemMetadata from 'ee/ai/catalog/components/ai_catalog_item_metadata.vue';
import AiCatalogItemUserAttribution from 'ee/ai/catalog/components/ai_catalog_item_user_attribution.vue';
import { VERSION_LATEST } from 'ee/ai/catalog/constants';
import { mockAgent, mockFlow, mockThirdPartyFlow } from '../mock_data';

describe('AiCatalogItemMetadata', () => {
  let wrapper;

  const GlIconStub = stubComponent(GlIcon);

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(AiCatalogItemMetadata, {
      propsData: {
        item: mockAgent,
        versionKey: VERSION_LATEST,
        ...props,
      },
      directives: {
        GlTooltip: createMockDirective('gl-tooltip'),
      },
      stubs: {
        GlIcon: GlIconStub,
      },
    });
  };

  const findUserAttribution = () => wrapper.findComponent(AiCatalogItemUserAttribution);
  const findFoundationalItem = () => wrapper.findByTestId('metadata-foundational');
  const findExternalItem = () => wrapper.findByTestId('metadata-external');
  const findVersionItem = () => wrapper.findByTestId('metadata-version');

  describe('user attribution', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the user attribution component with correct props', () => {
      const attribution = findUserAttribution();
      expect(attribution.exists()).toBe(true);
      expect(attribution.props('item')).toBe(mockAgent);
      expect(attribution.props('versionKey')).toBe(VERSION_LATEST);
    });
  });

  describe('foundational field', () => {
    describe('when item is a foundational agent', () => {
      beforeEach(() => {
        createComponent({
          item: {
            ...mockAgent,
            foundational: true,
          },
        });
      });

      it('displays "Foundational agent" text', () => {
        const foundational = findFoundationalItem();
        expect(foundational.text()).toBe('GitLab-managed');
        expect(foundational.findComponent(GlIcon).props('name')).toBe('tanuki-verified');
      });
    });

    describe('when item is a foundational flow', () => {
      beforeEach(() => {
        createComponent({
          item: {
            ...mockFlow,
            foundational: true,
          },
        });
      });

      it('displays "Foundational flow" text', () => {
        const foundational = findFoundationalItem();
        expect(foundational.text()).toBe('GitLab-managed');
        expect(foundational.findComponent(GlIcon).props('name')).toBe('tanuki-verified');
      });
    });

    describe('when item is a foundational third-party flow', () => {
      beforeEach(() => {
        createComponent({
          item: {
            ...mockThirdPartyFlow,
            foundational: true,
          },
        });
      });

      it('displays "Foundational agent" text', () => {
        const foundational = findFoundationalItem();
        expect(foundational.text()).toBe('GitLab-managed');
        expect(foundational.findComponent(GlIcon).props('name')).toBe('tanuki-verified');
      });
    });

    it('does not display foundational metadata when item is not foundational', () => {
      createComponent({
        item: {
          ...mockAgent,
          foundational: false,
        },
      });

      expect(findFoundationalItem().exists()).toBe(false);
    });
  });

  describe('external field', () => {
    describe('when item type is AI_CATALOG_TYPE_THIRD_PARTY_FLOW', () => {
      beforeEach(() => {
        createComponent({ item: mockThirdPartyFlow });
      });

      it('displays the "External" label with the correct icon', () => {
        const external = findExternalItem();
        expect(external.exists()).toBe(true);
        expect(external.text()).toContain('External');
        expect(external.findComponent(GlIcon).props('name')).toBe('connected');
      });

      it('has the correct tooltip text', () => {
        expect(getBinding(findExternalItem().element, 'gl-tooltip').value).toBe(
          'Connects to an AI model provider outside GitLab.',
        );
      });
    });

    describe('when item type is not AI_CATALOG_TYPE_THIRD_PARTY_FLOW', () => {
      beforeEach(() => {
        createComponent();
      });

      it('does not display the external metadata', () => {
        expect(findExternalItem().exists()).toBe(false);
      });
    });
  });

  describe('version field', () => {
    beforeEach(() => {
      createComponent();
    });

    it('should show the human-readable version with correct value and icon', () => {
      const version = findVersionItem();
      expect(version.exists()).toBe(true);
      expect(version.findComponent(GlIcon).props('name')).toBe('tag');
      expect(version.text()).toContain('v1.0.0-draft');
    });
  });

  describe('usage count field', () => {
    const findUsageCountItem = () => wrapper.findByTestId('metadata-usage-count');

    beforeEach(() => {
      createComponent();
    });

    it('renders the usage count metadata item with chart icon', () => {
      const usageCount = findUsageCountItem();
      expect(usageCount.exists()).toBe(true);
      expect(usageCount.findComponent(GlIcon).props('name')).toBe('chart');
    });

    it('displays the count value from the item', () => {
      const usageCount = findUsageCountItem();
      expect(usageCount.text()).toContain('0');
    });

    it('has the correct tooltip binding', () => {
      expect(getBinding(findUsageCountItem().element, 'gl-tooltip').value).toBe(
        'The number of projects that have used this item in the last 30 days.',
      );
    });
  });
});
