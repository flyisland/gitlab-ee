import { GlLink } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import { useMockLocationHelper } from 'helpers/mock_window_location_helper';
import OrbitExploreEmptyState from 'ee/orbit/components/orbit_explore_empty_state.vue';
import TurnOnIndexingModal from 'ee/orbit/components/turn_on_indexing_modal.vue';

describe('OrbitExploreEmptyState tracking', () => {
  let wrapper;

  const { bindInternalEventDocument } = useMockInternalEventsTracking();
  useMockLocationHelper();

  const ownerGroup = {
    name: 'Owner Group',
    fullPath: 'owner-group',
    avatarUrl: null,
    knowledgeGraphAvailable: true,
    knowledgeGraphEnabled: false,
    maxAccessLevel: { integerValue: 50 },
    userPermissions: { startOrbitTrial: false },
  };

  const nonOwnerGroup = {
    name: 'Member Group',
    fullPath: 'member-group',
    avatarUrl: null,
    knowledgeGraphAvailable: true,
    knowledgeGraphEnabled: false,
    maxAccessLevel: { integerValue: 30 },
    userPermissions: { startOrbitTrial: false },
  };

  const findGetStartedButton = () => wrapper.find('[data-testid="orbit-get-started-btn"]');
  const findTurnOnModal = () => wrapper.findComponent(TurnOnIndexingModal);

  const createComponent = (availableGroups) =>
    mount(OrbitExploreEmptyState, {
      propsData: { availableGroups },
      stubs: {
        TurnOnIndexingModal: true,
        OrbitEmptyState: { template: '<div><slot /></div>' },
        GlAvatar: true,
        GlModal: true,
      },
    });

  it('tracks click_orbit_get_started_empty_state when the Get started button is clicked', async () => {
    wrapper = createComponent([ownerGroup]);
    const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

    await wrapper.find('[data-testid="orbit-get-started-btn"]').trigger('click');

    expect(trackEventSpy).toHaveBeenCalledWith(
      'click_orbit_get_started_empty_state',
      {},
      undefined,
    );
  });

  it('tracks click_orbit_setup_guide_empty_state when the Setup guide button is clicked', async () => {
    wrapper = createComponent([nonOwnerGroup]);
    const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

    await wrapper.find('[data-testid="orbit-setup-guide-btn"]').trigger('click');

    expect(trackEventSpy).toHaveBeenCalledWith(
      'click_orbit_setup_guide_empty_state',
      {},
      undefined,
    );
  });

  it('exposes data-event-tracking on the View Owners link', () => {
    wrapper = createComponent([nonOwnerGroup]);

    const ownersLink = wrapper
      .findAllComponents(GlLink)
      .wrappers.find((link) => link.text() === 'View Owners');

    expect(ownersLink.attributes('data-event-tracking')).toBe(
      'click_orbit_view_owners_empty_state',
    );
  });

  it('does not render the Get started button for non-owner groups', () => {
    wrapper = createComponent([nonOwnerGroup]);

    expect(wrapper.find('[data-testid="orbit-get-started-btn"]').exists()).toBe(false);
  });

  it('does not render the Setup guide button for owner groups', () => {
    wrapper = createComponent([ownerGroup]);

    expect(wrapper.find('[data-testid="orbit-setup-guide-btn"]').exists()).toBe(false);
  });

  it('shows the no-eligible-groups message when no groups are available', () => {
    wrapper = createComponent([]);

    const message = wrapper.find('[data-testid="orbit-no-available-groups"]');
    expect(message.exists()).toBe(true);
    expect(message.text()).toBe('No eligible groups are available for GitLab Orbit.');
  });

  describe('when the group needs a trial', () => {
    beforeEach(() => {
      wrapper = createComponent([{ ...ownerGroup, userPermissions: { startOrbitTrial: true } }]);
    });

    it('stays on the page before Get started is clicked', () => {
      expect(window.location.assign).not.toHaveBeenCalled();
    });

    describe('and Get started is clicked', () => {
      beforeEach(async () => {
        await findGetStartedButton().trigger('click');
      });

      it('opens its Settings > Orbit page', () => {
        expect(window.location.assign).toHaveBeenCalledWith('/groups/owner-group/-/settings/orbit');
      });

      it('does not open the turn on modal', () => {
        expect(findTurnOnModal().props('group')).toBe(null);
      });
    });
  });

  describe('when the group does not need a trial', () => {
    beforeEach(() => {
      wrapper = createComponent([ownerGroup]);
    });

    it('has no group in the turn on modal before Get started is clicked', () => {
      expect(findTurnOnModal().props('group')).toBe(null);
    });

    describe('and Get started is clicked', () => {
      beforeEach(async () => {
        await findGetStartedButton().trigger('click');
      });

      it('opens the turn on modal for the group', () => {
        expect(findTurnOnModal().props('group')).toEqual(ownerGroup);
      });

      it('stays on the page', () => {
        expect(window.location.assign).not.toHaveBeenCalled();
      });
    });
  });

  it('does not show the no-eligible-groups message when groups are available', () => {
    wrapper = createComponent([ownerGroup]);

    expect(wrapper.find('[data-testid="orbit-no-available-groups"]').exists()).toBe(false);
  });
});
