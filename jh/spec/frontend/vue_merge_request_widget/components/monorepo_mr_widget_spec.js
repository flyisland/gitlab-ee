import { nextTick } from 'vue';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import MonorepoMrWidget from 'jh/vue_merge_request_widget/components/monorepo_mr_widget.vue';
import MonorepoMrItem from 'jh/vue_merge_request_widget/components/monorepo_mr_item.vue';
import MonorepoMrPipeline from 'jh/vue_merge_request_widget/components/monorepo_mr_pipeline.vue';
import StatusIcon from '~/vue_merge_request_widget/components/widget/status_icon.vue';
import MrWidgetAuthorTime from '~/vue_merge_request_widget/components/mr_widget_author_time.vue';
import {
  mockMergedByUser,
  mockMergedAtTime,
  mockMonorepoMrWidgetData,
  mockCentralPipeline,
} from '../mock_data';

describe('Monorepo MR Widget', () => {
  let wrapper;
  let axiosAdapter;
  const testSourceProjectFullPath = 'test/project/path';
  const testIId = 1;
  const originalGl = window.gl;

  const createComponent = () => {
    wrapper = shallowMountExtended(MonorepoMrWidget);
  };

  const testAPIEndpoint = `/${testSourceProjectFullPath}/-/merge_requests/${testIId}.json?serializer=monorepo`;

  const findWidgetContainer = () => wrapper.find('.mr-widget-section');
  const findMergeButton = () => wrapper.findComponentByTestId('dispatch-merge-btn');
  const findToggleButton = () => wrapper.findComponentByTestId('toggle-merge-requests-btn');
  const findMrItems = () => wrapper.findAllComponents(MonorepoMrItem);
  const findStatusIcon = () => wrapper.findComponent(StatusIcon);

  beforeEach(() => {
    axiosAdapter = new MockAdapter(axios);
  });

  beforeAll(() => {
    window.gl = {
      mrWidgetData: {
        source_project_full_path: testSourceProjectFullPath,
        iid: testIId,
      },
    };
  });

  afterAll(() => {
    window.gl = originalGl;
  });

  it('renders widget after fetch data', async () => {
    axiosAdapter.onGet(testAPIEndpoint).reply(200, mockMonorepoMrWidgetData);

    createComponent();
    expect(findWidgetContainer().exists()).toBe(false);
    await waitForPromises();

    expect(findWidgetContainer().exists()).toBe(true);
    expect(findStatusIcon().exists()).toBe(true);

    const dispatchMergeBtn = findMergeButton();
    expect(dispatchMergeBtn.exists()).toBe(true);
    expect(dispatchMergeBtn.attributes('disabled')).toBeUndefined();
    expect(dispatchMergeBtn.attributes('loading')).toBeUndefined();
  });

  it('renders closed info for users', async () => {
    axiosAdapter.onGet(testAPIEndpoint).reply(200, {
      ...mockMonorepoMrWidgetData,
      merge_requests_list_status: 'closed',
    });
    createComponent();

    await waitForPromises();

    expect(wrapper.findByTestId('merge-request-closed').exists()).toBe(true);
  });

  it('should be able to toggle merge requests list', async () => {
    axiosAdapter.onGet(testAPIEndpoint).reply(200, mockMonorepoMrWidgetData);

    createComponent();
    await waitForPromises();

    expect(findMrItems()).toHaveLength(1);

    await findToggleButton().vm.$emit('click');

    expect(findMrItems()).toHaveLength(0);
  });

  it('should display merged by user and merged at time', async () => {
    axiosAdapter.onGet(testAPIEndpoint).reply(200, {
      ...mockMonorepoMrWidgetData,
      merge_requests_list_status: 'merged',
      merge_user: mockMergedByUser,
      merged_at: mockMergedAtTime,
    });

    createComponent();
    await waitForPromises();

    expect(wrapper.findComponent(MrWidgetAuthorTime).exists()).toBe(true);
    expect(findMergeButton().exists()).toBe(false);
  });

  it('should not allow dispatching merge when there is no permission', async () => {
    axiosAdapter.onGet(testAPIEndpoint).reply(200, {
      ...mockMonorepoMrWidgetData,
      has_permission_to_merge: false,
    });

    createComponent();
    await waitForPromises();

    expect(findMergeButton().exists()).toBe(false);
  });

  it('should not be able to click while merge train is full', async () => {
    axiosAdapter.onGet(testAPIEndpoint).reply(200, {
      ...mockMonorepoMrWidgetData,
      other_merging_topic_label_name: 'topic::some-other-topic',
    });

    createComponent();
    await waitForPromises();

    expect(findMergeButton().props('disabled')).toBe(true);
  });

  it('should show loading status to the user', async () => {
    axiosAdapter.onGet(testAPIEndpoint).reply(200, {
      ...mockMonorepoMrWidgetData,
      merge_requests_list_status: 'merging',
    });

    createComponent();
    await waitForPromises();

    const mergeBtn = findMergeButton();
    expect(mergeBtn.props('disabled')).toBe(true);
    expect(mergeBtn.props('loading')).toBe(true);
  });

  it('should be able to dispatch merge request to backend', async () => {
    axiosAdapter.onGet(testAPIEndpoint).replyOnce(200, mockMonorepoMrWidgetData);

    axiosAdapter
      .onPost(`/${testSourceProjectFullPath}/-/merge_requests/${testIId}/bulk_merge`)
      .reply(200, {});

    createComponent();
    await waitForPromises();

    axiosAdapter.onGet(testAPIEndpoint).replyOnce(200, {
      ...mockMonorepoMrWidgetData,
      merge_requests_list_status: 'merged',
      merge_user: mockMergedByUser,
      merged_at: mockMergedAtTime,
    });

    findMergeButton().vm.$emit('click');
    await nextTick();
    expect(findMergeButton().props('disabled')).toBe(true);
    await waitForPromises();
    expect(findMergeButton().exists()).toBe(false);
  });

  it('should render central pipeline status while presented', async () => {
    axiosAdapter.onGet(testAPIEndpoint).replyOnce(200, {
      ...mockMonorepoMrWidgetData,
      central_pipeline: mockCentralPipeline,
    });

    createComponent();
    await waitForPromises();
    expect(wrapper.findComponent(MonorepoMrPipeline).exists()).toBe(true);
  });
});
