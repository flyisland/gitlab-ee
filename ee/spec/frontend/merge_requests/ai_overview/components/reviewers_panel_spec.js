import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlAvatar, GlIcon, GlLink } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import HelpPopover from '~/vue_shared/components/help_popover.vue';
import ReviewersPanel from 'ee/merge_requests/ai_overview/components/reviewers_panel.vue';
import setReviewersMutation from '~/merge_requests/components/reviewers/queries/set_reviewers.mutation.graphql';
import {
  interaction,
  makeMergeRequest,
  makeReviewer,
  makeSuggestedReviewer,
  reviewers,
  suggestedReviewers,
} from '../mock_data';

jest.mock('~/alert');

Vue.use(VueApollo);

describe('AI Overview reviewers panel', () => {
  let wrapper;
  let mutationHandler;

  const createComponent = (overrides = {}) => {
    mutationHandler = jest
      .fn()
      .mockResolvedValue({ data: { mergeRequestSetReviewers: { errors: [] } } });

    wrapper = mountExtended(ReviewersPanel, {
      apolloProvider: createMockApollo([[setReviewersMutation, mutationHandler]]),
      provide: { projectPath: 'group/proj', iid: '1' },
      propsData: { mergeRequest: makeMergeRequest(overrides) },
    });
  };

  const findRows = () => wrapper.findAllByTestId('reviewer-row');
  const findSuggestedRows = () => wrapper.findAllByTestId('suggested-reviewer-row');
  const rowIcon = (index) => findRows().at(index).findComponent(GlIcon);
  const findAddButton = () => wrapper.findComponentByTestId('add-suggested-reviewer');

  const reviewerWith = (id, reviewState) =>
    makeReviewer({
      id: `gid://gitlab/User/${id}`,
      username: `user${id}`,
      name: `User ${id}`,
      mergeRequestInteraction: interaction({ approved: false, reviewState }),
    });

  describe('with reviewers', () => {
    beforeEach(() => {
      createComponent({
        reviewers: reviewers(
          makeReviewer(),
          reviewerWith(3, 'REQUESTED_CHANGES'),
          reviewerWith(4, 'REVIEWED'),
          reviewerWith(5, 'REVIEW_STARTED'),
          reviewerWith(6, 'UNREVIEWED'),
        ),
      });
    });

    it('renders one row per reviewer with their avatar and name', () => {
      expect(findRows()).toHaveLength(5);
      expect(findRows().at(0).findComponent(GlAvatar).props('src')).toBe('/avatar.png');
      expect(findRows().at(0).text()).toContain('Elena Kowalski');
    });

    it('links each reviewer to their profile with the user popover data', () => {
      const link = findRows().at(0).findComponent(GlLink);

      expect(link.attributes('href')).toBe('/elena');
      expect(link.classes()).toContain('js-user-link');
      expect(link.attributes('data-user-id')).toBe('2');
      expect(link.attributes('data-username')).toBe('elena');
    });

    it.each`
      index | label                  | variant
      ${0}  | ${'Approved'}          | ${'success'}
      ${1}  | ${'Requested changes'} | ${'danger'}
      ${2}  | ${'Commented'}         | ${'info'}
      ${3}  | ${'Review started'}    | ${'subtle'}
      ${4}  | ${'Awaiting review'}   | ${'subtle'}
    `('shows what reviewer $index has done so far', ({ index, label, variant }) => {
      expect(findRows().at(index).text()).toContain(label);
      expect(rowIcon(index).props('variant')).toBe(variant);
    });

    it('counts the approvals in the header', () => {
      expect(wrapper.text()).toContain('1 of 5 approved');
    });
  });

  describe('without reviewers', () => {
    beforeEach(() => {
      createComponent({ reviewers: reviewers() });
    });

    it('renders an empty state instead of rows', () => {
      expect(findRows()).toHaveLength(0);
      expect(wrapper.text()).toContain('No reviewers yet');
      expect(wrapper.text()).not.toContain('approved');
    });
  });

  it.each`
    description                       | mergeRequestInteraction
    ${'without interaction data'}     | ${null}
    ${'who took their approval back'} | ${interaction({ approved: false, reviewState: 'UNAPPROVED' })}
  `('treats a reviewer $description as awaiting review', ({ mergeRequestInteraction }) => {
    createComponent({ reviewers: reviewers(makeReviewer({ mergeRequestInteraction })) });

    expect(findRows().at(0).text()).toContain('Awaiting review');
  });

  // The state can lag behind the approval itself, so the flag decides.
  it('shows an approval whatever the review state says', () => {
    createComponent({
      reviewers: reviewers(
        makeReviewer({ mergeRequestInteraction: interaction({ reviewState: 'REVIEWED' }) }),
      ),
    });

    expect(findRows().at(0).text()).toContain('Approved');
  });

  describe('recommended reviewers', () => {
    beforeEach(() => {
      createComponent();
    });

    it('lists each suggestion with the rule it was made for', () => {
      expect(findSuggestedRows()).toHaveLength(1);
      expect(findSuggestedRows().at(0).text()).toContain('Sam Okafor');
      expect(findSuggestedRows().at(0).text()).toContain('Backend');
    });

    it('links the suggested user to their profile', () => {
      const link = findSuggestedRows().at(0).findComponent(GlLink);

      expect(link.attributes('href')).toBe('/sam');
      expect(link.attributes('data-user-id')).toBe('5');
    });

    it('keeps the reason behind a help popover', () => {
      const popover = findSuggestedRows().at(0).findComponent(HelpPopover);

      expect(popover.props('ariaLabel')).toBe('Reason for recommended reviewer');
      expect(popover.text()).toBe('Owns the changed files.');
    });

    it('adds the suggested user as a reviewer', async () => {
      expect(findAddButton().attributes('aria-label')).toBe('Add Sam Okafor as a reviewer');

      findAddButton().vm.$emit('click');
      await waitForPromises();

      expect(mutationHandler).toHaveBeenCalledWith({
        projectPath: 'group/proj',
        iid: '1',
        reviewerUsernames: ['sam'],
        operationMode: 'APPEND',
      });
    });

    it('reports a failed add without losing the suggestion', async () => {
      mutationHandler.mockRejectedValue(new Error('nope'));

      findAddButton().vm.$emit('click');
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({
          message: 'Could not add Sam Okafor as a reviewer. Try again later.',
        }),
      );
      expect(findSuggestedRows()).toHaveLength(1);
    });
  });

  it('names the any-approver rule for the reader', () => {
    createComponent({
      aiSuggestedReviewers: suggestedReviewers(
        makeSuggestedReviewer({
          approvalRule: {
            __typename: 'ApprovalRule',
            id: 'gid://gitlab/ApprovalProjectRule/2',
            name: 'All Members',
            type: 'ANY_APPROVER',
          },
        }),
      ),
    });

    expect(findSuggestedRows().at(0).text()).toContain('Any eligible user');
    expect(findSuggestedRows().at(0).text()).not.toContain('All Members');
  });

  it('offers no add button to someone who cannot update the merge request', () => {
    createComponent({
      userPermissions: { __typename: 'MergeRequestPermissions', updateMergeRequest: false },
    });

    expect(findAddButton().exists()).toBe(false);
  });

  it.each`
    description                           | aiSuggestedReviewers
    ${'the flow is off for the project'}  | ${null}
    ${'there is nothing left to suggest'} | ${suggestedReviewers()}
  `('hides the recommended section when $description', ({ aiSuggestedReviewers }) => {
    createComponent({ aiSuggestedReviewers });

    expect(findSuggestedRows()).toHaveLength(0);
    expect(wrapper.text()).not.toContain('Recommended');
  });
});
