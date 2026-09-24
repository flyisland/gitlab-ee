import { GlBadge, GlBreadcrumb, GlIcon } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import MonorepoMrItem from 'jh/vue_merge_request_widget/components/monorepo_mr_item.vue';
import { mockMonorepoMr } from '../mock_data';

describe('MonorepoMrItem', () => {
  let wrapper;

  const createComponent = (additionalData = {}) => {
    wrapper = shallowMountExtended(MonorepoMrItem, {
      propsData: {
        mr: { ...mockMonorepoMr, ...additionalData },
      },
    });
  };

  const findMergeableBadge = () => wrapper.find('.monorepo-mr-meta').findComponent(GlBadge);
  const findStateBadge = () => wrapper.find('.mono-repo-mr-item-status').findComponent(GlBadge);
  const findPathSegments = () => wrapper.findComponent(GlBreadcrumb);
  const findPipelineIndicator = () => wrapper.findComponent(GlIcon);

  it('renders path segments', () => {
    createComponent();

    expect(findPathSegments().exists()).toBe(true);
  });

  it('renders mr title', () => {
    createComponent();

    expect(wrapper.find('.monorepo-mr-title').text()).toBe(mockMonorepoMr.title);
  });

  describe('Mergeable badge', () => {
    it('renders the badge while mergeable', () => {
      createComponent();

      expect(findMergeableBadge().exists()).toBe(true);
    });

    it('renders no mergeable badge', () => {
      createComponent({ mergeable: false });

      expect(findMergeableBadge().exists()).toBe(false);
    });
  });

  describe('MR state', () => {
    it('shows no state by default', () => {
      createComponent();

      expect(findStateBadge().exists()).toBe(false);
    });

    it('shows the state when merged', () => {
      createComponent({ state: 'merged' });

      expect(findStateBadge().exists()).toBe(true);
    });

    it('shows the state when closed', () => {
      createComponent({ state: 'closed' });

      expect(findStateBadge().exists()).toBe(true);
    });
  });

  describe('Pipeline status indicator', () => {
    it('shows the pipeline status when available', () => {
      createComponent();

      expect(findPipelineIndicator().exists()).toBe(true);
    });

    it('does not show the pipeline status when not available', () => {
      createComponent({ head_pipeline: null });

      expect(findPipelineIndicator().exists()).toBe(false);
    });

    it.each(['success', 'success-with-warnings', 'fail'])(
      'container with $group class',
      (group) => {
        createComponent({ head_pipeline: { ...mockMonorepoMr.head_pipeline, group } });

        expect(wrapper.find(`.ci-status-icon-${group}`).exists()).toBe(true);
      },
    );
  });
});
