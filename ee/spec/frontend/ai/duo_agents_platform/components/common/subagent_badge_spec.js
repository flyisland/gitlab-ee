import { GlBadge } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubagentBadge from 'ee/ai/duo_agents_platform/components/common/subagent_badge.vue';

describe('SubagentBadge', () => {
  const createWrapper = (propsData = {}) =>
    shallowMount(SubagentBadge, {
      propsData: {
        componentName: 'developer',
        subsessionId: 'session-123',
        ...propsData,
      },
    });

  const findBadges = (wrapper) => wrapper.findAllComponents(GlBadge);

  it('renders component name, session id, and Subagent badge', () => {
    const wrapper = createWrapper();

    expect(wrapper.text()).toContain('Developer session session-123');

    const badges = findBadges(wrapper);
    expect(badges).toHaveLength(1);
    expect(badges.at(0).text()).toBe('Subagent');
    expect(badges.at(0).props('variant')).toBe('neutral');
  });

  it.each([
    ['running', 'info', 'Running'],
    ['finished', 'success', 'Finished'],
    ['failed', 'danger', 'Failed'],
    ['unknown_state', 'neutral', 'Unknown state'],
  ])('renders status badge for %s status', (status, expectedVariant, expectedText) => {
    const wrapper = createWrapper({ status });

    const badges = findBadges(wrapper);

    expect(badges).toHaveLength(2);
    expect(badges.at(1).props('variant')).toBe(expectedVariant);
    expect(badges.at(1).text()).toBe(expectedText);
  });

  it('does not render status badge when status is not provided', () => {
    const wrapper = createWrapper({ status: null });

    expect(findBadges(wrapper)).toHaveLength(1);
  });
});
