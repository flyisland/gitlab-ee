import { GlAlert, GlButton, GlForm, GlFormInput } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import JobSidebar from '~/ci/job_details/components/sidebar/sidebar.vue';
import JobSidebarDetailsContainer from '~/ci/job_details/components/sidebar/sidebar_job_details_container.vue';
import createStore from '~/ci/job_details/store';
import JobTagsEditor from 'jh/ci/job_details/components/job_tags_editor.vue';
import 'jh/ci/job_details/job_tags_overrides';

jest.mock('~/alert');

describe('JH job tags editor', () => {
  let wrapper;
  let store;
  let mock;
  const updateTagsPath = '/group/project/-/jobs/1/update_tags';
  const jobEndpoint = '/group/project/-/jobs/1.json';
  const findEditButton = () => wrapper.findComponentByTestId('edit-job-tags');
  const findForm = () => wrapper.findComponent(GlForm);
  const findInput = () => wrapper.findComponent(GlFormInput);

  const createComponent = async (job = {}) => {
    store = createStore();
    store.state.jobEndpoint = jobEndpoint;
    await store.dispatch('receiveJobSuccess', {
      tags: ['runner-a'],
      update_tags_path: updateTagsPath,
      ...job,
    });
    wrapper = mountExtended(JobSidebar.components.JobSidebarDetailsContainer, {
      store,
      stubs: { GlFormInput: true },
      provide: { pipelineTestReportUrl: '/group/project/-/pipelines/1/test_report' },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    mock.onGet(jobEndpoint).reply(200, { tags: ['runner-b'], update_tags_path: updateTagsPath });
  });

  afterEach(() => {
    mock.restore();
  });

  it('keeps the upstream details and opens the editor with the current tags', async () => {
    await createComponent();
    expect(wrapper.findComponent(JobSidebarDetailsContainer).exists()).toBe(true);
    expect(wrapper.findComponent(JobTagsEditor).exists()).toBe(true);

    await findEditButton().vm.$emit('click');

    expect(findInput().attributes('value')).toBe('runner-a');
  });

  it('updates the tags displayed by the upstream component after saving', async () => {
    mock.onPatch(updateTagsPath).reply(200, { tags: ['runner-b'] });
    await createComponent();
    await findEditButton().vm.$emit('click');
    await findInput().vm.$emit('input', 'runner-b');
    await findForm().trigger('submit');
    await waitForPromises();

    expect(JSON.parse(mock.history.patch[0].data)).toEqual({ tags: ['runner-b'] });
    expect(wrapper.findComponent(JobSidebarDetailsContainer).text()).toContain('runner-b');
    expect(findForm().exists()).toBe(false);
  });

  it('keeps the input and shows the server error when the job was already picked up', async () => {
    mock.onPatch(updateTagsPath).reply(409, { message: 'The job is no longer pending.' });
    await createComponent();
    await findEditButton().vm.$emit('click');
    await findInput().vm.$emit('input', 'runner-b');
    await findForm().trigger('submit');
    await waitForPromises();

    expect(wrapper.findComponent(GlAlert).text()).toBe('The job is no longer pending.');
    expect(findInput().attributes('value')).toBe('runner-b');
    expect(store.state.job.tags).toEqual(['runner-a']);
  });

  it.each([false, true])('refreshes the stuck state to %s after saving', async (stuck) => {
    const runners = { online: !stuck, available: true };
    mock.onPatch(updateTagsPath).reply(200, { tags: ['runner-b'] });
    mock.onGet(jobEndpoint).reply(200, { tags: ['runner-b'], stuck, runners });
    await createComponent({ stuck: true, runners: { online: false, available: true } });
    await findEditButton().vm.$emit('click');
    await findForm().trigger('submit');
    await waitForPromises();

    expect(mock.history.get).toHaveLength(1);
    expect(store.state.job.stuck).toBe(stuck);
    expect(store.state.job.runners).toEqual(runners);
  });

  it('keeps saved tags and reports a refresh failure separately', async () => {
    mock.onPatch(updateTagsPath).reply(200, { tags: ['runner-b'] });
    mock.onGet(jobEndpoint).reply(500);
    await createComponent();
    await findEditButton().vm.$emit('click');
    await findForm().trigger('submit');
    await waitForPromises();

    expect(store.state.job.tags).toEqual(['runner-b']);
    expect(findForm().exists()).toBe(false);
    expect(createAlert).toHaveBeenCalledWith(
      expect.objectContaining({
        message: expect.stringContaining(
          'Tags were saved, but the job details could not be updated.',
        ),
      }),
    );
  });

  it('cancels without sending a request', async () => {
    await createComponent();
    await findEditButton().vm.$emit('click');
    await wrapper.findAllComponents(GlButton).at(1).vm.$emit('click');

    expect(findForm().exists()).toBe(false);
    expect(mock.history.patch).toHaveLength(0);
  });

  it('allows editing a job with no tags', async () => {
    await createComponent({ tags: [] });
    await findEditButton().vm.$emit('click');

    expect(findInput().attributes('value')).toBe('');
  });

  it('hides the editor when polling removes the update path', async () => {
    await createComponent();
    await findEditButton().vm.$emit('click');
    await store.dispatch('receiveJobSuccess', { tags: ['runner-a'] });

    expect(findForm().exists()).toBe(false);
    expect(findEditButton().exists()).toBe(false);
  });

  it('keeps existing tags visible without offering editing to unauthorized users', async () => {
    await createComponent({ update_tags_path: undefined });

    expect(wrapper.findComponent(JobSidebarDetailsContainer).text()).toContain('runner-a');
    expect(findEditButton().exists()).toBe(false);
  });
});
