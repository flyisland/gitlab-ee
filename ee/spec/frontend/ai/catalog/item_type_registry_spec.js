import {
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
} from 'ee/ai/catalog/constants';
import { itemTypeValidator, getRegistryItem } from 'ee/ai/catalog/item_type_registry';

describe('item_type_registry', () => {
  it.each`
    type                     | label
    ${AI_CATALOG_TYPE_AGENT} | ${'agents'}
    ${AI_CATALOG_TYPE_FLOW}  | ${'flows'}
  `('validates and resolves $label', ({ type }) => {
    expect(itemTypeValidator(type)).toBe(true);
    expect(getRegistryItem(type)).toBeDefined();
  });

  it('rejects third-party flows from the validator', () => {
    expect(itemTypeValidator(AI_CATALOG_TYPE_THIRD_PARTY_FLOW)).toBe(false);
  });

  it('throws for an unknown item type', () => {
    expect(() => getRegistryItem('UNKNOWN')).toThrow('Unknown AI catalog item type: UNKNOWN');
  });
});
