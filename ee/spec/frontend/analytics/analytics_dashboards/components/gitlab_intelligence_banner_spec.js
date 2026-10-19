import { GlBadge } from '@gitlab/ui';
import GitLabIntelligenceBanner from 'ee/analytics/analytics_dashboards/components/gitlab_intelligence_banner.vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';

describe('GitLabIntelligenceBanner', () => {
  /** @type {import('helpers/vue_test_utils_helper').ExtendedWrapper} */
  let wrapper;

  const exploreDashboardsPath = '/explore/analytics_dashboards';

  const createWrapper = () => {
    wrapper = mountExtended(GitLabIntelligenceBanner, {
      propsData: {
        exploreDashboardsPath,
      },
    });
  };

  beforeEach(() => {
    createWrapper();
  });

  it('introduces GitLab Intelligence as new', () => {
    expect(wrapper.text()).toContain('Introducing GitLab Intelligence');
    expect(wrapper.findComponent(GlBadge).text()).toBe('New');
  });

  it('renders the headline and description', () => {
    expect(
      wrapper.findByRole('heading', { level: 2, name: 'See everything. Ask anything.' }).exists(),
    ).toBe(true);
    expect(wrapper.text()).toContain(
      'See activity across your entire organization in one place, and ask GitLab Duo to explain what the numbers mean — without building a dashboard first.',
    );
  });

  it('links the call to action to GitLab Intelligence', () => {
    expect(
      wrapper.findByRole('link', { name: 'Open GitLab Intelligence' }).attributes('href'),
    ).toBe(exploreDashboardsPath);
  });

  it('links to the analytics dashboards documentation', () => {
    expect(wrapper.findByRole('link', { name: 'Learn more' }).attributes('href')).toBe(
      '/help/user/analytics/analytics_dashboards',
    );
  });

  it.each(['Organization-wide view', 'Insights with GitLab Duo', 'Build your own dashboards'])(
    'renders the "%s" value proposition',
    (name) => {
      expect(wrapper.findByRole('heading', { level: 3, name }).exists()).toBe(true);
    },
  );
});
