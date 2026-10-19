import { shallowMount } from '@vue/test-utils';
import VirtualList from 'vue-virtual-scroll-list';
import { GlCard, GlCollapsibleListbox } from '@gitlab/ui';
import Vue, { nextTick } from 'vue';
import Vuex from 'vuex';
import RankList from 'jh/analytics/performance_analytics/components/rank_list.vue';
import MemberItem from 'jh/analytics/performance_analytics/components/member_item.vue';
import {
  RANK_DROPDOWN_OPTIONS,
  PERFORMANCE_TYPE_PUSH_TEXTS,
} from 'jh/analytics/performance_analytics/constants';
import createState from 'jh/analytics/performance_analytics/store/state';
import mutations from 'jh/analytics/performance_analytics/store/mutations';
import {
  currentGroup,
  rankDropdownDefaultValue,
  groupRankDropdownDefaultValue,
  mockRankList,
} from '../mock';

Vue.use(Vuex);

let wrapper;

const fakeStore = (state) =>
  new Vuex.Store({
    state: createState({
      groupId: currentGroup.groupId,
      fullPath: currentGroup.fullPath,
      isGroup: currentGroup.isGroup,
      projectId: null,
      ...state,
    }),
    mutations,
  });

function createComponent(state = {}) {
  const store = fakeStore(state);

  wrapper = shallowMount(RankList, {
    store,
    stubs: {
      GlCard,
    },
  });
}

describe('RankList', () => {
  const findMemberItems = () => wrapper.findAllComponents(MemberItem);
  const findVirtualList = () => wrapper.findComponent(VirtualList);
  const findGlCard = () => wrapper.findComponent(GlCard);
  const findGlCollapsibleListbox = () => wrapper.findComponent(GlCollapsibleListbox);

  describe('renders', () => {
    beforeEach(() => {
      createComponent();
    });
    it('should have GlCard', () => {
      expect(findGlCard().exists()).toBe(true);
    });

    it('should have GlCollapsibleListbox', () => {
      expect(findGlCollapsibleListbox().exists()).toBe(true);
    });
  });

  describe('Dropdown text', () => {
    it('has correct texts for dropdown items', async () => {
      createComponent({
        isGroup: false,
      });

      await nextTick();
      const dropdownOptions = findGlCollapsibleListbox().props('items');

      dropdownOptions.forEach((option, index) => {
        expect(option.text).toBe(RANK_DROPDOWN_OPTIONS[index].text);
      });
    });

    it('has correct texts for dropdown items in group page', () => {
      createComponent();
      const dropdownOptions = findGlCollapsibleListbox().props('items');

      dropdownOptions.forEach((option, index) => {
        const optionKey = RANK_DROPDOWN_OPTIONS[index].key;
        const text = PERFORMANCE_TYPE_PUSH_TEXTS[optionKey] || RANK_DROPDOWN_OPTIONS[index].text;

        expect(option.text).toBe(text);
      });
    });
  });

  describe('Select commits number', () => {
    it('default select commits number in project page', async () => {
      createComponent({
        isGroup: false,
      });
      await nextTick();

      expect(findGlCollapsibleListbox().props('selected')).toBe(rankDropdownDefaultValue);
    });

    it('default select commits number in group page', async () => {
      createComponent();
      await nextTick();

      expect(findGlCollapsibleListbox().props('selected')).toBe(groupRankDropdownDefaultValue);
    });
  });

  describe('should have member list', () => {
    beforeEach(() => {
      createComponent({
        rankList: mockRankList,
      });
    });

    it('renders virtual list', () => {
      const virtualList = findVirtualList();
      expect(virtualList.exists()).toBe(true);
      expect(virtualList.attributes()).toMatchObject(
        expect.objectContaining({
          remain: '5',
          size: '64',
        }),
      );
    });

    it('with correct member list', () => {
      expect(findMemberItems()).toHaveLength(mockRankList.length);
    });
  });
});
