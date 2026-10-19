import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import ViewSessionButton from 'ee/ai/shared/widgets/view_session_button.vue';
import SeverityMeter from 'ee/vue_shared/components/severity_meter/severity_meter.vue';
import RiskPanel from 'ee/merge_requests/ai_overview/components/risk_panel.vue';
import riskAssessmentQuery from 'ee/vue_merge_request_widget/widgets/risk_assessment/graphql/risk_assessment.query.graphql';
import { makeRiskAssessment, riskAssessmentResponse } from '../mock_data';

Vue.use(VueApollo);

describe('AI Overview risk panel', () => {
  let wrapper;
  let queryHandler;

  const createComponent = ({
    handler = jest.fn().mockResolvedValue(riskAssessmentResponse()),
  } = {}) => {
    queryHandler = handler;

    wrapper = mountExtended(RiskPanel, {
      apolloProvider: createMockApollo([[riskAssessmentQuery, queryHandler]]),
      provide: { projectPath: 'group/proj', iid: '1' },
      // It runs its own Duo Chat availability query, which is not what is under test here.
      stubs: { ViewSessionButton: true },
    });
  };

  const createWithAssessment = async (overrides) => {
    createComponent({
      handler: jest.fn().mockResolvedValue(riskAssessmentResponse(makeRiskAssessment(overrides))),
    });
    await waitForPromises();
  };

  const findPanel = () => wrapper.findByTestId('risk-panel');
  const findTitle = () => wrapper.findByTestId('risk-title');
  const findMeter = () => wrapper.findComponent(SeverityMeter);
  const findUpdating = () => wrapper.findByTestId('risk-updating');
  const findRationale = () => wrapper.findByTestId('risk-rationale');
  const findBreakdown = () => wrapper.findByTestId('risk-signal-breakdown');
  const findStaleWarning = () => wrapper.findByTestId('risk-stale-warning');
  const findLowConfidence = () => wrapper.findByTestId('risk-low-confidence');
  const findToggle = () => wrapper.findByTestId('risk-details-toggle');

  it('asks for the assessment of this merge request', async () => {
    createComponent();
    await waitForPromises();

    expect(queryHandler).toHaveBeenCalledWith({ projectPath: 'group/proj', iid: '1' });
  });

  it('renders nothing while the assessment loads', () => {
    createComponent();

    expect(findPanel().exists()).toBe(false);
  });

  // The field is null when the flow is not available to the project, or has not run yet.
  it('renders nothing when there is no assessment', async () => {
    createComponent({ handler: jest.fn().mockResolvedValue(riskAssessmentResponse(null)) });
    await waitForPromises();

    expect(findPanel().exists()).toBe(false);
  });

  describe('with a completed assessment', () => {
    beforeEach(async () => {
      await createWithAssessment();
    });

    it('shows the risk and confidence tiers in the headline', () => {
      expect(findTitle().text()).toBe('Risk assessment: High with medium confidence');
      expect(findTitle().find('strong').text()).toBe('Risk assessment:');
      expect(findUpdating().exists()).toBe(false);
    });

    it('fills the meter to the risk tier', () => {
      expect(findMeter().props()).toMatchObject({
        severity: 'HIGH',
        label: 'Risk level: High risk',
      });
    });

    it('explains the score', () => {
      expect(findRationale().text()).toBe('Changes the merge path without new tests.');
      expect(findBreakdown().findAll('li')).toHaveLength(1);
      expect(findBreakdown().text()).toContain('Size of change');
      expect(findBreakdown().text()).toContain('640 lines changed');
      expect(findLowConfidence().exists()).toBe(false);
    });

    it('does not warn about staleness', () => {
      expect(findStaleWarning().exists()).toBe(false);
    });

    it('offers no session link without a session', () => {
      expect(wrapper.findComponent(ViewSessionButton).exists()).toBe(false);
    });

    describe('details', () => {
      const findDetails = () => findRationale().element.parentElement;

      it('are collapsed by default, leaving the headline and meter on show', () => {
        expect(findDetails().style.display).toBe('none');
        expect(findMeter().props('severity')).toBe('HIGH');
        expect(findToggle().attributes()).toMatchObject({
          'aria-label': 'Show details',
          'aria-expanded': 'false',
          'aria-controls': findDetails().id,
        });
      });

      it('expand and collapse from the toggle', async () => {
        await findToggle().trigger('click');

        expect(findDetails().style.display).toBe('');
        expect(findToggle().attributes()).toMatchObject({
          'aria-label': 'Hide details',
          'aria-expanded': 'true',
        });

        await findToggle().trigger('click');

        expect(findDetails().style.display).toBe('none');
      });
    });
  });

  it('warns when the assessment predates the latest changes', async () => {
    await createWithAssessment({ stale: true });

    expect(findStaleWarning().exists()).toBe(true);
  });

  it('names the signals it could not measure when confidence is low', async () => {
    await createWithAssessment({
      confidenceTier: 'LOW',
      missingSignals: [
        { __typename: 'MergeRequestRiskMissingSignal', signal: 'test_coverage', label: 'Tests' },
        { __typename: 'MergeRequestRiskMissingSignal', signal: 'some_claim', label: null },
      ],
    });

    expect(findTitle().text()).toBe('Risk assessment: High with low confidence');
    expect(findLowConfidence().text()).toBe(
      'Based on a partial picture: Tests could not be measured.',
    );
  });

  // The backend scores tier and confidence independently, so confidence can come back empty.
  it('still names the tier when confidence did not resolve', async () => {
    await createWithAssessment({ confidenceTier: null });

    expect(findTitle().text()).toBe('Risk assessment: High');
  });

  it('links to the Duo session that produced it', async () => {
    await createWithAssessment({ duoWorkflowId: 42 });

    expect(wrapper.findComponent(ViewSessionButton).props('sessionId')).toBe(42);
  });

  it.each(['QUEUED', 'SCORING'])(
    'keeps the previous result while a refresh is %s',
    async (status) => {
      await createWithAssessment({ status });

      expect(findTitle().text()).toBe('Risk assessment: High with medium confidence');
      expect(findUpdating().text()).toBe('Updating…');
      expect(findMeter().props('severity')).toBe('HIGH');
    },
  );

  it.each`
    status       | title
    ${'PENDING'} | ${'Risk assessment: Pending'}
    ${'QUEUED'}  | ${'Risk assessment: Queued'}
    ${'SCORING'} | ${'Risk assessment: Queued'}
    ${'FAILED'}  | ${'Risk assessment: Unavailable'}
  `('says "$title" with no result to show when $status', async ({ status, title }) => {
    await createWithAssessment({ status, riskTier: null, confidenceTier: null });

    expect(findTitle().text()).toBe(title);
    expect(findMeter().props()).toMatchObject({
      severity: null,
      label: 'Risk level not available',
    });
    expect(findBreakdown().exists()).toBe(false);
    expect(findToggle().exists()).toBe(false);
  });

  it('does not trust the last result of a failed run', async () => {
    await createWithAssessment({ status: 'FAILED' });

    expect(findTitle().text()).toBe('Risk assessment: Unavailable');
    expect(findMeter().props('severity')).toBe(null);
    expect(findRationale().exists()).toBe(false);
  });

  it('says so when the assessment cannot be loaded', async () => {
    createComponent({ handler: jest.fn().mockRejectedValue(new Error('nope')) });
    await waitForPromises();

    expect(findTitle().text()).toBe('Risk assessment: Not available');
    expect(findPanel().text()).toContain('Failed to load the risk assessment');
    expect(findMeter().props('severity')).toBe(null);
    expect(findToggle().exists()).toBe(false);
  });
});
