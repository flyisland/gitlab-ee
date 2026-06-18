import MockAdapter from 'axios-mock-adapter';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import {
  HTTP_STATUS_CREATED,
  HTTP_STATUS_CONFLICT,
  HTTP_STATUS_UNPROCESSABLE_ENTITY,
} from '~/lib/utils/http_status';
import OnboardingAction from 'ee/ai/duo_agents_platform/pages/onboarding/components/onboarding_action.vue';

jest.mock('~/alert');

const ACTION_PATH = '/namespace/project/-/automate/onboarding/some_action';
const WORKFLOW_ID = 99;
const BUTTON_LABEL = 'Run action';
const FALLBACK_ERROR = 'Something went wrong.';

describe('OnboardingAction', () => {
  let wrapper;
  let mockAxios;

  const createWrapper = ({
    gonPathKey = 'some_action_path',
    actionDisabled = false,
    slots = {},
  } = {}) => {
    gon[gonPathKey] = ACTION_PATH;

    wrapper = mountExtended(OnboardingAction, {
      propsData: {
        gonPathKey,
        fallbackErrorMessage: FALLBACK_ERROR,
        buttonLabel: BUTTON_LABEL,
        actionDisabled,
      },
      mocks: {
        $router: {
          resolve: jest.fn().mockReturnValue({ href: `/sessions/${WORKFLOW_ID}` }),
        },
      },
      slots,
    });
  };

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAxios.restore();
  });

  const findActionButton = () => wrapper.findByTestId('action-button');

  it('renders the action button with the given label', () => {
    createWrapper();
    expect(findActionButton().text()).toBe(BUTTON_LABEL);
  });

  describe('when actionDisabled is true', () => {
    it('does not render the action button', () => {
      createWrapper({ actionDisabled: true });
      expect(findActionButton().exists()).toBe(false);
    });
  });

  describe('on successful action', () => {
    beforeEach(async () => {
      createWrapper();
      mockAxios.onPost(ACTION_PATH).reply(HTTP_STATUS_CREATED, { workflow_id: WORKFLOW_ID });
      await findActionButton().trigger('click');
      await axios.waitForAll();
    });

    it('shows the workflow started alert', () => {
      expect(wrapper.findByTestId('workflow-started-alert').exists()).toBe(true);
    });

    it('hides the action button', () => {
      expect(findActionButton().exists()).toBe(false);
    });
  });

  describe('on 409 conflict with workflow_id', () => {
    beforeEach(async () => {
      createWrapper();
      mockAxios.onPost(ACTION_PATH).reply(HTTP_STATUS_CONFLICT, {
        message: 'Already in progress.',
        workflow_id: WORKFLOW_ID,
      });
      await findActionButton().trigger('click');
      await axios.waitForAll();
    });

    it('shows the conflict-in-progress alert', () => {
      expect(wrapper.findByTestId('conflict-in-progress-alert').exists()).toBe(true);
    });

    it('does not show the plain conflict alert', () => {
      expect(wrapper.findByTestId('conflict-alert').exists()).toBe(false);
    });

    it('hides the action button', () => {
      expect(findActionButton().exists()).toBe(false);
    });
  });

  describe('on 409 conflict without workflow_id', () => {
    beforeEach(async () => {
      createWrapper();
      mockAxios.onPost(ACTION_PATH).reply(HTTP_STATUS_CONFLICT, {
        message: 'Already in progress.',
      });
      await findActionButton().trigger('click');
      await axios.waitForAll();
    });

    it('shows the plain conflict alert', () => {
      expect(wrapper.findByTestId('conflict-alert').exists()).toBe(true);
    });

    it('hides the action button', () => {
      expect(findActionButton().exists()).toBe(false);
    });
  });

  describe('on unprocessable entity error', () => {
    beforeEach(async () => {
      createWrapper();
      mockAxios.onPost(ACTION_PATH).reply(HTTP_STATUS_UNPROCESSABLE_ENTITY, {
        message: 'Validation failed.',
      });
      await findActionButton().trigger('click');
      await axios.waitForAll();
    });

    it('calls createAlert with the error message', () => {
      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: 'Validation failed.' }),
      );
    });

    it('shows the action button again', () => {
      expect(findActionButton().exists()).toBe(true);
    });
  });

  describe('when gon path is not set', () => {
    beforeEach(async () => {
      createWrapper({ gonPathKey: 'missing_path' });
      gon.missing_path = undefined;
      await findActionButton().trigger('click');
      await axios.waitForAll();
    });

    it('calls createAlert with the fallback error message', () => {
      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: FALLBACK_ERROR }),
      );
    });
  });

  describe('prerequisite-alerts slot', () => {
    it('renders slot content', () => {
      createWrapper({
        slots: {
          'prerequisite-alerts': '<div data-testid="slot-content">prereq</div>',
        },
      });
      expect(wrapper.findByTestId('slot-content').exists()).toBe(true);
    });
  });
});
