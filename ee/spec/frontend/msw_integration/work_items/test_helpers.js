import { within } from '@testing-library/vue';
import { escapeRegExp } from 'lodash-es';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import {
  findByGraphQLId,
  waitForElement,
  waitForAssertion,
} from 'ee_jest/msw_integration/helpers/test_helpers';
import {
  labelsResponse,
  autocompleteUsersResponse,
  milestonesResponse,
  baseUpdateResponse,
} from './handlers';

/**
 * Work item specific test helpers for MSW integration tests.
 * These helpers are specific to work item drawer/panel interactions.
 */

/**
 * Finds an element within the contextual panel portal by data-testid.
 * @param {string} testId - The data-testid value to search for
 * @returns {HTMLElement|null}
 */
function withinDrawer() {
  const portalEl = document.getElementById('contextual-panel-portal');
  if (!portalEl) return null;
  return within(portalEl);
}

export function findInDrawer(testId) {
  return withinDrawer()?.queryByTestId(testId) ?? null;
}

/**
 * Creates a portal element for testing drawer/modal interactions.
 * Should be called in beforeAll hook.
 * @param {string} [id='contextual-panel-portal'] - The ID for the portal element
 * @returns {HTMLElement}
 */
export function createPortalElement(id = 'contextual-panel-portal') {
  const existing = document.getElementById(id);
  if (existing) return existing;

  const portalEl = document.createElement('div');
  portalEl.id = id;
  document.body.appendChild(portalEl);
  return portalEl;
}

export const firstLabel = labelsResponse.data.namespace.labels.nodes[0];
export const firstUser = autocompleteUsersResponse.data.namespace.users[0];
export const firstMilestone = milestonesResponse.data.namespace.attributes.nodes[0];
export const workItemId = baseUpdateResponse.data.workItemUpdate.workItem.id;

export const findIssueToEdit = () => findByGraphQLId(workItemId, getIdFromGraphQLId);

export const findWorkItemDetail = () => findInDrawer('work-item-detail');
export const findEditFormButton = () => findInDrawer('work-item-edit-form-button');
export const findTitleInput = () =>
  withinDrawer()?.queryByRole('textbox', { name: /title/i }) ?? null;
export const findWorkItemTitle = () => findInDrawer('work-item-title');
export const findDescriptionWrapper = () => findInDrawer('work-item-description-wrapper');
export const findAssigneesWidget = () => findInDrawer('work-item-assignees');
export const findLabelsWidget = () => findInDrawer('work-item-labels');
export const findActionsDropdown = () =>
  withinDrawer()?.queryByRole('button', { name: /more actions/i }) ?? null;
export const findConfidentialityAction = () => findInDrawer('confidentiality-toggle-action');
export const findMilestoneWidget = () => findInDrawer('work-item-milestone');
export const findSubscribeButton = () => findInDrawer('subscribe-button');
export const findDatesWidget = () => findInDrawer('work-item-due-dates');
export const findConfirmButton = () => findInDrawer('confirm-button');
export const findApplyButton = () => findInDrawer('apply-button');
export const findStartDateValue = () => findInDrawer('start-date-value');
export const findDueDateValue = () => findInDrawer('due-date-value');
export const findUserListboxItem = () =>
  withinDrawer()?.queryByRole('option', { name: new RegExp(escapeRegExp(firstUser.name), 'i') }) ??
  null;
export const findLabelListboxItem = () =>
  withinDrawer()?.queryByRole('option', {
    name: new RegExp(escapeRegExp(firstLabel.title), 'i'),
  }) ?? null;
export const findMilestoneListboxItem = () =>
  withinDrawer()?.queryByRole('option', {
    name: new RegExp(escapeRegExp(firstMilestone.title), 'i'),
  }) ?? null;
export const findRelationshipsWidget = () => findInDrawer('work-item-relationships');
export const findLinkItemAddButton = () => findInDrawer('link-item-add-button');
export const findLinkItemForm = () => findInDrawer('link-work-item-form');
export const findLinkWorkItemSubmitButton = () => findInDrawer('link-work-item-button');
export const findLinkedItemsCountBadge = () => findInDrawer('linked-items-count-bage');
export const findRemoveLinkedItemButton = () => findInDrawer('remove-work-item-link');
export const findTokenSelectorInput = () =>
  withinDrawer()?.queryByTestId('work-item-token-select-input')?.querySelector('input') ?? null;
export const findTokenSelectorResult = () =>
  withinDrawer()?.queryByText('Linkable test issue', { exact: false }) ?? null;
export const findTodosToggleButton = () =>
  withinDrawer()?.queryByRole('button', { name: /mark to-do items done/i }) ?? null;

export const findIssuableTitleLink = () =>
  within(findIssueToEdit()).queryByTestId('issuable-title-link');
export const findAssigneeLink = () => within(findIssueToEdit()).queryByTestId('assignee-link');
export const findConfidentialIcon = () =>
  within(findIssueToEdit()).queryByTestId('confidential-icon-container');
export const findIssuableComments = () =>
  within(findIssueToEdit()).queryByTestId('issuable-comments');
export const findIssuableDueDate = () =>
  within(findIssueToEdit()).queryByTestId('issuable-due-date');

export const clickIssue = () => {
  findIssueToEdit().click();
};

export const selectIssue = async () => {
  clickIssue();
  await waitForElement(findWorkItemDetail);
};

/**
 * Returns the widget's edit button only once it accepts clicks.
 *
 * While an update is in flight the button stays in the DOM but GlButton marks it
 * `aria-disabled` (not natively disabled, so it keeps focus) and drops clicks on it.
 * Waiting for it to become enabled avoids a click that silently does nothing.
 *
 * @param {Function} finder - A function that returns the widget element
 * @returns {Function} A finder for the edit button, or null while it is disabled
 */
export const findEnabledEditButton = (finder) => () => {
  const widget = finder();
  const button = widget ? within(widget).queryByTestId('edit-button') : null;
  return button?.getAttribute('aria-disabled') === 'true' ? null : button;
};

export const startEditing = async (finder) => {
  const button = await waitForElement(findEnabledEditButton(finder));
  button.click();
  await waitForAssertion(() => {
    expect(finder().querySelector('[role="listbox"]')).not.toBe(null);
  });
};

export const closeListbox = (finder) => {
  within(finder()).queryByTestId('base-dropdown-toggle').click();
};
