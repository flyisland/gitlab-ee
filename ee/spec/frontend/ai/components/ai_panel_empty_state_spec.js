// eslint-disable-next-line no-restricted-syntax -- test mocks viewport breakpoints used by the source component
import { GlBreakpointInstance } from '@gitlab/ui/src/utils';
import { GlIcon, GlSprintf } from '@gitlab/ui';
import { createWrapper } from '@vue/test-utils';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { userCalloutMutationResponse } from 'jest/vue_shared/components/user_callout_dismisser_mock_data';
import AiPanelEmptyState from 'ee/ai/components/ai_panel_empty_state.vue';
import { DUO_PANEL_EMPTY_STATE_EVENTS } from 'ee/ai/constants';
import { BV_HIDE_TOOLTIP } from '~/lib/utils/constants';
import dismissUserCalloutMutation from '~/graphql_shared/mutations/dismiss_user_callout.mutation.graphql';

const newTrialPathMock = '/-/trials/new';
const trialDurationMock = '20';
const buyAddonPathMock = 'https://customers.gitlab.com/subscriptions';

const mutationSuccessHandlerSpy = jest.fn((variables) =>
  Promise.resolve(userCalloutMutationResponse(variables)),
);

const triggerResize = () => {
  window.dispatchEvent(new Event('resize'));
};
const { bindInternalEventDocument } = useMockInternalEventsTracking();

Vue.use(VueApollo);

