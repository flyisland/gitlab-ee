import * as testHelpers from 'jest/msw_integration/test_helpers';
import * as workItemsHelpers from 'jest/msw_integration/work_items/test_helpers';

// eslint-disable-next-line jest/no-export
export function describeDrawerInteractions() {
  describe('when navigating to a work item', () => {
    beforeEach(async () => {
      await workItemsHelpers.selectIssue();
    });

    it('opens the work item detail in the drawer', async () => {
      await testHelpers.waitForElement(workItemsHelpers.findWorkItemDetail);
    });
  });

  describe('when clicking the same issue again', () => {
    beforeEach(async () => {
      await workItemsHelpers.selectIssue();
      workItemsHelpers.clickIssue();
    });

    it('closes the drawer', async () => {
      await testHelpers.waitForElementToBeNull(workItemsHelpers.findWorkItemDetail);
    });
  });

  describe('when user adds a comment from the drawer', () => {
    it('updates comment count', async () => {
      await workItemsHelpers.selectIssue();

      const findTextarea = () =>
        document.getElementById('contextual-panel-portal')?.querySelector('textarea');
      await testHelpers.waitForElement(findTextarea);
      await testHelpers.waitAndSetValue(findTextarea, 'Test comment from drawer');

      await testHelpers.waitAndClick(workItemsHelpers.findConfirmButton);

      await testHelpers.waitForAssertion(() => {
        expect(testHelpers.getText(workItemsHelpers.findIssuableComments())).toContain('1');
      });
    });
  });

  describe('with selected issue', () => {
    beforeEach(async () => {
      await workItemsHelpers.selectIssue();
    });

    describe('when title is edited in the drawer', () => {
      const newTitle = 'New title';

      it('updates work item title in the list', async () => {
        await testHelpers.waitAndClick(workItemsHelpers.findEditFormButton);
        await testHelpers.waitAndSetValue(workItemsHelpers.findTitleInput, newTitle);

        workItemsHelpers
          .findDescriptionWrapper()
          .querySelector('form')
          .dispatchEvent(new Event('submit', { bubbles: true }));

        await testHelpers.waitForAssertion(() => {
          expect(testHelpers.getText(workItemsHelpers.findWorkItemTitle())).toBe(newTitle);
          expect(testHelpers.getText(workItemsHelpers.findIssuableTitleLink())).toBe(newTitle);
        });
      });
    });

    describe('when assignee is changed in the drawer', () => {
      it('updates assignee in the list', async () => {
        await workItemsHelpers.startEditing(workItemsHelpers.findAssigneesWidget);

        await testHelpers.waitAndClick(workItemsHelpers.findUserListboxItem);
        await testHelpers.waitForAssertion(() => {
          expect(workItemsHelpers.findUserListboxItem().getAttribute('aria-selected')).toBe('true');
        });

        workItemsHelpers.closeListbox(workItemsHelpers.findAssigneesWidget);

        await testHelpers.waitForAssertion(() => {
          expect(testHelpers.getText(workItemsHelpers.findAssigneesWidget())).toContain(
            workItemsHelpers.firstUser.name,
          );
          expect(workItemsHelpers.findAssigneeLink().getAttribute('href')).toBe(
            workItemsHelpers.firstUser.webPath,
          );
        });
      });
    });

    describe('when a label is added in the drawer', () => {
      it('updates labels in the list', async () => {
        await workItemsHelpers.startEditing(workItemsHelpers.findLabelsWidget);

        await testHelpers.waitAndClick(workItemsHelpers.findLabelListboxItem);
        await testHelpers.waitForAssertion(() => {
          expect(workItemsHelpers.findLabelListboxItem().getAttribute('aria-selected')).toBe(
            'true',
          );
        });

        workItemsHelpers.closeListbox(workItemsHelpers.findLabelsWidget);

        await testHelpers.waitForAssertion(() => {
          expect(testHelpers.getText(workItemsHelpers.findLabelsWidget())).toContain(
            workItemsHelpers.firstLabel.title,
          );
          expect(testHelpers.getText(workItemsHelpers.findIssueToEdit())).toContain(
            workItemsHelpers.firstLabel.title,
          );
        });
      });
    });

    describe('when confidentiality is toggled in the drawer', () => {
      beforeEach(async () => {
        const actionsDropdown = await testHelpers.waitForElement(
          workItemsHelpers.findActionsDropdown,
        );
        actionsDropdown.querySelector('button').click();
        const confidentialityAction = await testHelpers.waitForElement(
          workItemsHelpers.findConfidentialityAction,
        );
        confidentialityAction.querySelector('button').click();
      });

      it('shows the confidential icon on the list', async () => {
        await testHelpers.waitForElement(workItemsHelpers.findConfidentialIcon);
      });
    });

    describe('when milestone is changed in the drawer', () => {
      beforeEach(async () => {
        await workItemsHelpers.startEditing(workItemsHelpers.findMilestoneWidget);
        await testHelpers.waitAndClick(workItemsHelpers.findMilestoneListboxItem);
      });

      it('updates milestone in the list', async () => {
        await testHelpers.waitForAssertion(() => {
          expect(testHelpers.getText(workItemsHelpers.findMilestoneWidget())).toContain(
            workItemsHelpers.firstMilestone.title,
          );
          expect(testHelpers.getText(workItemsHelpers.findIssueToEdit())).toContain(
            workItemsHelpers.firstMilestone.title,
          );
        });
      });
    });

    describe('when notifications subscription is toggled', () => {
      beforeEach(async () => {
        await testHelpers.waitForElement(workItemsHelpers.findSubscribeButton);
      });

      it('toggles subscription off and back on', async () => {
        await testHelpers.waitForAssertion(() => {
          expect(workItemsHelpers.findSubscribeButton().dataset.subscribed).toBe('true');
        });

        await testHelpers.waitAndClick(workItemsHelpers.findSubscribeButton);

        await testHelpers.waitForAssertion(() => {
          expect(workItemsHelpers.findSubscribeButton().dataset.subscribed).toBe('false');
        });

        await testHelpers.waitAndClick(workItemsHelpers.findSubscribeButton);

        await testHelpers.waitForAssertion(() => {
          expect(workItemsHelpers.findSubscribeButton().dataset.subscribed).toBe('true');
        });
      });
    });

    describe('when dates are changed in the drawer', () => {
      it('updates start and due date on the list', async () => {
        const portalEl = document.getElementById('contextual-panel-portal');

        const datesWidget = await testHelpers.waitForElement(workItemsHelpers.findDatesWidget);
        testHelpers.findByTestId('edit-button', datesWidget).click();

        const findStartInput = () => portalEl.querySelector('#start-date-input');
        const findDueInput = () => portalEl.querySelector('#due-date-input');

        await testHelpers.waitAndSetValue(findStartInput, '2025-01-01', 'change');
        await testHelpers.waitAndSetValue(findDueInput, '2025-12-31', 'change');

        await testHelpers.waitAndClick(workItemsHelpers.findApplyButton);

        await testHelpers.waitForAssertion(() => {
          expect(testHelpers.getText(workItemsHelpers.findStartDateValue())).not.toBe('None');
          expect(testHelpers.getText(workItemsHelpers.findDueDateValue())).not.toBe('None');
          expect(workItemsHelpers.findIssuableDueDate()).not.toBe(null);
        });
      });
    });
  });
}
