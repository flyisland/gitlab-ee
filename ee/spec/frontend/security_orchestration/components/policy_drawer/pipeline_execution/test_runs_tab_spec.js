import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlAlert, GlButton, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import TestRunsTab from 'ee/security_orchestration/components/policy_drawer/pipeline_execution/test_runs_tab.vue';
import GroupProjectsDropdown from 'ee/security_orchestration/components/shared/group_projects_dropdown.vue';
import { NAMESPACE_TYPES } from 'ee/security_orchestration/constants';
import projectPolicyTestRunsQuery from 'ee/security_orchestration/graphql/queries/project_policy_test_runs.query.graphql';
import groupPolicyTestRunsQuery from 'ee/security_orchestration/graphql/queries/group_policy_test_runs.query.graphql';
import spepTestRunMutation from 'ee/security_orchestration/graphql/mutations/spep_test_run.mutation.graphql';

Vue.use(VueApollo);

describe('TestRunsTab', () => {
  let wrapper;
  let projectQueryHandler;
  let groupQueryHandler;
  let mutationHandler;

  const mockTestRun = {
    id: 'gid://gitlab/Security::ScheduledPipelineExecutionPolicyTestRun/1',
    state: 'COMPLETE',
    startedAt: '2024-01-01T00:00:00Z',
    finishedAt: '2024-01-01T00:05:00Z',
    duration: 300,
    errorMessage: null,
    createdAt: '2024-01-01T00:00:00Z',
    project: {
      id: 'gid://gitlab/Project/1',
      fullPath: 'gitlab-org/gitlab',
      name: 'GitLab',
    },
  };

  const mockPolicy = {
    id: 'gid://gitlab/Security::Policy/1',
    name: 'Test Policy',
    yaml: 'name: Test Policy',
  };

  const createMockQueryResponse = (testRun = null) => ({
    data: {
      namespace: {
        id: '1',
        securityPolicies: {
          nodes: [
            {
              id: 'gid://gitlab/Security::Policy/1',
              name: 'Test Policy',
              testRuns: {
                nodes: testRun ? [testRun] : [],
              },
            },
          ],
        },
      },
    },
  });

  const createMockMutationResponse = (testRun = mockTestRun, errors = []) => ({
    data: {
      pipelineExecutionSchedulePolicyTestRun: {
        testRun,
        pipeline: testRun
          ? {
              id: 'gid://gitlab/Ci::Pipeline/1',
              status: 'running',
            }
          : null,
        errors,
      },
    },
  });

  const createComponent = ({
    provide = {},
    policy = mockPolicy,
    testRun = mockTestRun,
    isGroup = false,
    mutationResponse = createMockMutationResponse(),
  } = {}) => {
    const namespaceType = isGroup ? NAMESPACE_TYPES.GROUP : NAMESPACE_TYPES.PROJECT;
    projectQueryHandler = jest.fn().mockResolvedValue(createMockQueryResponse(testRun));
    groupQueryHandler = jest.fn().mockResolvedValue(createMockQueryResponse(testRun));
    mutationHandler = jest.fn().mockResolvedValue(mutationResponse);

    const mockApollo = createMockApollo([
      [projectPolicyTestRunsQuery, projectQueryHandler],
      [groupPolicyTestRunsQuery, groupQueryHandler],
      [spepTestRunMutation, mutationHandler],
    ]);

    wrapper = shallowMountExtended(TestRunsTab, {
      apolloProvider: mockApollo,
      propsData: {
        policy,
      },
      provide: {
        namespaceType,
        namespacePath: isGroup ? 'gitlab-org' : 'gitlab-org/gitlab',
        ...provide,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  const findTitle = () => wrapper.findByTestId('test-runs-title');
  const findDescription = () => wrapper.findByTestId('test-runs-description');
  const findErrorAlert = () => wrapper.findComponent(GlAlert);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findTestRunResults = () => wrapper.findByTestId('test-run-results');
  const findTestRunDetails = () => wrapper.findByTestId('test-run-details');
  const findNoTestRun = () => wrapper.findByTestId('no-test-runs');
  const findRunTestButton = () => wrapper.findComponent(GlButton);
  const findProjectSelectorSection = () => wrapper.findByTestId('project-selector-section');
  const findProjectSelector = () => wrapper.findComponent(GroupProjectsDropdown);

  describe('default rendering', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the title', () => {
      expect(findTitle().exists()).toBe(true);
      expect(findTitle().text()).toBe('Test runs');
    });

    it('renders the description', () => {
      expect(findDescription().exists()).toBe(true);
    });

    it('renders the run test button', () => {
      expect(findRunTestButton().exists()).toBe(true);
      expect(findRunTestButton().text()).toBe('Begin test run');
    });

    it('does not render error alert initially', () => {
      expect(findErrorAlert().exists()).toBe(false);
    });
  });

  describe('loading state', () => {
    it('shows loading icon when fetching test run data', () => {
      createComponent();

      expect(findLoadingIcon().exists()).toBe(true);
      expect(findTestRunResults().exists()).toBe(false);
      expect(findNoTestRun().exists()).toBe(false);
    });
  });

  describe('with test run', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders test run results section', () => {
      expect(findTestRunResults().exists()).toBe(true);
    });

    it('displays test run information', () => {
      const testRunText = findTestRunDetails().text();

      expect(testRunText).toContain('Complete');
      expect(testRunText).toContain('gitlab-org/gitlab');
    });

    it('does not show no test run message', () => {
      expect(findNoTestRun().exists()).toBe(false);
    });

    it('does not show loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });
  });

  describe('without test run', () => {
    beforeEach(async () => {
      createComponent({ testRun: null });
      await waitForPromises();
    });

    it('shows no test run message', () => {
      expect(findNoTestRun().exists()).toBe(true);
      expect(findNoTestRun().text()).toContain('No test runs found');
    });

    it('does not render test run results section', () => {
      expect(findTestRunResults().exists()).toBe(false);
    });
  });

  describe('with test run error message', () => {
    it('displays error message when provided', async () => {
      createComponent({
        testRun: {
          ...mockTestRun,
          state: 'FAILED',
          errorMessage: 'Pipeline execution failed',
        },
      });
      await waitForPromises();

      expect(findTestRunDetails().text()).toContain('Pipeline execution failed');
    });

    it('displays generic error message when errorMessage is null', async () => {
      createComponent({
        testRun: {
          ...mockTestRun,
          state: 'FAILED',
          errorMessage: null,
        },
      });
      await waitForPromises();

      expect(findTestRunDetails().text()).toContain(
        'The test run failed for an unspecified reason',
      );
    });
  });

  describe('at project level', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('does not render project selector', () => {
      expect(findProjectSelectorSection().exists()).toBe(false);
    });

    it('enables run test button by default', () => {
      expect(findRunTestButton().attributes('disabled')).toBeUndefined();
    });
  });

  describe('at group level', () => {
    beforeEach(async () => {
      createComponent({ isGroup: true });
      await waitForPromises();
    });

    it('renders project selector', () => {
      expect(findProjectSelectorSection().exists()).toBe(true);
      expect(findProjectSelector().exists()).toBe(true);
    });

    it('disables run test button when no project selected', () => {
      expect(findRunTestButton().props('disabled')).toBe(true);
    });

    it('enables run test button when project is selected', async () => {
      await findProjectSelector().vm.$emit('select', {
        id: '1',
        name: 'Test Project',
        fullPath: 'gitlab-org/test',
      });

      expect(findRunTestButton().attributes('disabled')).toBeUndefined();
    });
  });

  describe('duration formatting', () => {
    it('formats duration in minutes', async () => {
      createComponent({
        testRun: { ...mockTestRun, duration: 120 },
      });
      await waitForPromises();

      expect(findTestRunDetails().text()).toContain('2 minutes');
    });

    it('formats duration in seconds for short durations', async () => {
      createComponent({
        testRun: { ...mockTestRun, duration: 30 },
      });
      await waitForPromises();

      expect(findTestRunDetails().text()).toContain('30 seconds');
    });

    it('handles zero duration', async () => {
      createComponent({
        testRun: { ...mockTestRun, duration: 0 },
      });
      await waitForPromises();

      expect(findTestRunDetails().text()).toContain('0 seconds');
    });
  });

  describe('state formatting', () => {
    it.each([
      ['RUNNING', 'Running'],
      ['COMPLETE', 'Complete'],
      ['FAILED', 'Failed'],
    ])('formats %s state as %s', async (state, expected) => {
      createComponent({
        testRun: { ...mockTestRun, state },
      });
      await waitForPromises();

      expect(findTestRunDetails().text()).toContain(expected);
    });
  });

  describe('running a test', () => {
    it('shows loading state when test is running', async () => {
      createComponent({ testRun: null });
      await waitForPromises();

      expect(findRunTestButton().attributes('loading')).toBeUndefined();

      await findRunTestButton().vm.$emit('click');

      expect(findRunTestButton().attributes('loading')).toBe('true');
    });

    it('prevents multiple simultaneous test runs', async () => {
      createComponent({ testRun: null });
      await waitForPromises();

      await findRunTestButton().vm.$emit('click');
      expect(findRunTestButton().props('disabled')).toBe(true);
    });

    it('calls mutation with correct variables at project level', async () => {
      createComponent({ testRun: null });
      await waitForPromises();

      await findRunTestButton().vm.$emit('click');
      await waitForPromises();

      expect(mutationHandler).toHaveBeenCalledWith({
        policyId: mockPolicy.id,
        projectPath: 'gitlab-org/gitlab',
      });
    });

    it('calls mutation with selected project path at group level', async () => {
      createComponent({ testRun: null, isGroup: true });
      await waitForPromises();

      await findProjectSelector().vm.$emit('select', {
        id: '1',
        name: 'Test Project',
        fullPath: 'gitlab-org/test-project',
      });

      await findRunTestButton().vm.$emit('click');
      await waitForPromises();

      expect(mutationHandler).toHaveBeenCalledWith({
        policyId: mockPolicy.id,
        projectPath: 'gitlab-org/test-project',
      });
    });

    it('refetches query after successful mutation', async () => {
      createComponent({ testRun: null });
      await waitForPromises();

      expect(projectQueryHandler).toHaveBeenCalledTimes(1);

      await findRunTestButton().vm.$emit('click');
      await waitForPromises();

      expect(projectQueryHandler).toHaveBeenCalledTimes(2);
    });
  });

  describe('error handling', () => {
    it('shows error alert when mutation returns errors', async () => {
      createComponent({
        testRun: null,
        mutationResponse: createMockMutationResponse(null, ['Policy not found']),
      });
      await waitForPromises();

      await findRunTestButton().vm.$emit('click');
      await waitForPromises();

      expect(findErrorAlert().exists()).toBe(true);
      expect(findErrorAlert().text()).toContain('Policy not found');
    });

    it('shows error alert when mutation throws', async () => {
      createComponent({ testRun: null });
      mutationHandler.mockRejectedValueOnce(new Error('Network error'));
      await waitForPromises();

      await findRunTestButton().vm.$emit('click');
      await waitForPromises();

      expect(findErrorAlert().exists()).toBe(true);
      expect(findErrorAlert().text()).toContain('Network error');
    });

    it('can dismiss error alert', async () => {
      createComponent({
        testRun: null,
        mutationResponse: createMockMutationResponse(null, ['Policy not found']),
      });
      await waitForPromises();

      await findRunTestButton().vm.$emit('click');
      await waitForPromises();

      expect(findErrorAlert().exists()).toBe(true);

      await findErrorAlert().vm.$emit('dismiss');

      expect(findErrorAlert().exists()).toBe(false);
    });
  });
});
