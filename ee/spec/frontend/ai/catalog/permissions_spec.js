import { isLoggedIn } from '~/lib/utils/common_utils';
import {
  canCreateAiCatalogItem,
  canEditAiCatalogItem,
  canDuplicateAiCatalogItem,
} from 'ee/ai/catalog/permissions';
import {
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
} from 'ee/ai/catalog/constants';

jest.mock('~/lib/utils/common_utils');

describe('AI Catalog Permissions', () => {
  beforeEach(() => {
    isLoggedIn.mockReturnValue(true);
  });

  describe('canCreateAiCatalogItem', () => {
    describe('when isGlobalNamespace is true', () => {
      it('returns true', () => {
        expect(canCreateAiCatalogItem({ isGlobalNamespace: true })).toBe(true);
        expect(
          canCreateAiCatalogItem({
            isGlobalNamespace: true,
            glAbilities: { adminAiCatalogItem: false },
          }),
        ).toBe(true);
      });
    });

    describe('when isGlobalNamespace is false or not provided', () => {
      it('returns false when glAbilities.adminAiCatalogItem is false', () => {
        expect(canCreateAiCatalogItem({ glAbilities: { adminAiCatalogItem: false } })).toBe(false);
        expect(canCreateAiCatalogItem({})).toBe(false);
      });

      it('returns true when glAbilities.adminAiCatalogItem is true', () => {
        expect(canCreateAiCatalogItem({ glAbilities: { adminAiCatalogItem: true } })).toBe(true);
      });
    });
  });

  describe('canDuplicateAiCatalogItem', () => {
    it('returns false when user is not logged in', () => {
      isLoggedIn.mockReturnValue(false);

      expect(
        canDuplicateAiCatalogItem(
          {
            itemType: AI_CATALOG_TYPE_AGENT,
            userPermissions: { adminAiCatalogItem: true },
          },
          { isGlobalNamespace: true },
        ),
      ).toBe(false);
    });

    it('returns false when item is null or undefined', () => {
      expect(canDuplicateAiCatalogItem(null)).toBe(false);
      expect(canDuplicateAiCatalogItem(undefined)).toBe(false);
    });

    it.each`
      isGlobalNamespace | adminPermission | expected
      ${true}           | ${false}        | ${true}
      ${true}           | ${true}         | ${true}
      ${false}          | ${false}        | ${false}
      ${false}          | ${true}         | ${true}
    `(
      'with isGlobalNamespace = $isGlobalNamespace and adminAiCatalogItem = $adminPermission returns $expected',
      ({ isGlobalNamespace, adminPermission, expected }) => {
        expect(
          canDuplicateAiCatalogItem(
            {
              itemType: AI_CATALOG_TYPE_AGENT,
              userPermissions: { adminAiCatalogItem: adminPermission },
            },
            { isGlobalNamespace },
          ),
        ).toBe(expected);
      },
    );

    describe('when itemType is THIRD_PARTY_FLOW', () => {
      it.each`
        isGlobalNamespace | createAbility | adminPermission | expected
        ${false}          | ${false}      | ${true}         | ${false}
        ${false}          | ${true}       | ${true}         | ${true}
        ${true}           | ${true}       | ${false}        | ${true}
        ${true}           | ${false}      | ${false}        | ${false}
      `(
        'with isGlobalNamespace = $isGlobalNamespace, createAiCatalogThirdPartyFlow = $createAbility, and adminAiCatalogItem = $adminPermission returns $expected',
        ({ isGlobalNamespace, createAbility, adminPermission, expected }) => {
          expect(
            canDuplicateAiCatalogItem(
              {
                itemType: AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
                userPermissions: { adminAiCatalogItem: adminPermission },
              },
              {
                isGlobalNamespace,
                glAbilities: { createAiCatalogThirdPartyFlow: createAbility },
              },
            ),
          ).toBe(expected);
        },
      );

      it('uses glFeatures as fallback when glAbilities is not set', () => {
        expect(
          canDuplicateAiCatalogItem(
            {
              itemType: AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
              userPermissions: { adminAiCatalogItem: true },
            },
            {
              isGlobalNamespace: false,
              glFeatures: {
                aiCatalogThirdPartyFlows: true,
                aiCatalogCreateThirdPartyFlows: true,
              },
            },
          ),
        ).toBe(true);
      });
    });

    describe('when itemType is FLOW and item is foundational', () => {
      it.each`
        isGlobalNamespace | adminPermission
        ${true}           | ${true}
        ${true}           | ${false}
        ${false}          | ${true}
        ${false}          | ${false}
      `(
        'returns false with isGlobalNamespace = $isGlobalNamespace and adminAiCatalogItem = $adminPermission',
        ({ isGlobalNamespace, adminPermission }) => {
          expect(
            canDuplicateAiCatalogItem(
              {
                itemType: AI_CATALOG_TYPE_FLOW,
                foundational: true,
                userPermissions: { adminAiCatalogItem: adminPermission },
              },
              { isGlobalNamespace },
            ),
          ).toBe(false);
        },
      );
    });

    it('returns true for foundational agents', () => {
      expect(
        canDuplicateAiCatalogItem(
          {
            itemType: AI_CATALOG_TYPE_AGENT,
            foundational: true,
            userPermissions: { adminAiCatalogItem: true },
          },
          { isGlobalNamespace: true },
        ),
      ).toBe(true);
    });

    it.each`
      itemType
      ${AI_CATALOG_TYPE_AGENT}
      ${AI_CATALOG_TYPE_FLOW}
    `('when itemType is $itemType ignores glAbilities and glFeatures', ({ itemType }) => {
      expect(
        canDuplicateAiCatalogItem(
          {
            itemType,
            userPermissions: { adminAiCatalogItem: true },
          },
          {
            isGlobalNamespace: false,
            glAbilities: { createAiCatalogThirdPartyFlow: false },
            glFeatures: { aiCatalogThirdPartyFlows: false },
          },
        ),
      ).toBe(true);
    });

    it('defaults isGlobalNamespace to false when not provided', () => {
      expect(
        canDuplicateAiCatalogItem({
          itemType: AI_CATALOG_TYPE_AGENT,
          userPermissions: { adminAiCatalogItem: false },
        }),
      ).toBe(false);
    });

    it('defaults glAbilities and glFeatures to empty objects', () => {
      expect(
        canDuplicateAiCatalogItem(
          {
            itemType: AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
            userPermissions: { adminAiCatalogItem: true },
          },
          { isGlobalNamespace: false },
        ),
      ).toBe(false);
    });
  });

  describe('canEditAiCatalogItem', () => {
    it('returns false when item is null or undefined', () => {
      expect(canEditAiCatalogItem(null)).toBe(false);
      expect(canEditAiCatalogItem(undefined)).toBe(false);
    });

    it('returns false when item has no userPermissions', () => {
      expect(canEditAiCatalogItem({})).toBe(false);
      expect(canEditAiCatalogItem({ userPermissions: null })).toBe(false);
    });

    it('returns false when adminAiCatalogItem is false', () => {
      expect(
        canEditAiCatalogItem({
          userPermissions: { adminAiCatalogItem: false },
        }),
      ).toBe(false);
    });

    it('returns true when adminAiCatalogItem is true', () => {
      expect(
        canEditAiCatalogItem({
          userPermissions: { adminAiCatalogItem: true },
        }),
      ).toBe(true);
    });

    it('returns false when adminAiCatalogItem is missing', () => {
      expect(
        canEditAiCatalogItem({
          userPermissions: { otherPermission: true },
        }),
      ).toBe(false);
    });

    it('handles items with additional properties', () => {
      expect(
        canEditAiCatalogItem({
          id: '123',
          name: 'Test Agent',
          userPermissions: { adminAiCatalogItem: true },
        }),
      ).toBe(true);
    });
  });
});
