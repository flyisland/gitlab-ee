import { GlSkeletonLoader } from '@gitlab/ui';
import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import setWindowLocation from 'helpers/set_window_location_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import DecisionLogPanel from 'ee/work_items/components/decision_log/decision_log_panel.vue';
import DecisionLogFormModal from 'ee/work_items/components/decision_log/decision_log_form_modal.vue';
import DecisionLogItem from 'ee/work_items/components/decision_log/decision_log_item.vue';
import { decisionLogStubResolvers } from 'ee/work_items/components/decision_log/graphql/stub_resolvers';
import { createAlert } from '~/alert';
import { confirmAction } from '~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal';
import * as urlUtility from '~/lib/utils/url_utility';
import { mockDecisions } from './mock_data';

jest.mock('~/alert');
jest.mock('~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal');

Vue.use(VueApollo);

const participants = [{ id: 'gid://gitlab/User/1', name: 'Avery Patel' }];
const workItemId = 'gid://gitlab/WorkItem/7';
const workItemWebUrl = 'http://test.host/group/-/work_items/7';

const editedFields = {
  title: 'Ship SAML first, SCIM follows',
  resolvedBy: participants[0],
  description: 'The MVP needs authentication before it needs provisioning.',
  resolutionRationale: 'Splitting them would leave the MVP with accounts nothing creates.',
  noteUrl: '',
};

const MountingPortalStub = {
  name: 'MountingPortal',
  template: '<div data-testid="mounting-portal-stub"><slot /></div>',
};

const DynamicPanelStub = {
  name: 'DynamicPanel',
  props: ['header'],
  template: '<div data-testid="dynamic-panel"><slot /></div>',
};

const GlEmptyStateStub = {
  name: 'GlEmptyState',
  props: ['title', 'description'],
  template: '<div><slot name="actions" /></div>',
};

