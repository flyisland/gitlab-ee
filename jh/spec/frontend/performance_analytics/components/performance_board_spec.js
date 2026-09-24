import { shallowMount } from '@vue/test-utils';
import PerformanceBoard from 'jh/analytics/performance_analytics/components/performance_board.vue';
import PerformanceCards from 'jh/analytics/performance_analytics/components/performance_cards.vue';
import RankList from 'jh/analytics/performance_analytics/components/rank_list.vue';

function createComponent() {
  return shallowMount(PerformanceBoard);
}

describe('PerformanceBoard', () => {
  let wrapper;

  const findPerformanceCards = () => wrapper.findComponent(PerformanceCards);
  const findRankList = () => wrapper.findComponent(RankList);

  beforeEach(() => {
    wrapper = createComponent();
  });

  it('will render performance cards', () => {
    expect(findPerformanceCards().exists()).toBe(true);
  });

  it('will render rank list', () => {
    expect(findRankList().exists()).toBe(true);
  });
});
