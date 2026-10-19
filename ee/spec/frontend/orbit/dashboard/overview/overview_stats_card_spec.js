import { GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import OverviewStatsCard from 'ee/orbit/dashboard/overview/overview_stats_card.vue';

const AREA_ITEMS = [
  { name: 'core', items: [{ name: 'Project', count: 2140 }] },
  { name: 'plan', items: [{ name: 'WorkItem', count: 4380 }] },
  { name: 'code_review', items: [{ name: 'MergeRequest', count: 3912 }] },
  { name: 'ci', items: [{ name: 'Pipeline', count: 5206 }] },
  { name: 'source_code', items: [{ name: 'File', count: 1894 }] },
  { name: 'security', items: [{ name: 'Vulnerability', count: 242 }] },
];

const buildStats = ({ indexedProjects = 3, total = 17774 } = {}) => ({
  getTotalIndexedNodes: () => total,
  getDomains: () => AREA_ITEMS,
  getDomainTotals: () =>
    Object.fromEntries(AREA_ITEMS.map(({ name, items }) => [name, items[0].count])),
  getProjects: () => ({ indexed: indexedProjects }),
});

const RouterLinkStub = { name: 'RouterLink', props: ['to'], template: '<a><slot /></a>' };

describe('OverviewStatsCard', () => {
  let wrapper;

  const createComponent = ({
    groupCount = 4,
    graphStats = buildStats(),
    status = 'ready',
  } = {}) => {
    wrapper = shallowMountExtended(OverviewStatsCard, {
      propsData: { groupCount, graphStats, status },
      stubs: { GlSprintf, RouterLink: RouterLinkStub },
    });
  };

  const findScope = () => wrapper.findByTestId('overview-stats-scope');
  const areaRowTexts = () =>
    wrapper.findAll('ul li').wrappers.map((row) => row.text().replace(/\s+/g, ' ').trim());

  describe('when the counts loaded', () => {
    beforeEach(() => createComponent());

    it('shows the title and the total', () => {
      expect(wrapper.text()).toContain('In your graph');
      expect(wrapper.text()).toContain('17,774');
      expect(wrapper.text()).toContain('items');
    });

    it('shows the areas with their counts in order', () => {
      expect(areaRowTexts()).toEqual([
        'Core 2,140',
        'Planning 4,380',
        'Code review 3,912',
        'CI/CD 5,206',
        'Source code 1,894',
        'Security 242',
      ]);
    });

    it('links to the schema', () => {
      expect(wrapper.text()).toContain('What is in each area? View schema');
      expect(wrapper.findComponent(RouterLinkStub).props('to')).toEqual({ name: 'schema' });
    });

    it('summarizes the groups and projects', () => {
      expect(findScope().text()).toBe('in 4 groups and 3 projects');
    });
  });

  describe('with one item', () => {
    beforeEach(() => createComponent({ graphStats: buildStats({ total: 1 }) }));

    it('uses the singular', () => {
      expect(wrapper.text()).toMatch(/1\s+item\b/);
      expect(wrapper.text()).not.toContain('items');
    });
  });

  describe('when one group and one project', () => {
    beforeEach(() =>
      createComponent({ groupCount: 1, graphStats: buildStats({ indexedProjects: 1 }) }),
    );

    it('uses singular forms', () => {
      expect(findScope().text()).toBe('in 1 group and 1 project');
    });
  });

  describe('when the counts are loading', () => {
    beforeEach(() => createComponent({ graphStats: null, status: 'loading' }));

    it('shows a loading icon and no counts', () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
      expect(wrapper.text()).not.toContain('items');
    });
  });

  describe('when the counts did not load', () => {
    beforeEach(() => createComponent({ graphStats: null, status: 'failed' }));

    it('says the counts are not available, with no zero and the schema link', () => {
      expect(wrapper.findByTestId('overview-stats-failed').text()).toBe(
        'Counts are not available right now. Try again later.',
      );
      expect(wrapper.text()).not.toMatch(/0\s+items/);
      expect(wrapper.text()).toContain('What is in each area? View schema');
    });
  });

  describe('when the counts are forbidden', () => {
    beforeEach(() => createComponent({ graphStats: null, status: 'forbidden' }));

    it('says the counts are not available for the groups', () => {
      expect(wrapper.findByTestId('overview-stats-failed').text()).toBe(
        'Counts are not available for your groups.',
      );
    });
  });
});