describe('DecisionLogPanel', () => {
  let wrapper;
  let updateResolver;
  let deleteResolver;

  const decisions = mockDecisions;

  const createComponent = ({
    open = true,
    updateHandler = jest.fn(decisionLogStubResolvers.Mutation.workItemDecisionUpdate),
    deleteHandler = jest.fn(decisionLogStubResolvers.Mutation.workItemDecisionDelete),
    ...props
  } = {}) => {
    updateResolver = updateHandler;
    deleteResolver = deleteHandler;

    wrapper = shallowMountExtended(DecisionLogPanel, {
      apolloProvider: createMockApollo([], {
        Mutation: {
          workItemDecisionUpdate: updateResolver,
          workItemDecisionDelete: deleteResolver,
        },
      }),
      propsData: {
        open,
        workItemId,
        decisions,
        participants,
        fullPath: 'group/project',
        isGroup: true,
        workItemWebUrl,
        ...props,
      },
      stubs: {
        MountingPortal: MountingPortalStub,
        DynamicPanel: DynamicPanelStub,
        GlEmptyState: GlEmptyStateStub,
      },
    });
  };

  const findPanel = () => wrapper.findComponentByTestId('decision-log-panel');
  const findCount = () => wrapper.findByTestId('decision-log-count');
  const findEmptyState = () => wrapper.findComponentByTestId('decision-log-empty-state');
  const findAllItems = () => wrapper.findAllComponents(DecisionLogItem);
  const findSkeleton = () => wrapper.findComponent(GlSkeletonLoader);
  const findNewDecisionButton = () => wrapper.findComponentByTestId('new-decision-button');
  const findFormModal = () => wrapper.findComponent(DecisionLogFormModal);
  const pressEscape = () => document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }));

  beforeEach(() => {
    setWindowLocation('/');
    jest.spyOn(urlUtility, 'updateHistory').mockImplementation(() => {});
    confirmAction.mockResolvedValue(true);
  });

  describe('when open', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the panel', () => {
      expect(findPanel().exists()).toBe(true);
    });

    it('titles the panel "Decision log"', () => {
      expect(findPanel().props('header')).toBe('Decision log');
    });

    it('heads the list with the number of decisions captured', () => {
      expect(findCount().text()).toBe('3 decisions captured');
      expect(findAllItems()).toHaveLength(3);
      expect(findEmptyState().exists()).toBe(false);
    });

    it('passes each decision through to its item', () => {
      expect(findAllItems().wrappers.map((item) => item.props('decision'))).toEqual(decisions);
    });

    it('gives every item the work item URL its copy link needs', () => {
      expect(findAllItems().wrappers.map((item) => item.props('workItemWebUrl'))).toEqual(
        decisions.map(() => workItemWebUrl),
      );
    });

    it('tells every item that no decision is targeted', () => {
      expect(findAllItems().wrappers.map((item) => item.props('targetAnchor'))).toEqual(
        decisions.map(() => ''),
      );
    });

    it('offers a New decision button', () => {
      expect(findNewDecisionButton().text()).toBe('New decision');
    });

    it('keeps the form closed', () => {
      expect(findFormModal().props('visible')).toBe(false);
    });

    it('deep-links the panel', () => {
      expect(urlUtility.updateHistory).toHaveBeenCalledWith({
        url: expect.stringContaining('show=decision-log'),
      });
    });

    describe('when the panel asks to close', () => {
      beforeEach(() => {
        findPanel().vm.$emit('close');
      });

      it('emits close', () => {
        expect(wrapper.emitted('close')).toHaveLength(1);
      });
    });

    describe('when an item sends the reader off to its comment', () => {
      beforeEach(() => {
        findAllItems().at(0).vm.$emit('view-comment');
      });

      it('emits close', () => {
        expect(wrapper.emitted('close')).toHaveLength(1);
      });
    });

    describe('when the user presses Escape', () => {
      beforeEach(() => {
        pressEscape();
      });

      it('emits close', () => {
        expect(wrapper.emitted('close')).toHaveLength(1);
      });
    });

    describe('when the New decision button is clicked', () => {
      beforeEach(async () => {
        findNewDecisionButton().vm.$emit('click');
        await nextTick();
      });

      it('opens the form for a new decision', () => {
        expect(findFormModal().props()).toMatchObject({ visible: true, decision: null });
      });

      it('passes the participants to the form', () => {
        expect(findFormModal().props('participants')).toEqual(participants);
      });

      it('passes the workspace to the form, so the decider dropdown can search', () => {
        expect(findFormModal().props()).toMatchObject({
          fullPath: 'group/project',
          isGroup: true,
        });
      });

      describe('when the form hides', () => {
        beforeEach(async () => {
          findFormModal().vm.$emit('hide');
          await nextTick();
        });

        it('closes the form', () => {
          expect(findFormModal().props('visible')).toBe(false);
        });
      });

      describe('when the form saves', () => {
        beforeEach(async () => {
          findFormModal().vm.$emit('save', {});
          await nextTick();
        });

        it('closes the form', () => {
          expect(findFormModal().props('visible')).toBe(false);
        });
      });
    });
  });

  describe('when a decision asks to be edited', () => {
    beforeEach(async () => {
      createComponent();
      findAllItems().at(0).vm.$emit('edit');
      await nextTick();
    });

    it('opens the form on that decision', () => {
      expect(findFormModal().props()).toMatchObject({ visible: true, decision: decisions[0] });
    });

    describe('when the form saves', () => {
      beforeEach(async () => {
        findFormModal().vm.$emit('save', editedFields);
        await waitForPromises();
      });

      it('saves the edited fields against that decision', () => {
        expect(updateResolver).toHaveBeenCalledWith(
          {},
          {
            input: {
              id: decisions[0].id,
              title: editedFields.title,
              description: editedFields.description,
              resolutionRationale: editedFields.resolutionRationale,
              noteUrl: editedFields.noteUrl,
              resolvedBy: {
                id: participants[0].id,
                name: participants[0].name,
                avatarUrl: null,
              },
            },
          },
          expect.anything(),
          expect.anything(),
        );
      });

      it('closes the form', () => {
        expect(findFormModal().props('visible')).toBe(false);
      });
    });
  });

  describe('when the decider was found by search rather than the participants', () => {
    const outsider = {
      id: 'gid://gitlab/User/99',
      name: 'Robin Fox',
      avatarUrl: '/robin.png',
    };

    beforeEach(async () => {
      createComponent();
      findAllItems().at(0).vm.$emit('edit');
      await nextTick();
      findFormModal().vm.$emit('save', { ...editedFields, resolvedBy: outsider });
      await waitForPromises();
    });

    it('saves the decider they picked', () => {
      expect(updateResolver).toHaveBeenCalledWith(
        {},
        { input: expect.objectContaining({ resolvedBy: outsider }) },
        expect.anything(),
        expect.anything(),
      );
    });
  });

  describe('when saving an edited decision fails', () => {
    beforeEach(async () => {
      createComponent({ updateHandler: jest.fn().mockRejectedValue(new Error()) });
      findAllItems().at(0).vm.$emit('edit');
      await nextTick();
      findFormModal().vm.$emit('save', editedFields);
      await waitForPromises();
    });

    it('tells the user the decision was not saved', () => {
      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({
          message: 'Something went wrong when saving the decision. Please try again.',
        }),
      );
    });

    it('keeps the form open, so the changes are not lost', () => {
      expect(findFormModal().props('visible')).toBe(true);
    });
  });

  describe('when a decision asks to be removed', () => {
    beforeEach(async () => {
      createComponent();
      findAllItems().at(0).vm.$emit('delete');
      await waitForPromises();
    });

    it('asks the user to confirm, because a removal cannot be undone', () => {
      expect(confirmAction).toHaveBeenCalledWith(
        'Are you sure you want to remove this decision?',
        expect.objectContaining({ primaryBtnVariant: 'danger' }),
      );
    });

    it('removes the decision from the log', () => {
      expect(deleteResolver).toHaveBeenCalledWith(
        {},
        { input: { id: decisions[0].id, workItemId } },
        expect.anything(),
        expect.anything(),
      );
    });
  });

  describe('when the user dismisses the removal confirmation', () => {
    beforeEach(async () => {
      confirmAction.mockResolvedValue(false);
      createComponent();
      findAllItems().at(0).vm.$emit('delete');
      await waitForPromises();
    });

    it('keeps the decision', () => {
      expect(deleteResolver).not.toHaveBeenCalled();
    });
  });

  describe('when removing a decision fails', () => {
    beforeEach(async () => {
      createComponent({ deleteHandler: jest.fn().mockRejectedValue(new Error()) });
      findAllItems().at(0).vm.$emit('delete');
      await waitForPromises();
    });

    it('tells the user the decision is still there', () => {
      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({
          message: 'Something went wrong when removing the decision. Please try again.',
        }),
      );
    });
  });

  describe('when closed', () => {
    beforeEach(() => {
      createComponent({ open: false });
    });

    it('does not render the panel', () => {
      expect(findPanel().exists()).toBe(false);
    });

    it('does not touch the url', () => {
      expect(urlUtility.updateHistory).not.toHaveBeenCalled();
    });

    describe('when the user presses Escape', () => {
      beforeEach(() => {
        pressEscape();
      });

      it('does not emit close', () => {
        expect(wrapper.emitted('close')).toBeUndefined();
      });
    });
  });

  describe('with no decisions', () => {
    beforeEach(() => {
      createComponent({ decisions: [] });
    });

    it('shows an empty state instead of the list', () => {
      expect(findEmptyState().exists()).toBe(true);
      expect(findCount().exists()).toBe(false);
      expect(findAllItems()).toHaveLength(0);
    });

    it('explains how decisions get captured', () => {
      expect(findEmptyState().props()).toMatchObject({
        title: 'No decisions yet',
      });
    });

    it('offers the New decision button as the empty state action', () => {
      expect(findNewDecisionButton().text()).toBe('New decision');
      expect(findNewDecisionButton().props('variant')).toBe('confirm');
    });

    describe('when the empty state button is clicked', () => {
      beforeEach(async () => {
        findNewDecisionButton().vm.$emit('click');
        await nextTick();
      });

      it('opens the form for a new decision', () => {
        expect(findFormModal().props()).toMatchObject({ visible: true, decision: null });
      });
    });
  });

  describe('while the decisions are loading', () => {
    beforeEach(() => {
      createComponent({ decisions: [], isLoading: true });
    });

    it('holds the empty state back, because nothing has been fetched yet', () => {
      expect(findSkeleton().exists()).toBe(true);
      expect(findEmptyState().exists()).toBe(false);
      expect(findAllItems()).toHaveLength(0);
    });
  });

  describe('when Escape belongs to something else', () => {
    let focused;

    const focus = (element) => {
      focused = element;
      document.body.appendChild(focused);
      focused.focus();
    };

    afterEach(() => {
      focused?.remove();
      focused = undefined;
      document.body.classList.remove('modal-open');
    });

    describe.each(['INPUT', 'TEXTAREA'])('when focus is in a %s', (tagName) => {
      beforeEach(() => {
        focus(document.createElement(tagName));
        createComponent();

        pressEscape();
      });

      it('does not emit close', () => {
        expect(wrapper.emitted('close')).toBeUndefined();
      });
    });

    describe('when focus is in a rich text field', () => {
      beforeEach(() => {
        const editor = document.createElement('div');
        editor.setAttribute('contenteditable', 'true');
        editor.tabIndex = 0;
        focus(editor);
        createComponent();

        pressEscape();
      });

      it('does not emit close', () => {
        expect(wrapper.emitted('close')).toBeUndefined();
      });
    });

    describe('when a modal is open', () => {
      beforeEach(() => {
        document.body.classList.add('modal-open');
        createComponent();

        pressEscape();
      });

      it('does not emit close', () => {
        expect(wrapper.emitted('close')).toBeUndefined();
      });
    });
  });

  describe('when the decision log show param is set', () => {
    beforeEach(() => {
      setWindowLocation('?show=decision-log');
      createComponent();
    });

    it('does not rewrite the url', () => {
      expect(urlUtility.updateHistory).not.toHaveBeenCalled();
    });

    describe('when the panel closes', () => {
      beforeEach(async () => {
        await wrapper.setProps({ open: false });
      });

      it('clears the param', () => {
        expect(urlUtility.updateHistory).toHaveBeenCalledWith({
          url: expect.not.stringContaining('show='),
        });
      });
    });
  });

  describe('when the reader arrived on a decision anchor', () => {
    beforeEach(() => {
      setWindowLocation('?show=decision-log#decision_1');
      createComponent();
    });

    it('tells every item which decision is targeted', () => {
      expect(findAllItems().wrappers.map((item) => item.props('targetAnchor'))).toEqual(
        decisions.map(() => 'decision_1'),
      );
    });

    // Pasting a link while the panel is already open changes only the hash, so the browser fires
    // hashchange instead of reloading.
    describe('when the hash moves to another decision without a reload', () => {
      beforeEach(async () => {
        setWindowLocation('#decision_2');
        window.dispatchEvent(new HashChangeEvent('hashchange'));
        await nextTick();
      });

      it('hands the new anchor down', () => {
        expect(findAllItems().wrappers.map((item) => item.props('targetAnchor'))).toEqual(
          decisions.map(() => 'decision_2'),
        );
      });
    });

    describe('when the panel is destroyed', () => {
      beforeEach(() => {
        wrapper.destroy();
        setWindowLocation('#decision_2');
      });

      it('stops listening for hash changes', () => {
        expect(() => window.dispatchEvent(new HashChangeEvent('hashchange'))).not.toThrow();
      });
    });

    describe('when the panel closes', () => {
      beforeEach(async () => {
        await wrapper.setProps({ open: false });
      });

      it('clears the anchor along with the param', () => {
        expect(urlUtility.updateHistory).toHaveBeenCalledWith({
          url: expect.not.stringContaining('#'),
        });
      });
    });
  });

  describe('when the hash belongs to the page behind the panel', () => {
    beforeEach(() => {
      setWindowLocation('?show=decision-log#note_5');
      createComponent();
    });

    describe('when the panel closes', () => {
      beforeEach(async () => {
        await wrapper.setProps({ open: false });
      });

      it('leaves the hash alone', () => {
        expect(urlUtility.updateHistory).toHaveBeenCalledWith({
          url: expect.stringContaining('#note_5'),
        });
      });
    });
  });

  describe('when another panel has claimed the show param', () => {
    beforeEach(() => {
      setWindowLocation('?show=decision-log');
      createComponent();
      setWindowLocation('?show=workplan');
      urlUtility.updateHistory.mockClear();
    });

    describe('when the panel closes', () => {
      beforeEach(async () => {
        await wrapper.setProps({ open: false });
      });

      it('leaves the param alone', () => {
        expect(urlUtility.updateHistory).not.toHaveBeenCalled();
      });
    });
  });
});
