import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ListView from '~/work_items/list/list_view.vue';
import ListViewEE from 'ee/work_items/list/list_view.vue';
import { WORK_ITEM_TYPE_NAME_EPIC } from '~/work_items/constants';
import { CREATED_DESC } from '~/work_items/list/constants';
import { STATUS_OPEN } from '~/issues/constants';

/** @type {import('helpers/vue_test_utils_helper').ExtendedWrapper} */
let wrapper;

const findListView = () => wrapper.findComponent(ListView);

const baseProvide = {
  groupIssuesPath: 'groups/gitlab-org/-/issues',
  namespaceName: 'Test',
};

const mountComponent = ({
  hasEpicsFeature = true,
  hasIssueWeightsFeature = false,
  hasIssuableHealthStatusFeature = false,
  hasCustomFieldsFeature = true,
  hasIterationsFeature = false,
  hasStatusFeature = true,
  showNewWorkItem = true,
  isGroup = true,
  workItemType = WORK_ITEM_TYPE_NAME_EPIC,
  props = {},
} = {}) => {
  wrapper = shallowMountExtended(ListViewEE, {
    provide: {
      hasEpicsFeature,
      hasCustomFieldsFeature,
      hasIssueWeightsFeature,
      hasIssuableHealthStatusFeature,
      hasIterationsFeature,
      showNewWorkItem,
      isGroup,
      workItemType,
      hasStatusFeature,
      ...baseProvide,
    },
    stubs: {
      EmptyStateWithoutAnyIssues: {
        template: '<div></div>',
      },
    },
    propsData: {
      rootPageFullPath: 'gitlab-org',
      workItems: ['just', 'an', 'example'],
      workItemTypes: ['just', 'an', 'example'],
      hasWorkItems: false,
      isInitialLoadComplete: true,
      initialLoadWasFiltered: false,
      isLoading: false,
      detailLoading: false,
      showBulkEditSidebar: false,
      pageInfo: {},
      sortKey: CREATED_DESC,
      isSortKeyInitialized: true,
      state: STATUS_OPEN,
      ...props,
    },
  });
};

describe('planning view props', () => {
  it('passes work item data props down to the ce list_view component', () => {
    mountComponent();

    const props = findListView().props();

    expect(props).toMatchObject({
      rootPageFullPath: 'gitlab-org',
      workItems: ['just', 'an', 'example'],
      hasWorkItems: false,
      isInitialLoadComplete: true,
      isLoading: false,
      detailLoading: false,
      initialLoadWasFiltered: false,
    });
  });
});
