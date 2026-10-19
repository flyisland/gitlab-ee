import VueApollo from 'vue-apollo';
import Vue, { nextTick } from 'vue';
import JobAssistantDrawer from 'jh/ci/pipeline_editor/components/job_assistant_drawer/job_assistant_drawer.vue';
import JobSetupItem from '~/ci/pipeline_editor/components/job_assistant_drawer/accordion_items/job_setup_item.vue';
import ImageItem from '~/ci/pipeline_editor/components/job_assistant_drawer/accordion_items/image_item.vue';
import ServicesItem from '~/ci/pipeline_editor/components/job_assistant_drawer/accordion_items/services_item.vue';
import ArtifactsAndCacheItem from '~/ci/pipeline_editor/components/job_assistant_drawer/accordion_items/artifacts_and_cache_item.vue';
import RulesItem from '~/ci/pipeline_editor/components/job_assistant_drawer/accordion_items/rules_item.vue';
import getRunnerTags from '~/ci/pipeline_editor/graphql/queries/runner_tags.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { getJobTemplateList } from 'jh/rest_api';

import JobTemplate from 'jh/ci/pipeline_editor/components/job_assistant_drawer/job_template.vue';

import { mountExtended } from 'helpers/vue_test_utils_helper';
import {
  mockRunnersTagsQueryResponse,
  mockLintResponse,
  mockCiYml,
} from 'jest/ci/pipeline_editor/mock_data';

import { mockJobTemplateList } from './mock_data';

jest.mock('jh/api/job_assistant_api');
Vue.use(VueApollo);

describe('Job assistant drawer', () => {
  let wrapper;
  let mockApollo;

  const findJobTemplate = () => wrapper.findComponent(JobTemplate);
  const findJobSetupItem = () => wrapper.findComponent(JobSetupItem);
  const findImageItem = () => wrapper.findComponent(ImageItem);
  const findServicesItem = () => wrapper.findComponent(ServicesItem);
  const findArtifactsAndCacheItem = () => wrapper.findComponent(ArtifactsAndCacheItem);
  const findRulesItem = () => wrapper.findComponent(RulesItem);

  const findConfirmButton = () => wrapper.findByTestId('confirm-button');
  const findCancelButton = () => wrapper.findByTestId('cancel-button');

  const createComponent = () => {
    mockApollo = createMockApollo([
      [getRunnerTags, jest.fn().mockResolvedValue(mockRunnersTagsQueryResponse)],
    ]);

    wrapper = mountExtended(JobAssistantDrawer, {
      propsData: {
        ciConfigData: mockLintResponse,
        ciFileContent: mockCiYml,
        isVisible: false,
      },
      provide: {
        glFeatures: {
          jobTemplate: true,
        },
      },
      apolloProvider: mockApollo,
    });
  };

  beforeEach(async () => {
    getJobTemplateList.mockReturnValue(Promise.resolve({ data: mockJobTemplateList }));
    createComponent();
    wrapper.setProps({ isVisible: true });
    await waitForPromises();
  });

  afterEach(() => {
    getJobTemplateList.mockReset();
  });

  it('should render job template after created', () => {
    expect(findJobTemplate().exists()).toBe(true);
  });

  it('should hide job template view when job template component emit hide event', async () => {
    findJobTemplate().vm.$emit('hide');

    await nextTick();

    expect(findJobTemplate().exists()).toBe(false);

    expect(findJobSetupItem().exists()).toBe(true);
    expect(findImageItem().exists()).toBe(true);
    expect(findServicesItem().exists()).toBe(true);
    expect(findArtifactsAndCacheItem().exists()).toBe(true);
    expect(findRulesItem().exists()).toBe(true);

    expect(findConfirmButton().exists()).toBe(true);
    expect(findCancelButton().exists()).toBe(true);
  });

  it('should show job template view when closing the drawer', async () => {
    findJobTemplate().vm.$emit('hide');

    await nextTick();

    await wrapper.setProps({
      isVisible: false,
    });

    await wrapper.setProps({
      isVisible: true,
    });

    expect(findJobTemplate().exists()).toBe(true);

    expect(findJobSetupItem().exists()).toBe(false);
    expect(findImageItem().exists()).toBe(false);
    expect(findServicesItem().exists()).toBe(false);
    expect(findArtifactsAndCacheItem().exists()).toBe(false);
    expect(findRulesItem().exists()).toBe(false);

    expect(findConfirmButton().exists()).toBe(false);
    expect(findCancelButton().exists()).toBe(false);
  });
});
