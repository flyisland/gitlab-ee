import { shallowMount } from '@vue/test-utils';
import { GlAvatarLink, GlAvatarLabeled } from '@gitlab/ui';
import MemberItem from 'jh/analytics/performance_analytics/components/member_item.vue';
import { mockRankList } from '../mock';

jest.mock('jh_images/leaderboard/medal_gold.svg', () => ({
  __esModule: true,
  default: '<svg></svg>',
}));
function createComponent(state = {}) {
  return shallowMount(MemberItem, {
    stubs: {
      GlAvatarLink,
    },
    propsData: {
      member: mockRankList[0],
      ranking: 0,
      ...state,
    },
  });
}

describe('MemberItem', () => {
  let wrapper;

  const findGlAvatarLink = () => wrapper.findComponent(GlAvatarLink);
  const findGlAvatarLabeled = () => wrapper.findComponent(GlAvatarLabeled);
  const findMedalIcon = () => wrapper.find('[data-testid="member-ranking-icon"]');
  const findRankingText = () => wrapper.find('[data-testid="member-ranking-text"]');

  const defaultAvatarSize = 32;

  beforeEach(() => {
    wrapper = createComponent();
  });

  describe('renders', () => {
    const userInfo = mockRankList[0].user;

    it('with avatar link component', () => {
      expect(findGlAvatarLink().exists()).toBe(true);
    });

    it('avatar link with correct props', () => {
      expect(findGlAvatarLink().attributes()).toMatchObject({
        href: userInfo.user_web_url,
        'data-username': userInfo.username,
      });
    });

    describe('medal icon', () => {
      it('should be render if top three member', () => {
        expect(findMedalIcon().html()).toContain('<svg></svg>');
      });
    });

    describe('ranking text', () => {
      beforeEach(() => {
        wrapper = createComponent({ ranking: 3 });
      });

      it('should render if not top three member', () => {
        expect(findRankingText().text()).toBe('4');
      });
    });

    it('with avatar label component', () => {
      expect(findGlAvatarLabeled().exists()).toBe(true);
    });

    it('avatar label with correct props', () => {
      const avatarLabeled = findGlAvatarLabeled();

      expect(avatarLabeled.attributes()).toMatchObject({
        size: `${defaultAvatarSize}`,
        src: userInfo.avatar,
        alt: userInfo.fullname,
      });
      expect(avatarLabeled.props()).toMatchObject({
        label: userInfo.fullname,
        subLabel: `@${userInfo.username}`,
      });
    });
  });
});
