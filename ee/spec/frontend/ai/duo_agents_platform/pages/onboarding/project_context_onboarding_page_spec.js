import MockAdapter from 'axios-mock-adapter';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import {
  HTTP_STATUS_CREATED,
  HTTP_STATUS_CONFLICT,
  HTTP_STATUS_UNPROCESSABLE_ENTITY,
} from '~/lib/utils/http_status';
import ProjectContextOnboardingPage from 'ee/ai/duo_agents_platform/pages/onboarding/project_context_onboarding_page.vue';

jest.mock('~/alert');

const INITIALIZE_PATH = '/namespace/project/-/automate/onboarding/initialize';
const WORKFLOW_ID = 42;

describe('ProjectContextOnboardingPage', () => {
  let wrapper;
  let mockAxios;

  const createWrapper = ({ hasAgentsMd = false } = {}) => {
    gon.has_agents_md = hasAgentsMd;
    gon.initialize_context_path = INITIALIZE_PATH;

    wrapper = shallowMountExtended(ProjectContextOnboardingPage, {
      mocks: {
        $router: {
          resolve: jest.fn().mockReturnValue({ href: `/sessions/${WORKFLOW_ID}` }),
        },
      },
    });
  };

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAxios.restore();
  });

  const findInitButton = () => wrapper.findByTestId('initialize-project-context-button');

  describe('when AGENTS.md already exists', () => {
    beforeEach(() => {
      createWrapper({ hasAgentsMd: true });
    });

    it('shows the already-initialized alert', () => {
      expect(wrapper.findByTestId('agents-md-present-alert').exists()).toBe(true);
    });

    it('does not show the initialize button', () => {
      expect(findInitButton().exists()).toBe(false);
    });
  });

  describe('when initializeContextPath is not set', () => {
    beforeEach(() => {
      gon.has_agents_md = false;
      gon.initialize_context_path = undefined;
      wrapper = shallowMountExtended(ProjectContextOnboardingPage, {
        mocks: {
          $router: {
            resolve: jest.fn().mockReturnValue({ href: `/sessions/${WORKFLOW_ID}` }),
          },
        },
      });
    });

    it('calls createAlert with a fallback message when initializeProjectContext is called', async () => {
      await wrapper.vm.initializeProjectContext();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({
          message: 'Something went wrong while initializing project context.',
        }),
      );
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
      expect(wrapper.findByTestId('agents-md-present-alert').exists()).toBe(false);
    });

    describe('on successful initialization', () => {
      beforeEach(async () => {
        mockAxios.onPost(INITIALIZE_PATH).reply(HTTP_STATUS_CREATED, { workflow_id: WORKFLOW_ID });
        await wrapper.vm.initializeProjectContext();
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
        mockAxios.onPost(INITIALIZE_PATH).reply(HTTP_STATUS_CONFLICT, {
          message: 'Project context has already been initialized.',
        });
        await wrapper.vm.initializeProjectContext();
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
        mockAxios.onPost(INITIALIZE_PATH).reply(HTTP_STATUS_CONFLICT, {
          message: 'Project context initialization is already in progress.',
          workflow_id: WORKFLOW_ID,
        });
        await wrapper.vm.initializeProjectContext();
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
        mockAxios.onPost(INITIALIZE_PATH).reply(HTTP_STATUS_UNPROCESSABLE_ENTITY, {
          message: 'something went wrong',
        });
        await wrapper.vm.initializeProjectContext();
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
  });
});
