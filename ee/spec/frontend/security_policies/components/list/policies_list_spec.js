import { shallowMount } from '@vue/test-utils';
import { GlButton, GlCollapsibleListbox, GlEmptyState } from '@gitlab/ui';
import PoliciesList from 'ee/security_policies/components/list/policies_list.vue';
import SummaryTile from 'ee/security_policies/components/list/summary_tile.vue';
import StatsBar from 'ee/security_policies/components/list/stats_bar.vue';
import { SUMMARY_TILES } from 'ee/security_policies/constants';

describe('PoliciesList', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(PoliciesList);
  };

  const findSummaryTiles = () => wrapper.findAllComponents(SummaryTile);
  const findStatsBar = () => wrapper.findComponent(StatsBar);
  const findListboxes = () => wrapper.findAllComponents(GlCollapsibleListbox);
  const findNewPolicyButton = () =>
    wrapper.findAllComponents(GlButton).wrappers.find((w) => w.text() === 'New Policy');

  it('renders "Policies" heading', () => {
    createComponent();

    expect(wrapper.find('h1').text()).toBe('Policies');
  });

  it('renders all 6 summary tiles', () => {
    createComponent();

    expect(findSummaryTiles()).toHaveLength(SUMMARY_TILES.length);
    expect(SUMMARY_TILES).toHaveLength(6);
  });

  it('renders the stats bar', () => {
    createComponent();

    expect(findStatsBar().exists()).toBe(true);
  });

  it('renders the filter dropdowns', () => {
    createComponent();

    expect(findListboxes()).toHaveLength(3);
  });

  it('emits create when New Policy button is clicked', () => {
    createComponent();

    findNewPolicyButton().vm.$emit('click');

    expect(wrapper.emitted('create')).toBeDefined();
  });

  it('shows empty state when policies array is empty', () => {
    createComponent();

    expect(wrapper.findComponent(GlEmptyState).exists()).toBe(true);
  });
});
