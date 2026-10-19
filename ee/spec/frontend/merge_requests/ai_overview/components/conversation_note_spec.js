import { GlAvatar } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import ConversationNote from 'ee/merge_requests/ai_overview/components/conversation_note.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { author, makeNote } from '../mock_data';

describe('AI Overview conversation note', () => {
  let wrapper;

  const createComponent = ({ props = {}, slots = {} } = {}) => {
    wrapper = mountExtended(ConversationNote, {
      propsData: { note: makeNote(), role: { text: 'Author', variant: 'info' }, ...props },
      slots,
    });
  };

  const findAuthor = () => wrapper.findByTestId('conversation-author');
  const findAgentAvatar = () => wrapper.findByTestId('conversation-agent-avatar');

  describe('by default', () => {
    beforeEach(() => {
      createComponent({
        slots: { badges: '<span>Unresolved</span>', default: '<span>app/models/user.rb</span>' },
      });
    });

    it('links the author with a full-size avatar', () => {
      expect(findAuthor().text()).toBe('Priya Nair');
      expect(findAuthor().attributes('href')).toBe('/priya');
      expect(wrapper.findComponent(GlAvatar).props('size')).toBe(24);
      expect(findAgentAvatar().exists()).toBe(false);
    });

    it('shows the role, the extra badges, the time and the first line of the note', () => {
      expect(wrapper.findByTestId('conversation-role').text()).toBe('Author');
      expect(wrapper.text()).toContain('Unresolved');
      expect(wrapper.text()).toContain('app/models/user.rb');
      expect(wrapper.findComponent(TimeAgoTooltip).props('time')).toBe('2026-09-20T10:00:00Z');
      expect(wrapper.findByTestId('conversation-body').html()).toContain('<code>method</code>');
    });

    it('keeps the first line inline', () => {
      expect(wrapper.findByTestId('conversation-body').find('p p').exists()).toBe(false);
    });
  });

  it('uses a smaller avatar when compact', () => {
    createComponent({ props: { compact: true } });

    expect(wrapper.findComponent(GlAvatar).props('size')).toBe(16);
  });

  it('shows an agent as the agent tile instead of its avatar', () => {
    createComponent({ props: { note: makeNote({ author: { ...author, bot: true } }) } });

    expect(findAgentAvatar().exists()).toBe(true);
    expect(wrapper.findComponent(GlAvatar).exists()).toBe(false);
  });

  it('shows no role when there is none', () => {
    createComponent({ props: { role: null } });

    expect(wrapper.findByTestId('conversation-role').exists()).toBe(false);
  });
});
