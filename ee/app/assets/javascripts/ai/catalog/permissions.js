import { isLoggedIn } from '~/lib/utils/common_utils';
import { AI_CATALOG_TYPE_FLOW, AI_CATALOG_TYPE_THIRD_PARTY_FLOW } from './constants';

/**
 * Checks if user has admin permission on an item
 *
 * @param {Object} item - The AI Catalog item
 * @returns {Boolean}
 */
const canAdminItem = (item) => {
  return Boolean(item?.userPermissions?.adminAiCatalogItem);
};

/**
 * Checks if third-party flows are allowed based on glAbilities and glFeatures
 *
 * @param {Object} glAbilities - GitLab abilities object
 * @param {Object} glFeatures - GitLab features object
 * @returns {Boolean}
 */
const canCreateThirdPartyFlow = (glAbilities = {}, glFeatures = {}) => {
  // Use abilities when on project level, fallback to feature flags on explore level
  return Boolean(
    glAbilities.createAiCatalogThirdPartyFlow ??
      (glFeatures.aiCatalogThirdPartyFlows && glFeatures.aiCatalogCreateThirdPartyFlows),
  );
};

/**
 * Checks if user can create a new item.
 * Does not include isLoggedIn check as that's handled on the router level.
 *
 * @param {Object} options - Additional options
 * @param {Boolean} options.isGlobalNamespace - Whether viewing from explore page
 * @param {Object} options.glAbilities - GitLab abilities object
 * @returns {Boolean}
 */
export const canCreateAiCatalogItem = (options = {}) => {
  const { isGlobalNamespace = false, glAbilities = {} } = options;

  // When viewing from explore page, allow access as we don't know the permissions
  if (isGlobalNamespace) {
    return true;
  }

  // When viewing from project page, we use the admin_ai_catalog_item permissions
  return Boolean(glAbilities.adminAiCatalogItem);
};

/**
 * Checks if user can duplicate an existing item.
 * Duplicate has same permissions as edit, with additional checks for third-party flows
 * and foundational flows.
 *
 * @param {Object} item - The AI Catalog item
 * @param {Object} options - Additional options
 * @param {Boolean} options.isGlobalNamespace - Whether viewing from explore page
 * @param {Boolean} options.isGroupNamespace - Whether viewing from group page
 * @param {Object} options.glAbilities - GitLab abilities object
 * @param {Object} options.glFeatures - GitLab features object
 * @returns {Boolean}
 */
export const canDuplicateAiCatalogItem = (item, options = {}) => {
  const {
    isGlobalNamespace = false,
    isGroupNamespace = false,
    glAbilities = {},
    glFeatures = {},
  } = options;

  if (!item || !isLoggedIn()) {
    return false;
  }

  // Duplication is not available at group level
  if (isGroupNamespace) {
    return false;
  }

  // Third-party flows need creation ability
  if (item.itemType === AI_CATALOG_TYPE_THIRD_PARTY_FLOW) {
    if (!canCreateThirdPartyFlow(glAbilities, glFeatures)) {
      return false;
    }
  }

  // Foundational flow YAML exists only in Duo Workflow Service, and so the monolith cannot duplicate it.
  if (item.itemType === AI_CATALOG_TYPE_FLOW && item.foundational) {
    return false;
  }

  // When viewing from explore page, allow duplication button as we don't know the permissions
  if (isGlobalNamespace) {
    return true;
  }

  // When viewing from project page, we use the admin_ai_catalog_item permissions
  return canAdminItem(item);
};

/**
 * Checks if user can edit an existing item.
 * Does not include isLoggedIn check as that's handled on the router level.
 *
 * @param {Object} item - The AI Catalog item
 * @returns {Boolean}
 */
export const canEditAiCatalogItem = (item) => {
  return canAdminItem(item);
};
