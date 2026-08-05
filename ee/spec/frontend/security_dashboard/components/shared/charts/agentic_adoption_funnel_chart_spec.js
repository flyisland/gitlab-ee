import { GlChart } from '@gitlab/ui/src/charts';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgenticAdoptionFunnelChart from 'ee/security_dashboard/components/shared/charts/agentic_adoption_funnel_chart.vue';
import AgenticAdoptionFunnelStage from 'ee/security_dashboard/components/shared/charts/agentic_adoption_funnel_stage.vue';
import AgenticAdoptionFunnelEmptyState from 'ee/security_dashboard/components/shared/charts/agentic_adoption_funnel_empty_state.vue';

describe('AgenticAdoptionFunnelChart', () => {
  let wrapper;

  // Scenario 1: False Positive Detection and Vulnerability Resolution enabled
  const defaultData = {
    detectedVulnerabilities: { status: 'AVAILABLE', count: 1240 },
    truePositives: { status: 'AVAILABLE', count: 870 },
    createdMergeRequests: { status: 'AVAILABLE', count: 312 },
    mergedMergeRequests: { status: 'AVAILABLE', count: 100 },
  };

  // Scenario 2: Vulnerability Resolution is disabled, so no created/merged MRs.
  const vulnerabilityResolutionDisabled = {
    createdMergeRequests: { status: 'UNAVAILABLE_DISABLED', count: null },
    mergedMergeRequests: { status: 'UNAVAILABLE_DISABLED', count: null },
  };

  // Scenario 3: False Positive Detection is disabled. The merge request stages are
  // themselves available, but since this is a funnel their counts can't be derived
  // while the upstream stage is off, so they arrive as `null`.
  const falsePositiveDisabledMergeRequestsPending = {
    truePositives: { status: 'UNAVAILABLE_DISABLED', count: null },
    createdMergeRequests: { status: 'AVAILABLE', count: null },
    mergedMergeRequests: { status: 'AVAILABLE', count: null },
  };

  // Scenario 4: Both False Positive Detection and Vulnerability Resolution are disabled.
  const falsePositiveAndVulnerabilityResolutionDisabled = {
    truePositives: { status: 'UNAVAILABLE_DISABLED', count: null },
    createdMergeRequests: { status: 'UNAVAILABLE_DISABLED', count: null },
    mergedMergeRequests: { status: 'UNAVAILABLE_DISABLED', count: null },
  };

  const manageDuoSettingsPath = '/groups/gitlab-org/-/edit#js-gitlab-duo-settings';

  const createComponent = ({ data = {}, provide = {} } = {}) => {
    wrapper = shallowMountExtended(AgenticAdoptionFunnelChart, {
      propsData: {
        ...defaultData,
        ...data,
      },
      provide: {
        manageDuoSettingsPath,
        ...provide,
      },
    });
  };

  const findChart = () => wrapper.findComponent(GlChart);
  const findStages = () => wrapper.findAllComponents(AgenticAdoptionFunnelStage);
  const findEmptyStates = () => wrapper.findAllComponents(AgenticAdoptionFunnelEmptyState);
  const findChartArea = () => wrapper.findByTestId('funnel-chart-area');
  const findStageHeaderRow = () => wrapper.findByTestId('funnel-stage-header-row');
  const findEmptyStatesContainer = () => wrapper.findByTestId('funnel-empty-states');
  const findChartOptions = () => findChart().props('options');
  // Empty states are distinguished by their icon: 'false-positive' (FP Detection)
  // and 'merge-request' (Vulnerability Resolution). Returning them in render order
  // asserts both which states are shown and their count.
  const findEmptyStateIcons = () => findEmptyStates().wrappers.map((w) => w.props('icon'));

  beforeEach(() => {
    createComponent();
  });

  describe('stages', () => {
    it('renders a column for each funnel stage', () => {
      expect(findStages()).toHaveLength(4);
    });

    // Keep in sync with the top spacer in agentic_adoption_funnel_curve.vue
    // (asserted in its spec) so the empty-state curve stays aligned with these columns.
    it('sizes the stage-header row to a fixed height', () => {
      expect(findStageHeaderRow().classes()).toContain('gl-basis-13');
    });

    it.each`
      index | count   | title                                     | description
      ${0}  | ${1240} | ${'Critical & High SAST vulnerabilities'} | ${''}
      ${1}  | ${870}  | ${'True positive'}                        | ${'False Positive Detection'}
      ${2}  | ${312}  | ${'Vulnerabilities with AI-created MRs'}  | ${'Vulnerability Resolution'}
      ${3}  | ${100}  | ${'Vulnerabilities fixed'}                | ${'From AI-created MRs'}
    `(
      'renders the count, title and description for stage $index',
      ({ index, count, title, description }) => {
        const stage = findStages().at(index);

        expect(stage.props('count')).toBe(count);
        expect(stage.props('title')).toBe(title);
        expect(stage.props('description')).toBe(description);
      },
    );
  });

  describe('layout widths', () => {
    it.each([
      {
        scenario: 'all stages are shown',
        data: {},
        chartWidth: 'gl-w-full',
        emptyStatesWidth: null,
      },
      {
        scenario: 'the Vulnerability Resolution empty state is shown',
        data: vulnerabilityResolutionDisabled,
        chartWidth: 'gl-w-2/3',
        emptyStatesWidth: 'gl-w-1/3',
      },
      {
        scenario:
          'the False Positive Detection empty state is shown and merge requests are not calculable',
        data: falsePositiveDisabledMergeRequestsPending,
        chartWidth: 'gl-w-1/2',
        emptyStatesWidth: 'gl-w-1/2',
      },
      {
        scenario: 'both empty states are shown',
        data: falsePositiveAndVulnerabilityResolutionDisabled,
        chartWidth: 'gl-w-1/3',
        emptyStatesWidth: 'gl-w-2/3',
      },
    ])(
      'sizes the chart and empty states when $scenario',
      ({ data, chartWidth, emptyStatesWidth }) => {
        createComponent({ data });

        expect(findChartArea().classes()).toContain(chartWidth);

        if (emptyStatesWidth) {
          expect(findEmptyStatesContainer().classes()).toContain(emptyStatesWidth);
        } else {
          expect(findEmptyStatesContainer().exists()).toBe(false);
        }
      },
    );
  });

  describe('empty states', () => {
    it.each([
      { scenario: 'all stages are shown', data: {}, expectedIcons: [] },
      {
        scenario: 'only the Vulnerability Resolution stage is disabled',
        data: vulnerabilityResolutionDisabled,
        expectedIcons: ['merge-request'],
      },
      {
        scenario: 'False Positive Detection is disabled but merge requests are not calculable',
        data: falsePositiveDisabledMergeRequestsPending,
        expectedIcons: ['false-positive'],
      },
      {
        scenario: 'both False Positive Detection and Vulnerability Resolution are disabled',
        data: falsePositiveAndVulnerabilityResolutionDisabled,
        expectedIcons: ['false-positive', 'merge-request'],
      },
    ])('renders the expected empty states when $scenario', ({ data, expectedIcons }) => {
      createComponent({ data });

      expect(findEmptyStateIcons()).toEqual(expectedIcons);
    });

    it('renders the False Positive Detection empty state as enableable', () => {
      createComponent({
        data: {
          truePositives: { status: 'UNAVAILABLE_DISABLED' },
          createdMergeRequests: { status: 'UNAVAILABLE_DISABLED' },
        },
      });

      expect(findEmptyStates().at(0).props('canEnable')).toBe(true);
    });

    it('renders the Vulnerability Resolution empty state as enableable', () => {
      createComponent({ data: { createdMergeRequests: { status: 'UNAVAILABLE_DISABLED' } } });

      expect(findEmptyStates().at(0).props('canEnable')).toBe(true);
    });

    it('renders the empty state as not enableable when the feature is unavailable due to licensing', () => {
      createComponent({ data: { createdMergeRequests: { status: 'UNAVAILABLE_NO_LICENSE' } } });

      expect(findEmptyStates().at(0).props('canEnable')).toBe(false);
    });
  });

  describe('empty state curve ratios', () => {
    it('continues the curve from where the chart ends when true positives are available', () => {
      // Last chart value 870 over 1240 detected vulnerabilities.
      createComponent({ data: { createdMergeRequests: { status: 'UNAVAILABLE_DISABLED' } } });

      const emptyState = findEmptyStates().at(0);

      expect(emptyState.props('startRatio')).toBe(870 / 1240);
      expect(emptyState.props('endRatio')).toBe(null);
    });

    it('drops the false positive curve and chains the resolution curve when only detected is available', () => {
      createComponent({
        data: {
          truePositives: { status: 'UNAVAILABLE_DISABLED' },
          createdMergeRequests: { status: 'UNAVAILABLE_DISABLED' },
        },
      });

      // Last chart value equals detected count, so chartEndRatio is 1.
      const falsePositiveState = findEmptyStates().at(0);
      expect(falsePositiveState.props('startRatio')).toBe(1);
      expect(falsePositiveState.props('endRatio')).toBe(0.4);

      // The resolution curve starts where the false positive curve dropped to.
      const resolutionState = findEmptyStates().at(1);
      expect(resolutionState.props('startRatio')).toBe(0.4);
      expect(resolutionState.props('endRatio')).toBe(null);
    });

    it('uses a zero ratio when there are no detected vulnerabilities (avoids divide-by-zero)', () => {
      createComponent({
        data: {
          detectedVulnerabilities: { status: 'AVAILABLE', count: 0 },
          truePositives: { status: 'UNAVAILABLE_DISABLED', count: 0 },
          createdMergeRequests: { status: 'UNAVAILABLE_DISABLED', count: 0 },
        },
      });

      const falsePositiveState = findEmptyStates().at(0);
      expect(falsePositiveState.props('startRatio')).toBe(0);
      expect(falsePositiveState.props('endRatio')).toBe(0);

      const resolutionState = findEmptyStates().at(1);
      expect(resolutionState.props('startRatio')).toBe(0);
      expect(resolutionState.props('endRatio')).toBe(null);
    });
  });

  describe('chart data', () => {
    it('passes a point per stage plus a duplicated final point so the last stage lands flat', () => {
      const { data } = findChartOptions().series[0];

      expect(data).toEqual([
        ['detected_vulnerabilities', 1240],
        ['true_positives', 870],
        ['created_merge_requests', 312],
        ['merged_merge_requests', 100],
        ['merged_merge_requests_2', 100],
      ]);
    });

    it('omits merge request points and duplicates true positives when merge requests are unavailable', () => {
      createComponent({ data: { createdMergeRequests: { status: 'UNAVAILABLE_DISABLED' } } });

      expect(findChartOptions().series[0].data).toEqual([
        ['detected_vulnerabilities', 1240],
        ['true_positives', 870],
        ['true_positives_2', 870],
      ]);
    });

    it('only plots detected vulnerabilities when no other stage is available', () => {
      createComponent({
        data: {
          truePositives: { status: 'UNAVAILABLE_DISABLED' },
          createdMergeRequests: { status: 'UNAVAILABLE_DISABLED' },
        },
      });

      expect(findChartOptions().series[0].data).toEqual([
        ['detected_vulnerabilities', 1240],
        ['detected_vulnerabilities_2', 1240],
      ]);
    });

    it('omits merge request points when feature is available but not calculable because FP is disabled', () => {
      createComponent({ data: falsePositiveDisabledMergeRequestsPending });

      expect(findChartOptions().series[0].data).toEqual([
        ['detected_vulnerabilities', 1240],
        ['detected_vulnerabilities_2', 1240],
      ]);
    });
  });
});
