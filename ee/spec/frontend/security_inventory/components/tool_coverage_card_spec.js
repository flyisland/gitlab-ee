import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlCard, GlCollapsibleListbox, GlPopover, GlSkeletonLoader } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { stubComponent } from 'helpers/stub_component';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import ToolCoverageCard from 'ee/security_inventory/components/tool_coverage_card.vue';
import ToolCoverageChart from 'ee/security_inventory/components/tool_coverage_chart.vue';
import GroupToolCoverageQuery from 'ee/security_inventory/graphql/group_tool_coverage.query.graphql';
import { groupToolCoverageResponse } from '../mock_data';

Vue.use(VueApollo);

describe('ToolCoverageCard', () => {
  let wrapper;

  const fullPath = 'gitlab-org';

  const findCard = () => wrapper.findComponent(GlCard);
  const findChart = () => wrapper.findComponent(ToolCoverageChart);
  const findListbox = () => wrapper.findComponent(GlCollapsibleListbox);
  const findSkeletonLoader = () => wrapper.findComponent(GlSkeletonLoader);
  const findConfigurationLink = () => wrapper.findByTestId('view-configuration-link');
  const findLearnMoreLink = () => wrapper.findByTestId('learn-more-link');
  const findPopover = () => wrapper.findComponent(GlPopover);

  // The item is the whole row; the row is the toggle button inside it.
  const findLegendItem = (status) => wrapper.findByTestId(`legend-item-${status}`);
  const findLegendRow = (status) => wrapper.findByTestId(`legend-row-${status}`);
  const findEnableScannersLink = (status) =>
    findLegendItem(status).find('[data-testid="enable-scanners-link"]');
  const legendCountFor = (status) =>
    findLegendItem(status).find('[data-testid="legend-count"]').text();
  const legendPercentFor = (status) =>
    findLegendItem(status).find('[data-testid="legend-percent"]').text();

  const createComponent = ({ handler, selection } = {}) => {
    const queryHandler = handler ?? jest.fn().mockResolvedValue(groupToolCoverageResponse);

    wrapper = shallowMountExtended(ToolCoverageCard, {
      apolloProvider: createMockApollo([[GroupToolCoverageQuery, queryHandler]]),
      propsData: { fullPath, ...(selection ? { selection } : {}) },
      stubs: {
        GlCard: stubComponent(GlCard, {
          template:
            '<div><slot name="header"></slot><slot></slot><slot name="footer"></slot></div>',
        }),
      },
    });

    return queryHandler;
  };

  describe('while loading', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders a skeleton loader instead of the chart', () => {
      expect(findSkeletonLoader().exists()).toBe(true);
      expect(findChart().exists()).toBe(false);
    });

    it('disables the scanner listbox', () => {
      expect(findListbox().props('disabled')).toBe(true);
    });
  });

  it('requests the coverage for the given group', () => {
    const handler = createComponent();

    expect(handler).toHaveBeenCalledWith({ fullPath });
  });

  describe('help popover', () => {
    beforeEach(() => {
      createComponent();
    });

    it('explains what the coverage is based on', () => {
      expect(findPopover().props('title')).toBe('Tool coverage');
      expect(findPopover().text()).toContain(
        'Coverage across all scanners, or for a single scanner, based on the scan status of the most recent pipeline on the default branch.',
      );
    });

    it('links to the scanner coverage documentation', () => {
      expect(findLearnMoreLink().attributes('href')).toBe(
        '/help/user/application_security/security_inventory/_index#scanner-coverage',
      );
    });
  });

  describe('when the query succeeds', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the card with the chart and hides the loader', () => {
      expect(findCard().exists()).toBe(true);
      expect(findChart().exists()).toBe(true);
      expect(findSkeletonLoader().exists()).toBe(false);
    });

    it.each`
      status              | percent  | count
      ${'SUCCESS'}        | ${'52%'} | ${'788'}
      ${'FAILED'}         | ${'20%'} | ${'299'}
      ${'STALE'}          | ${'20%'} | ${'306'}
      ${'NOT_CONFIGURED'} | ${'8%'}  | ${'127'}
    `('shows $count ($percent) in the legend for $status', ({ status, percent, count }) => {
      expect(legendPercentFor(status)).toBe(percent);
      expect(legendCountFor(status)).toBe(count);
    });

    it('passes the chart a colour per status', () => {
      expect(findChart().props('segments')).toMatchObject([
        { label: 'Enabled', color: 'var(--green-500)' },
        { label: 'Failed', color: 'var(--red-500)' },
        { label: 'Stale', color: 'var(--gl-color-neutral-600)' },
        { label: 'Not enabled', color: 'var(--gl-color-neutral-200)' },
      ]);
    });

    it('offers every scanner alongside an all-scanners option', () => {
      expect(
        findListbox()
          .props('items')
          .map(({ value }) => value),
      ).toEqual([
        'ALL',
        'DEPENDENCY_SCANNING',
        'SAST',
        'SECRET_DETECTION',
        'CONTAINER_SCANNING',
        'DAST',
        'SAST_IAC',
      ]);
    });

    it('links to the group security configuration', () => {
      expect(findConfigurationLink().attributes('href')).toBe(
        '/groups/gitlab-org/-/security/configuration',
      );
    });

    describe('enable scanners link', () => {
      it('offers it on the not-enabled row, pointing at the wizard', () => {
        const link = findEnableScannersLink('NOT_CONFIGURED');

        expect(link.text()).toBe('Enable scanners');
        expect(link.attributes('href')).toBe(
          '/groups/gitlab-org/-/security/configuration#/enable_scanners',
        );
      });

      it.each(['SUCCESS', 'FAILED', 'STALE'])('does not offer it on the %s row', (status) => {
        expect(findEnableScannersLink(status).exists()).toBe(false);
      });

      it('reveals it on row hover while keeping it reachable by keyboard', () => {
        expect(findEnableScannersLink('NOT_CONFIGURED').classes()).toEqual(
          expect.arrayContaining([
            'gl-opacity-0',
            'group-hover:gl-opacity-10',
            'focus:gl-opacity-10',
          ]),
        );
        expect(findLegendItem('NOT_CONFIGURED').classes()).toContain('gl-group');
      });
    });

    it('asks the parent to change the scanner', () => {
      findListbox().vm.$emit('select', 'DAST');

      expect(wrapper.emitted('update:selection')).toEqual([[{ scanner: 'DAST', status: null }]]);
    });

    it('selects the status behind a clicked legend row', () => {
      findLegendRow('FAILED').trigger('click');

      expect(wrapper.emitted('update:selection')).toEqual([[{ scanner: 'ALL', status: 'FAILED' }]]);
    });

    it('selects the status behind a clicked chart slice', () => {
      findChart().vm.$emit('select-status', 'STALE');

      expect(wrapper.emitted('update:selection')).toEqual([[{ scanner: 'ALL', status: 'STALE' }]]);
    });

    it('leaves every legend row unpressed while nothing is selected', () => {
      expect(wrapper.findAll('[aria-pressed="true"]')).toHaveLength(0);
    });

    describe('when a single scanner is selected', () => {
      beforeEach(async () => {
        createComponent({ selection: { scanner: 'DAST', status: null } });
        await waitForPromises();
      });

      it.each`
        status              | percent  | count
        ${'SUCCESS'}        | ${'40%'} | ${'88'}
        ${'FAILED'}         | ${'45%'} | ${'99'}
        ${'STALE'}          | ${'3%'}  | ${'6'}
        ${'NOT_CONFIGURED'} | ${'12%'} | ${'27'}
      `(
        'narrows $status to that scanner, showing $count ($percent)',
        ({ status, percent, count }) => {
          expect(legendPercentFor(status)).toBe(percent);
          expect(legendCountFor(status)).toBe(count);
        },
      );
    });

    describe('when a status is selected', () => {
      beforeEach(async () => {
        createComponent({ selection: { scanner: 'ALL', status: 'FAILED' } });
        await waitForPromises();
      });

      it('marks only that legend row as pressed', () => {
        expect(findLegendRow('FAILED').attributes('aria-pressed')).toBe('true');
        expect(findLegendRow('SUCCESS').attributes('aria-pressed')).toBe('false');
      });

      it('gives only that legend row the active background', () => {
        expect(findLegendItem('FAILED').classes()).toContain('gl-bg-feedback-info');
        expect(findLegendItem('SUCCESS').classes()).not.toContain('gl-bg-feedback-info');
      });

      it('leaves the grey hover to the rows that are not selected', () => {
        expect(findLegendItem('FAILED').classes()).not.toContain('hover:gl-bg-strong');
        expect(findLegendItem('SUCCESS').classes()).toContain('hover:gl-bg-strong');
      });

      it('tells the chart which segment is selected', () => {
        expect(findChart().props('segments')).toMatchObject([
          { label: 'Enabled', isSelected: false },
          { label: 'Failed', isSelected: true },
          { label: 'Stale', isSelected: false },
          { label: 'Not enabled', isSelected: false },
        ]);
      });

      it('clears the selection when that row is clicked again', () => {
        findLegendRow('FAILED').trigger('click');

        expect(wrapper.emitted('update:selection')).toEqual([[{ scanner: 'ALL', status: null }]]);
      });

      it('keeps the status when the scanner changes', () => {
        findListbox().vm.$emit('select', 'DAST');

        expect(wrapper.emitted('update:selection')).toEqual([
          [{ scanner: 'DAST', status: 'FAILED' }],
        ]);
      });
    });

    describe('hover', () => {
      it('tells the chart which segment is hovered when a legend row is entered', async () => {
        await findLegendRow('FAILED').trigger('mouseenter');

        expect(findChart().props('segments')).toMatchObject([
          { label: 'Enabled', isHovered: false },
          { label: 'Failed', isHovered: true },
          { label: 'Stale', isHovered: false },
          { label: 'Not enabled', isHovered: false },
        ]);
      });

      it('clears the hovered flag when the legend row is left', async () => {
        await findLegendRow('FAILED').trigger('mouseenter');
        await findLegendRow('FAILED').trigger('mouseleave');

        expect(
          findChart()
            .props('segments')
            .every(({ isHovered }) => !isHovered),
        ).toBe(true);
      });

      it('tracks hover-status events emitted by the chart', async () => {
        findChart().vm.$emit('hover-status', 'STALE');
        await nextTick();

        expect(findChart().props('segments')).toMatchObject([
          { label: 'Enabled', isHovered: false },
          { label: 'Failed', isHovered: false },
          { label: 'Stale', isHovered: true },
          { label: 'Not enabled', isHovered: false },
        ]);
      });
    });
  });

  describe('when the group has no analyzer data', () => {
    beforeEach(async () => {
      createComponent({
        handler: jest.fn().mockResolvedValue({
          data: {
            group: {
              ...groupToolCoverageResponse.data.group,
              descendantGroups: { __typename: 'GroupConnection', count: 0 },
              analyzerStatuses: [],
            },
          },
        }),
      });
      await waitForPromises();
    });

    it('renders zeroed counts rather than hiding the card', () => {
      expect(findCard().exists()).toBe(true);
      expect(legendCountFor('SUCCESS')).toBe('0');
      expect(legendPercentFor('SUCCESS')).toBe('0%');
    });
  });

  describe('when the query fails', () => {
    const error = new Error('nope');

    beforeEach(async () => {
      jest.spyOn(Sentry, 'captureException').mockImplementation();
      createComponent({
        handler: jest
          .fn()
          .mockRejectedValueOnce(error)
          .mockResolvedValue(groupToolCoverageResponse),
      });
      await waitForPromises();
    });

    it('hides the card so the page is not topped by a broken widget', () => {
      expect(findCard().exists()).toBe(false);
    });

    it('reports the error to Sentry', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(error);
    });

    describe('and a later group loads successfully', () => {
      beforeEach(async () => {
        await wrapper.setProps({ fullPath: 'gitlab-org/subgroup' });
        await waitForPromises();
      });

      it('shows the card again', () => {
        expect(findCard().exists()).toBe(true);
      });
    });
  });
});
