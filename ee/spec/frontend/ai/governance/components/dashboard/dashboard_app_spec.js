import { GlCard } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import AiGovernanceDashboardApp from 'ee/ai/governance/components/dashboard/dashboard_app.vue';

describe('AiGovernanceDashboardApp', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = mountExtended(AiGovernanceDashboardApp);
  };

  const findCards = () => wrapper.findAllComponents(GlCard);
  const findSummaryMetric = (key) => wrapper.findByTestId(`summary-metric-${key}`);
  const findDashboardCard = (key) => wrapper.findByTestId(`dashboard-card-${key}`);

  beforeEach(() => {
    createComponent();
  });

  describe('summary header', () => {
    it.each(['agents', 'sessions', 'posture'])('renders the %s summary metric', (key) => {
      expect(findSummaryMetric(key).exists()).toBe(true);
    });
  });

  describe('card placeholders', () => {
    it('renders a card for each of the four beta areas', () => {
      expect(findCards()).toHaveLength(4);
    });

    it.each([
      ['ai-agents', 'AI agents'],
      ['ai-sessions', 'AI sessions'],
      ['audit-trail', 'Audit trail'],
      ['agent-inventory', 'AI agent inventory'],
    ])('renders the %s card with its title', (key, title) => {
      const card = findDashboardCard(key);

      expect(card.exists()).toBe(true);
      expect(card.text()).toContain(title);
    });
  });
});
