import GitLabIntelligenceBanner from './gitlab_intelligence_banner.vue';

export default {
  component: GitLabIntelligenceBanner,
  title: 'ee/analytics/analytics_dashboards/components/gitlab_intelligence_banner',
};

const Template = (args) => ({
  components: { GitLabIntelligenceBanner },
  provide: {},
  data() {
    return { ...args };
  },
  template: `<git-lab-intelligence-banner :explore-dashboards-path="exploreDashboardsPath" />`,
});

export const Default = {
  render: Template,
  args: {
    exploreDashboardsPath: '/explore/analytics_dashboards',
  },
};
