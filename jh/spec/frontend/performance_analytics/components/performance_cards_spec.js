import { shallowMount } from '@vue/test-utils';
import { GlCard } from '@gitlab/ui';
import Vuex from 'vuex';
import Vue, { nextTick } from 'vue';
import PerformanceCards from 'jh/analytics/performance_analytics/components/performance_cards.vue';
import {
  PERFORMANCE_TYPE_INDICATOR_TEXT,
  PERFORMANCE_TYPE_PUSH_TEXTS,
} from 'jh/analytics/performance_analytics/constants';
import mutations from 'jh/analytics/performance_analytics/store/mutations';
import * as types from 'jh/analytics/performance_analytics/store/mutation_types';
import createState from 'jh/analytics/performance_analytics/store/state';
import { currentGroup, mockIndicatorList } from '../mock';

Vue.use(Vuex);

const fakeStore = () =>
  new Vuex.Store({
    state: createState({
      groupId: currentGroup.groupId,
      fullPath: currentGroup.fullPath,
      isGroup: currentGroup.isGroup,
      projectId: null,
    }),
    mutations,
  });

function createComponent(state = {}) {
  const store = fakeStore(state);

  return shallowMount(PerformanceCards, {
    store,
    stubs: {
      GlCard,
    },
  });
}

describe('PerformanceCards', () => {
  let wrapper;

  const findGlCards = () => wrapper.findAllComponents(GlCard);
  const findCardsValue = () => wrapper.findAll('[data-testid="performance-card-value"]');
  const findCardHeader = (index) => findGlCards().at(index).find('.gl-card-header');

  beforeEach(() => {
    wrapper = createComponent();
  });

  describe('should render correctly', () => {
    it('have 4 performance cards', () => {
      expect(findGlCards()).toHaveLength(4);
    });

    it.each`
      performanceType             | index                         | isGroup  | pageName     | text
      ${mockIndicatorList[0].key} | ${mockIndicatorList[0].index} | ${false} | ${'project'} | ${PERFORMANCE_TYPE_INDICATOR_TEXT[mockIndicatorList[0].key]}
      ${mockIndicatorList[1].key} | ${mockIndicatorList[1].index} | ${false} | ${'project'} | ${PERFORMANCE_TYPE_INDICATOR_TEXT[mockIndicatorList[1].key]}
      ${mockIndicatorList[2].key} | ${mockIndicatorList[2].index} | ${false} | ${'project'} | ${PERFORMANCE_TYPE_INDICATOR_TEXT[mockIndicatorList[2].key]}
      ${mockIndicatorList[3].key} | ${mockIndicatorList[3].index} | ${false} | ${'group'}   | ${PERFORMANCE_TYPE_INDICATOR_TEXT[mockIndicatorList[3].key]}
      ${mockIndicatorList[1].key} | ${mockIndicatorList[1].index} | ${true}  | ${'project'} | ${PERFORMANCE_TYPE_PUSH_TEXTS[mockIndicatorList[1].key]}
      ${mockIndicatorList[3].key} | ${mockIndicatorList[3].index} | ${true}  | ${'group'}   | ${PERFORMANCE_TYPE_PUSH_TEXTS[mockIndicatorList[3].key]}
    `(
      `$performanceType card header should be $text in $pageName page`,
      async ({ text, index, isGroup }) => {
        wrapper.vm.$store.commit(types.SET_IS_GROUP, isGroup);
        await nextTick();
        expect(findCardHeader(index).text()).toBe(text);
      },
    );

    describe.each(mockIndicatorList)('default value', ({ key, index }) => {
      it(`${key} default value should be zero`, () => {
        expect(findCardsValue().at(index).text()).toBe('0');
      });
    });
  });
});