describe('AiPanelEmptyState', () => {
  let wrapper;
  let mockApollo;

  const findPanelContent = () => wrapper.findByTestId('panel-content');
  const findTogglePanelContentButton = () => wrapper.findByTestId('toggle-panel-content-button');
  const findClosePanelContentButton = () =>
    wrapper.findByTestId('content-container-collapse-button');
  const findEmptyStateText = () => wrapper.findByTestId('empty-state-text');
  const findStartTrialLink = () => wrapper.findByTestId('start-trial-link');
  const findLearnMoreLink = () => wrapper.findByTestId('learn-more-link');
  const findLearnMoreButton = () => wrapper.findByTestId('learn-more-button');
  const findUpgradeButton = () => wrapper.findByTestId('upgrade-button');
  const findWorkflowExamples = () => wrapper.findAllByTestId('workflow-example');

  const createComponent = (provide = {}) => {
    mockApollo = createMockApollo([[dismissUserCalloutMutation, mutationSuccessHandlerSpy]], {});

    wrapper = shallowMountExtended(AiPanelEmptyState, {
      apolloProvider: mockApollo,
      provide: {
        canStartTrial: true,
        newTrialPath: newTrialPathMock,
        trialDuration: trialDurationMock,
        autoExpand: true,
        ...provide,
      },
      stubs: {
        GlSprintf,
      },
      directives: {
        GlTooltip: createMockDirective('gl-tooltip'),
      },
    });
  };

  it('renders the correct content', () => {
    createComponent();
    const workflowExamples = findWorkflowExamples();

    expect(findEmptyStateText().text()).toMatchInterpolatedText(
      'Start your free 20-day trial now to accelerate your software delivery. Automate tasks with AI agents, from searching projects to creating commits.',
    );

    expect(findStartTrialLink().props('href')).toBe(newTrialPathMock);
    expect(findLearnMoreLink().props('href')).toBe('/help/user/duo_agent_platform/_index.md');

    expect(workflowExamples.at(0).findComponent(GlIcon).props('name')).toBe('merge-request');
    expect(workflowExamples.at(0).text()).toContain('Review a merge request');
    expect(workflowExamples.at(0).text()).toContain('Identify code improvements');

    expect(workflowExamples.at(1).findComponent(GlIcon).props('name')).toBe('pipeline');
    expect(workflowExamples.at(1).text()).toContain('Fix a failing pipeline');
    expect(workflowExamples.at(1).text()).toContain(
      'Analyze pipeline failures and get fix suggestions',
    );
  });

  it('tracks the `view_duo_agentic_not_available_empty_state` on mount', () => {
    createComponent();
    const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

    expect(trackEventSpy).toHaveBeenCalledWith(
      DUO_PANEL_EMPTY_STATE_EVENTS.VIEW_NOT_AVAILABLE,
      {},
      undefined,
    );
  });

  it('adds the correct tracking properties to the "Start a Free Trial" link', () => {
    createComponent();

    expect(findStartTrialLink().attributes()).toMatchObject({
      'data-event-tracking': 'click_link',
      'data-event-label': DUO_PANEL_EMPTY_STATE_EVENTS.CLICK_START_TRIAL,
    });
  });

  it('adds the correct tracking properties to the "Learn more" link', () => {
    createComponent();

    expect(findLearnMoreLink().attributes()).toMatchObject({
      'data-event-tracking': 'click_link',
      'data-event-label': DUO_PANEL_EMPTY_STATE_EVENTS.CLICK_LEARN_MORE,
    });
  });

  it('collapses the panel upon clicking the close button', async () => {
    createComponent();

    expect(findPanelContent().exists()).toBe(true);

    findClosePanelContentButton().vm.$emit('click');
    await waitForPromises();

    expect(findPanelContent().exists()).toBe(false);
  });

  describe('on desktop', () => {
    beforeEach(() => {
      jest.spyOn(GlBreakpointInstance, 'isDesktop').mockReturnValue(true);
    });

    describe('when the user callout was not dismissed yet', () => {
      beforeEach(() => {
        createComponent();
      });

      it('starts with content expanded', () => {
        expect(findPanelContent().exists()).toBe(true);
      });

      it('collapses the content if the window gets narrower', async () => {
        GlBreakpointInstance.isDesktop.mockReturnValue(false);
        triggerResize();
        await waitForPromises();

        expect(findPanelContent().exists()).toBe(false);
        expect(mutationSuccessHandlerSpy).not.toHaveBeenCalled();
      });

      describe('when clicking the toggle button', () => {
        beforeEach(() => {
          findTogglePanelContentButton().vm.$emit('click');

          return waitForPromises();
        });

        it('dismisses the user callout', () => {
          expect(mutationSuccessHandlerSpy).toHaveBeenCalledWith({
            input: { featureName: 'duo_panel_empty_state_auto_expanded' },
          });
        });
      });
    });

    describe('when the user callout was previously dismissed', () => {
      beforeEach(() => {
        return createComponent({
          autoExpand: false,
        });
      });

      it('starts with content collapsed', () => {
        expect(findPanelContent().exists()).toBe(false);
      });
    });
  });

  describe('on mobile', () => {
    beforeEach(() => {
      jest.spyOn(GlBreakpointInstance, 'isDesktop').mockReturnValue(false);
    });

    describe('when the panel was not toggled manually yet', () => {
      beforeEach(() => {
        createComponent();
      });

      it('starts with content collapsed', () => {
        expect(findPanelContent().exists()).toBe(false);
      });
    });
  });

  describe('when the user cannot start a trial', () => {
    it('renders the correct content', () => {
      createComponent({
        canStartTrial: false,
      });

      expect(findEmptyStateText().text()).toMatchInterpolatedText(
        "You don't have permission to use GitLab Duo Agent Platform in this project. Learn more.",
      );
      expect(findLearnMoreLink().props('href')).toBe('/help/user/duo_agent_platform/_index.md');
    });

    it('shows the correct text when the namespace is a group', () => {
      createComponent({
        canStartTrial: false,
        namespaceType: 'Group',
      });

      expect(findEmptyStateText().text()).toMatchInterpolatedText(
        "You don't have permission to use GitLab Duo Agent Platform in this group. Learn more.",
      );
    });

    it('adds the correct tracking properties to the "Learn more" link', () => {
      createComponent({
        canStartTrial: false,
      });

      expect(findLearnMoreLink().attributes()).toMatchObject({
        'data-event-tracking': 'click_link',
        'data-event-label': DUO_PANEL_EMPTY_STATE_EVENTS.CLICK_LEARN_MORE,
      });
    });
  });

  describe('tooltips', () => {
    beforeEach(createComponent);

    it('adds a tooltip to the toggle button', () => {
      const button = findTogglePanelContentButton();
      const tooltip = getBinding(button.element, 'gl-tooltip');

      expect(tooltip.modifiers.left).toBe(true);
      expect(button.attributes('title')).toBe('GitLab Duo Agent Platform');
    });

    it(`emits the ${BV_HIDE_TOOLTIP} event on the root when the mouse leaves the toggle button`, () => {
      const root = createWrapper(wrapper.vm.$root);

      expect(root.emitted(BV_HIDE_TOOLTIP)).toBeUndefined();

      findTogglePanelContentButton().vm.$emit('mouseout');

      expect(root.emitted(BV_HIDE_TOOLTIP)).toHaveLength(1);
    });

    it('adds a tooltip to the close button', () => {
      const button = findClosePanelContentButton();
      const tooltip = getBinding(button.element, 'gl-tooltip');

      expect(tooltip.modifiers.bottom).toBe(true);
      expect(button.attributes('title')).toBe('Collapse');
    });
  });

  describe('when the trial has expired', () => {
    it('renders the correct content', () => {
      createComponent({
        isTrialExpired: true,
        canBuyAddon: true,
        buyAddonPath: buyAddonPathMock,
      });

      expect(findEmptyStateText().text()).toBe(
        'Your trial has ended. Repurchase to resume using GitLab Duo Agent Platform.',
      );

      expect(findUpgradeButton().props('href')).toBe(buyAddonPathMock);
      expect(findLearnMoreButton().props('href')).toBe('/help/user/duo_agent_platform/_index.md');
    });

    it('tracks the `view_duo_agentic_trial_expired_empty_state` on mount', () => {
      createComponent({
        isTrialExpired: true,
        canBuyAddon: true,
        buyAddonPath: buyAddonPathMock,
      });
      const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

      expect(trackEventSpy).toHaveBeenCalledWith(
        DUO_PANEL_EMPTY_STATE_EVENTS.VIEW_TRIAL_EXPIRED,
        {},
        undefined,
      );
    });

    it('tracks `click_duo_agentic_trial_expired_upgrade` when upgrade button is clicked', () => {
      createComponent({
        isTrialExpired: true,
        canBuyAddon: true,
        buyAddonPath: buyAddonPathMock,
      });
      const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

      findUpgradeButton().vm.$emit('click');

      expect(trackEventSpy).toHaveBeenCalledWith(
        DUO_PANEL_EMPTY_STATE_EVENTS.CLICK_TRIAL_EXPIRED_UPGRADE,
        {},
        undefined,
      );
    });

    it('tracks `click_duo_agentic_trial_expired_learn_more` when learn more button is clicked', () => {
      createComponent({
        isTrialExpired: true,
        canBuyAddon: true,
        buyAddonPath: buyAddonPathMock,
      });
      const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

      findLearnMoreButton().vm.$emit('click');

      expect(trackEventSpy).toHaveBeenCalledWith(
        DUO_PANEL_EMPTY_STATE_EVENTS.CLICK_TRIAL_EXPIRED_LEARN_MORE,
        {},
        undefined,
      );
    });

    describe('upgrade button visibility', () => {
      it('shows upgrade button when canBuyAddon is true and buyAddonPath is present', () => {
        createComponent({
          isTrialExpired: true,
          canBuyAddon: true,
          buyAddonPath: buyAddonPathMock,
        });

        expect(findUpgradeButton().exists()).toBe(true);
      });

      it('hides upgrade button when canBuyAddon is false', () => {
        createComponent({
          isTrialExpired: true,
          canBuyAddon: false,
          buyAddonPath: buyAddonPathMock,
        });

        expect(findUpgradeButton().exists()).toBe(false);
      });

      it('hides upgrade button when buyAddonPath is empty', () => {
        createComponent({
          isTrialExpired: true,
          canBuyAddon: true,
          buyAddonPath: '',
        });

        expect(findUpgradeButton().exists()).toBe(false);
      });
    });
  });
});
