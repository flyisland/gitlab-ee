import { GlAvatar, GlDisclosureDropdown } from '@gitlab/ui';
import { nextTick } from 'vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import setWindowLocation from 'helpers/set_window_location_helper';
import toast from '~/vue_shared/plugins/global_toast';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import DecisionLogItem from 'ee/work_items/components/decision_log/decision_log_item.vue';
import DecisionLogContext from 'ee/work_items/components/decision_log/decision_log_context.vue';
import { mockDecision, buildMockDecision, buildMockOptions } from './mock_data';

jest.mock('~/vue_shared/plugins/global_toast');

const WORK_ITEM_URL = 'http://test.host/group/-/work_items/7';

describe('DecisionLogItem', () => {
  let wrapper;

  const scrollIntoView = jest.fn();
  HTMLElement.prototype.scrollIntoView = scrollIntoView;

  const settledOption = mockDecision.options.nodes.find((option) => option.selected);
  const unsettledOption = mockDecision.options.nodes.find((option) => !option.selected);

  const createComponent = ({
    decision = mockDecision,
    workItemWebUrl = WORK_ITEM_URL,
    targetAnchor = '',
  } = {}) => {
    wrapper = mountExtended(DecisionLogItem, {
      propsData: { decision, workItemWebUrl, targetAnchor },
    });
  };

  const findAnswer = () => wrapper.findByTestId('decision-answer');
  const findAllAnswers = () => wrapper.findAllByTestId('decision-answer');
  const findQuestion = () => wrapper.findByTestId('decision-question');
  const findDecidedBy = () => wrapper.findByTestId('decision-decided-by');
  const findAvatar = () => wrapper.findComponent(GlAvatar);
  const findTimeagoTooltip = () => wrapper.findComponent(TimeAgoTooltip);
  const findSource = () => wrapper.findByTestId('decision-source');
  const findCommentLink = () => wrapper.findComponentByTestId('decision-comment-link');
  const findContext = () => wrapper.findComponent(DecisionLogContext);
  const findCard = () => wrapper.findByTestId('decision-log-item');
  const findCopyLinkAction = () => wrapper.findComponentByTestId('copy-decision-link-action');
  const findActionsDropdown = () => wrapper.findComponent(GlDisclosureDropdown);
  const findEditAction = () => wrapper.findComponentByTestId('edit-decision-action');
  const findRemoveAction = () => wrapper.findComponentByTestId('remove-decision-action');

  beforeEach(() => {
    setWindowLocation('/group/-/work_items/7');
  });

  describe('when nobody is recorded as having resolved the decision', () => {
    beforeEach(() => {
      createComponent({ decision: buildMockDecision({ resolvedBy: null }) });
    });

    it('drops the attribution', () => {
      expect(findDecidedBy().exists()).toBe(false);
      expect(findAvatar().exists()).toBe(false);
    });

    it('still says when it was decided', () => {
      expect(findTimeagoTooltip().props('time')).toBe(mockDecision.resolvedAt);
    });
  });

  describe('when the decision has no resolved time', () => {
    beforeEach(() => {
      createComponent({ decision: buildMockDecision({ resolvedAt: null }) });
    });

    it('drops the timestamp', () => {
      expect(findTimeagoTooltip().exists()).toBe(false);
    });
  });

  describe('when a decision settled a question', () => {
    beforeEach(() => {
      createComponent();
    });

    it('leads with the settled option', () => {
      expect(findAnswer().text()).toBe(settledOption.content);
    });

    it('names who settled it and when', () => {
      expect(findDecidedBy().text()).toBe(mockDecision.resolvedBy.name);
      expect(findAvatar().props('entityName')).toBe(mockDecision.resolvedBy.name);
      expect(findTimeagoTooltip().props('time')).toBe(mockDecision.resolvedAt);
    });

    it('reads the question under the decision', () => {
      expect(findQuestion().text()).toBe(mockDecision.title);
    });

    it('hands the context and the rationale to the context block', () => {
      expect(findContext().props()).toMatchObject({
        context: mockDecision.description,
        rationale: mockDecision.resolutionRationale,
      });
    });
  });

  describe('when a decision settled several options', () => {
    const bothSettled = [
      { ...unsettledOption, selected: true },
      { ...settledOption, selected: true },
    ];

    beforeEach(() => {
      createComponent({
        decision: buildMockDecision({ options: buildMockOptions(bothSettled) }),
      });
    });

    it('lists every settled option', () => {
      expect(findAllAnswers().wrappers.map((answer) => answer.text())).toEqual(
        bothSettled.map((option) => option.content),
      );
    });
  });

  describe('when no option was settled', () => {
    beforeEach(() => {
      createComponent({
        decision: buildMockDecision({ options: buildMockOptions([unsettledOption]) }),
      });
    });

    it('makes the question the header', () => {
      expect(findAnswer().text()).toBe(mockDecision.title);
    });

    it('does not repeat the question underneath', () => {
      expect(findQuestion().exists()).toBe(false);
    });
  });

  describe('when the decision was marked from a thread', () => {
    beforeEach(() => {
      createComponent({ decision: buildMockDecision({ title: null }) });
    });

    it('renders the decision without a question', () => {
      expect(findAnswer().exists()).toBe(true);
      expect(findQuestion().exists()).toBe(false);
    });
  });

  describe('when the decision has neither context nor rationale', () => {
    beforeEach(() => {
      createComponent({
        decision: buildMockDecision({ description: null, resolutionRationale: null }),
      });
    });

    it('does not render the context block', () => {
      expect(findContext().exists()).toBe(false);
    });
  });

  describe('comment link', () => {
    describe('when the decision was made in a note', () => {
      beforeEach(() => {
        createComponent();
      });

      it('anchors to the note', () => {
        expect(findCommentLink().attributes('href')).toBe(mockDecision.noteUrl);
      });

      it('asks for the panel to get out of the way when followed', () => {
        findCommentLink().vm.$emit('click');

        expect(wrapper.emitted('view-comment')).toHaveLength(1);
      });
    });

    describe('when there is no note to point at', () => {
      beforeEach(() => {
        createComponent({ decision: buildMockDecision({ noteUrl: null }) });
      });

      it('is not rendered', () => {
        expect(findCommentLink().exists()).toBe(false);
      });
    });
  });

  describe('source', () => {
    describe('when Duo suggested the answer', () => {
      beforeEach(() => {
        createComponent();
      });

      it('names who raised the question', () => {
        expect(findSource().text()).toBe(
          `Suggested answer to an open question raised by ${mockDecision.author.name}`,
        );
      });
    });

    describe('when the decision carries a link its author pasted', () => {
      beforeEach(() => {
        createComponent({
          decision: buildMockDecision({ sourceLink: 'https://example.com/note', author: null }),
        });
      });

      it('renders the wording that needs no author', () => {
        expect(findSource().text()).toBe('Recorded manually on this work item');
      });
    });

    describe('when the decision carries the discussion it was marked on', () => {
      beforeEach(() => {
        createComponent({
          decision: buildMockDecision({
            discussionId: `gid://gitlab/Discussion/${'b'.repeat(40)}`,
            author: null,
          }),
        });
      });

      it('renders the wording that needs no author', () => {
        expect(findSource().text()).toBe('Recorded from a thread on this work item');
      });
    });

    describe('when the source names an author it does not have', () => {
      beforeEach(() => {
        createComponent({ decision: buildMockDecision({ author: null }) });
      });

      it('is dropped rather than naming nobody', () => {
        expect(findSource().exists()).toBe(false);
      });
    });
  });
  describe('copy link action', () => {
    describe('when the work item URL is known', () => {
      beforeEach(() => {
        createComponent();
      });

      it('copies a link that reopens the panel on this decision', () => {
        expect(findCopyLinkAction().attributes('data-clipboard-text')).toBe(
          `${WORK_ITEM_URL}?show=decision-log#decision_1`,
        );
      });

      it('confirms the copy to the reader', () => {
        findCopyLinkAction().vm.$emit('action');

        expect(toast).toHaveBeenCalledWith('Link copied to clipboard.');
      });
    });

    describe('when the work item URL is missing', () => {
      beforeEach(() => {
        createComponent({ workItemWebUrl: '' });
      });

      it('offers nothing to copy, rather than a link to the wrong page', () => {
        expect(findActionsDropdown().exists()).toBe(false);
        expect(findCopyLinkAction().exists()).toBe(false);
      });
    });
  });

  describe('the actions that change a decision', () => {
    beforeEach(() => {
      createComponent();
    });

    it('marks removal as destructive', () => {
      expect(findRemoveAction().props('variant')).toBe('danger');
    });

    describe('when edit is selected', () => {
      beforeEach(() => {
        findEditAction().vm.$emit('action');
      });

      it('asks the panel to edit this decision', () => {
        expect(wrapper.emitted('edit')).toHaveLength(1);
      });
    });

    describe('when remove is selected', () => {
      beforeEach(() => {
        findRemoveAction().vm.$emit('action');
      });

      it('asks the panel to remove this decision', () => {
        expect(wrapper.emitted('delete')).toHaveLength(1);
      });
    });
  });

  describe('the anchor a copied link lands on', () => {
    beforeEach(() => {
      createComponent();
    });

    it('names this decision', () => {
      expect(findCard().attributes('id')).toBe('decision_1');
    });

    it('leaves the card unhighlighted', () => {
      expect(findCard().classes()).not.toContain('is-target');
    });
  });

  describe('when the target anchor names this decision', () => {
    beforeEach(async () => {
      createComponent({ targetAnchor: 'decision_1' });
      await nextTick();
    });

    it('highlights the card', () => {
      expect(findCard().classes()).toContain('is-target');
    });

    it('scrolls the card into view', () => {
      expect(scrollIntoView).toHaveBeenCalled();
    });
  });

  describe('when the target anchor names another decision', () => {
    beforeEach(async () => {
      createComponent({ targetAnchor: 'decision_2' });
      await nextTick();
    });

    it('leaves the card unhighlighted', () => {
      expect(findCard().classes()).not.toContain('is-target');
    });

    it('does not scroll the card into view', () => {
      expect(scrollIntoView).not.toHaveBeenCalled();
    });
  });

  // Pasting a link while the panel is already open changes only the hash, so the panel hands down
  // a new anchor instead of the card being rebuilt.
  describe('when the target anchor moves onto this decision', () => {
    beforeEach(async () => {
      createComponent();
      await wrapper.setProps({ targetAnchor: 'decision_1' });
    });

    it('highlights the card', () => {
      expect(findCard().classes()).toContain('is-target');
    });
  });

  describe('when the target anchor moves off this decision', () => {
    beforeEach(async () => {
      createComponent({ targetAnchor: 'decision_1' });
      await wrapper.setProps({ targetAnchor: 'decision_2' });
    });

    it('drops the highlight', () => {
      expect(findCard().classes()).not.toContain('is-target');
    });
  });
});
