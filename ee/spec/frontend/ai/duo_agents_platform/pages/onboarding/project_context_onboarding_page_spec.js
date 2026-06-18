import { GlLink, GlSprintf } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import {
  HTTP_STATUS_CREATED,
  HTTP_STATUS_CONFLICT,
  HTTP_STATUS_UNPROCESSABLE_ENTITY,
} from '~/lib/utils/http_status';
import ProjectContextOnboardingPage from 'ee/ai/duo_agents_platform/pages/onboarding/project_context_onboarding_page.vue';
import OnboardingAction from 'ee/ai/duo_agents_platform/pages/onboarding/components/onboarding_action.vue';

jest.mock('~/alert');

const INITIALIZE_PATH = '/namespace/project/-/automate/onboarding/initialize';
const WORKFLOW_ID = 42;
const IN_PROGRESS_MESSAGE = 'Project context initialization is already in progress.';

describe('ProjectContextOnboardingPage', () => {
  let wrapper;
  let mockAxios;

  const createWrapper = ({
    projectContextInitialized = false,
    hasGitlabCiYml = false,
    inProgressWorkflowId = null,
    finishedWorkflowId = null,
    hasAgentConfig = false,
    hasMrReviewInstructions = false,
    shallow = true,
  } = {}) => {
    gon.project_context_initialized = projectContextInitialized;
    gon.initialize_context_path = INITIALIZE_PATH;
    gon.has_gitlab_ci_yml = hasGitlabCiYml;
    gon.in_progress_onboarding_workflow_id = inProgressWorkflowId;
    gon.finished_onboarding_workflow_id = finishedWorkflowId;
    gon.has_agent_config = hasAgentConfig;
    gon.has_mr_review_instructions = hasMrReviewInstructions;
    gon.in_progress_onboarding_message = inProgressWorkflowId ? IN_PROGRESS_MESSAGE : null;

    const mountFn = shallow ? shallowMountExtended : mountExtended;
    wrapper = mountFn(ProjectContextOnboardingPage, {
      mocks: {
        $router: {
          resolve: jest.fn().mockReturnValue({ href: `/sessions/${WORKFLOW_ID}` }),
        },
      },
      stubs: { GlSprintf },
    });
  };

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAxios.restore();
  });

  const findInitButton = () => wrapper.findByTestId('initialize-project-context-button');
  const findOnboardingAction = () => wrapper.findComponent(OnboardingAction);
  const findExecutionEnvAction = () => wrapper.findByTestId('initialize-execution-env-action');
  const findMrReviewInstructionsAction = () =>
    wrapper.findByTestId('initialize-mr-review-instructions-action');

  describe('when project context is already initialized', () => {
    beforeEach(() => {
      createWrapper({ projectContextInitialized: true });
    });

    it('shows the already-initialized alert', () => {
      expect(wrapper.findByTestId('project-context-initialized-alert').exists()).toBe(true);
    });

    it('does not show the initialize button', () => {
      expect(findInitButton().exists()).toBe(false);
    });
  });

  describe('when the onboarding workflow has already finished on page load', () => {
    beforeEach(() => {
      createWrapper({ projectContextInitialized: true, finishedWorkflowId: WORKFLOW_ID });
    });

    it('shows the already-initialized alert', () => {
      expect(wrapper.findByTestId('project-context-initialized-alert').exists()).toBe(true);
    });

    it('does not show the initialize button', () => {
      expect(findInitButton().exists()).toBe(false);
    });

    it('renders a session link inside the alert', () => {
      const link = wrapper.findByTestId('project-context-initialized-alert').findComponent(GlLink);

      expect(link.attributes('href')).toBe(`/sessions/${WORKFLOW_ID}`);
    });
  });

  describe('when an onboarding workflow is already in progress on page load', () => {
    beforeEach(() => {
      createWrapper({ inProgressWorkflowId: WORKFLOW_ID });
    });

    it('shows the in-progress conflict alert with a link', () => {
      expect(wrapper.findByTestId('conflict-in-progress-alert').exists()).toBe(true);
    });

    it('does not show the initialize button', () => {
      expect(findInitButton().exists()).toBe(false);
    });

    it('does not show the workflow started alert', () => {
      expect(wrapper.findByTestId('workflow-started-alert').exists()).toBe(false);
    });
  });

  describe('when AGENTS.md does not exist', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('shows the initialize button', () => {
      expect(findInitButton().exists()).toBe(true);
    });

    it('does not show the already-initialized alert', () => {
      expect(wrapper.findByTestId('project-context-initialized-alert').exists()).toBe(false);
    });

    describe('on successful initialization', () => {
      beforeEach(async () => {
        createWrapper({ shallow: false });
        mockAxios.onPost(INITIALIZE_PATH).reply(HTTP_STATUS_CREATED, { workflow_id: WORKFLOW_ID });
        await findInitButton().trigger('click');
        await axios.waitForAll();
      });

      it('does NOT send workflow_definition or goal in the request body', () => {
        const body = JSON.parse(mockAxios.history.post[0].data || '{}');
        expect(body).not.toHaveProperty('workflow_definition');
        expect(body).not.toHaveProperty('goal');
      });

      it('posts to the controller-provided initialize_context_path', () => {
        expect(mockAxios.history.post[0].url).toBe(INITIALIZE_PATH);
      });

      it('shows the workflow started alert', () => {
        expect(wrapper.findByTestId('workflow-started-alert').exists()).toBe(true);
      });

      it('hides the initialize button', () => {
        expect(findInitButton().exists()).toBe(false);
      });
    });

    describe('on 409 conflict — already initialized (no workflow_id returned)', () => {
      beforeEach(async () => {
        createWrapper({ shallow: false });
        mockAxios.onPost(INITIALIZE_PATH).reply(HTTP_STATUS_CONFLICT, {
          message: 'Project context has already been initialized.',
        });
        await findInitButton().trigger('click');
        await axios.waitForAll();
      });

      it('shows the conflict alert', () => {
        expect(wrapper.findByTestId('conflict-alert').exists()).toBe(true);
      });

      it('does not show the workflow started alert', () => {
        expect(wrapper.findByTestId('workflow-started-alert').exists()).toBe(false);
      });

      it('hides the initialize button', () => {
        expect(findInitButton().exists()).toBe(false);
      });
    });

    describe('on 409 conflict — already in progress (workflow_id returned)', () => {
      beforeEach(async () => {
        createWrapper({ shallow: false });
        mockAxios.onPost(INITIALIZE_PATH).reply(HTTP_STATUS_CONFLICT, {
          message: 'Project context initialization is already in progress.',
          workflow_id: WORKFLOW_ID,
        });
        await findInitButton().trigger('click');
        await axios.waitForAll();
      });

      it('shows the in-progress conflict alert with a link', () => {
        expect(wrapper.findByTestId('conflict-in-progress-alert').exists()).toBe(true);
      });

      it('does not show the plain conflict alert', () => {
        expect(wrapper.findByTestId('conflict-alert').exists()).toBe(false);
      });

      it('hides the initialize button', () => {
        expect(findInitButton().exists()).toBe(false);
      });
    });

    describe('on unprocessable entity error', () => {
      beforeEach(async () => {
        createWrapper({ shallow: false });
        mockAxios.onPost(INITIALIZE_PATH).reply(HTTP_STATUS_UNPROCESSABLE_ENTITY, {
          message: 'something went wrong',
        });
        await findInitButton().trigger('click');
        await axios.waitForAll();
      });

      it('calls createAlert with the error message', () => {
        expect(createAlert).toHaveBeenCalledWith(
          expect.objectContaining({ message: 'something went wrong' }),
        );
      });

      it('does not show the workflow started alert', () => {
        expect(wrapper.findByTestId('workflow-started-alert').exists()).toBe(false);
      });

      it('shows the initialize button again', () => {
        expect(findInitButton().exists()).toBe(true);
      });
    });

    describe('when initializeContextPath is not set', () => {
      beforeEach(async () => {
        gon.initialize_context_path = undefined;
        createWrapper({ shallow: false });
        await findInitButton().trigger('click');
        await axios.waitForAll();
      });

      it('calls createAlert with a fallback message', () => {
        expect(createAlert).toHaveBeenCalledWith(
          expect.objectContaining({
            message: 'Something went wrong while initializing project context.',
          }),
        );
      });
    });
  });

  describe('CI improvements section', () => {
    it('renders OnboardingAction with correct props', () => {
      createWrapper();
      expect(findOnboardingAction().props()).toMatchObject({
        gonPathKey: 'improve_ci_path',
        buttonLabel: 'Improve CI setup',
        actionDisabled: true,
      });
    });

    describe('when .gitlab-ci.yml does not exist', () => {
      beforeEach(() => {
        createWrapper({ hasGitlabCiYml: false });
      });

      it('passes actionDisabled=true to OnboardingAction', () => {
        expect(findOnboardingAction().props('actionDisabled')).toBe(true);
      });

      it('shows the no-gitlab-ci-yml alert', () => {
        expect(wrapper.findByTestId('no-gitlab-ci-yml-alert').exists()).toBe(true);
      });
    });

    describe('when .gitlab-ci.yml exists', () => {
      beforeEach(() => {
        createWrapper({ hasGitlabCiYml: true });
      });

      it('passes actionDisabled=false to OnboardingAction', () => {
        expect(findOnboardingAction().props('actionDisabled')).toBe(false);
      });

      it('does not show the no-gitlab-ci-yml alert', () => {
        expect(wrapper.findByTestId('no-gitlab-ci-yml-alert').exists()).toBe(false);
      });
    });
  });

  describe('execution environment section', () => {
    it('renders OnboardingAction with correct props', () => {
      createWrapper();
      expect(findExecutionEnvAction().props()).toMatchObject({
        gonPathKey: 'initialize_execution_env_path',
        buttonLabel: 'Initialize execution environment',
        actionDisabled: false,
      });
    });

    describe('when .gitlab/duo/agent-config.yml already exists', () => {
      beforeEach(() => {
        createWrapper({ hasAgentConfig: true });
      });

      it('passes actionDisabled=true to OnboardingAction', () => {
        expect(findExecutionEnvAction().props('actionDisabled')).toBe(true);
      });

      it('shows the agent-config-present alert', () => {
        expect(wrapper.findByTestId('agent-config-present-alert').exists()).toBe(true);
      });
    });

    describe('when .gitlab/duo/agent-config.yml does not exist', () => {
      beforeEach(() => {
        createWrapper({ hasAgentConfig: false });
      });

      it('passes actionDisabled=false to OnboardingAction', () => {
        expect(findExecutionEnvAction().props('actionDisabled')).toBe(false);
      });

      it('does not show the agent-config-present alert', () => {
        expect(wrapper.findByTestId('agent-config-present-alert').exists()).toBe(false);
      });
    });
  });

  describe('code review instructions section', () => {
    it('renders OnboardingAction with correct props', () => {
      createWrapper();
      expect(findMrReviewInstructionsAction().props()).toMatchObject({
        gonPathKey: 'initialize_mr_review_instructions_path',
        buttonLabel: 'Initialize code review instructions',
        fallbackErrorMessage: 'Something went wrong while initializing code review instructions.',
        actionDisabled: false,
      });
    });

    describe('when .gitlab/duo/mr-review-instructions.yaml already exists', () => {
      beforeEach(() => {
        createWrapper({ hasMrReviewInstructions: true });
      });

      it('passes actionDisabled=true to OnboardingAction', () => {
        expect(findMrReviewInstructionsAction().props('actionDisabled')).toBe(true);
      });

      it('shows the mr-review-instructions-present alert', () => {
        expect(wrapper.findByTestId('mr-review-instructions-present-alert').exists()).toBe(true);
      });
    });

    describe('when .gitlab/duo/mr-review-instructions.yaml does not exist', () => {
      beforeEach(() => {
        createWrapper({ hasMrReviewInstructions: false });
      });

      it('does not show the mr-review-instructions-present alert', () => {
        expect(wrapper.findByTestId('mr-review-instructions-present-alert').exists()).toBe(false);
      });
    });
  });
});
