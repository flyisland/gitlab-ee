import { GlFormGroup, GlFormTextarea } from '@gitlab/ui';
import { nextTick } from 'vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentFlowUserApproval from 'ee/ai/duo_agents_platform/components/common/agent_flow_user_approval.vue';
import { resumeWorkflow, cancelWorkflow } from 'ee/rest_api';
import waitForPromises from 'helpers/wait_for_promises';

jest.mock('ee/rest_api', () => ({
  resumeWorkflow: jest.fn(),
  cancelWorkflow: jest.fn(),
}));
const mockApollo = {
  query: jest.fn().mockResolvedValue({}),
};
jest.mock('~/alert', () => ({
  createAlert: jest.fn(),
}));

describe('AgentFlowUserApproval', () => {
  let wrapper;
  const mockWorkflowId = '123';

  const createWrapper = () => {
    wrapper = shallowMountExtended(AgentFlowUserApproval, {
      mocks: {
        $route: { params: { id: mockWorkflowId } },
        $apollo: mockApollo,
      },
    });
  };

  beforeEach(() => {
    jest.clearAllMocks();
    resumeWorkflow.mockResolvedValue({});
    cancelWorkflow.mockResolvedValue({});
    mockApollo.query.mockResolvedValue({});
    createWrapper();
  });

  const findEditForm = () => wrapper.findComponent(GlFormGroup);
  const findTextarea = () => wrapper.findComponent(GlFormTextarea);
  const findModifyButton = () => wrapper.findByTestId('flow-user-approval-modify-button');
  const findRejectButton = () => wrapper.findByTestId('flow-user-approval-reject-button');
  const findApproveButton = () => wrapper.findByTestId('flow-user-approval-approve-button');
  const findCancelButton = () => wrapper.findByTestId('flow-user-approval-cancel-button');
  const findSubmitButton = () => wrapper.findByTestId('flow-user-approval-submit-button');

  const enterEditMode = async () => {
    findModifyButton().vm.$emit('click');
    await nextTick();
  };

  const exitEditMode = async () => {
    findCancelButton().vm.$emit('click');
    await nextTick();
  };

  const fillAndSubmitForm = async (text) => {
    findTextarea().vm.$emit('input', text);
    await nextTick();
    findSubmitButton().vm.$emit('click');
    await waitForPromises();
  };

  const assertApprovalMode = () => {
    expect(findModifyButton().exists()).toBe(true);
    expect(findRejectButton().exists()).toBe(true);
    expect(findApproveButton().exists()).toBe(true);
    expect(findEditForm().exists()).toBe(false);
  };

  const assertEditMode = () => {
    expect(findEditForm().exists()).toBe(true);
    expect(findCancelButton().exists()).toBe(true);
    expect(findSubmitButton().exists()).toBe(true);
    expect(findModifyButton().exists()).toBe(false);
    expect(findRejectButton().exists()).toBe(false);
    expect(findApproveButton().exists()).toBe(false);
  };

  const assertHidden = () => {
    expect(findModifyButton().exists()).toBe(false);
    expect(findRejectButton().exists()).toBe(false);
    expect(findApproveButton().exists()).toBe(false);
    expect(findEditForm().exists()).toBe(false);
  };

  describe('initial state', () => {
    it('shows approval buttons and hides edit form', () => {
      assertApprovalMode();
    });
  });

  describe('mode transitions', () => {
    it('enters edit mode when modify button is clicked', async () => {
      await enterEditMode();
      assertEditMode();
    });

    it('returns to approval mode when cancel is clicked', async () => {
      await enterEditMode();
      await exitEditMode();
      assertApprovalMode();
    });

    it('returns to approval mode after submitting a modification', async () => {
      await enterEditMode();
      await fillAndSubmitForm('Change the plan');
      assertApprovalMode();
    });
  });

  describe('submit button', () => {
    it('is disabled when no modification text has been entered', async () => {
      await enterEditMode();
      findTextarea().vm.$emit('');
      await nextTick();

      expect(findSubmitButton().attributes('disabled')).toBeDefined();
    });

    it('makes API call with user input when clicked', async () => {
      await enterEditMode();
      await fillAndSubmitForm('Change the plan');

      expect(resumeWorkflow).toHaveBeenCalledWith(mockWorkflowId, {
        humanApproval: false,
        humanMessage: 'Change the plan',
      });
    });

    it('disables button during submission and returns to approval mode on success', async () => {
      let resolvePost;
      resumeWorkflow.mockImplementation(
        () =>
          new Promise((resolve) => {
            resolvePost = resolve;
          }),
      );

      await enterEditMode();
      findTextarea().vm.$emit('input', 'Change the plan');
      await nextTick();
      findSubmitButton().vm.$emit('click');
      await nextTick();

      expect(findSubmitButton().attributes('disabled')).toBeDefined();

      resolvePost({});
      await waitForPromises();

      assertApprovalMode();
    });
  });

  describe('approve button', () => {
    it('makes API call with correct payload when clicked', async () => {
      findApproveButton().vm.$emit('click');
      await waitForPromises();

      expect(resumeWorkflow).toHaveBeenCalledWith(mockWorkflowId, {
        humanApproval: true,
      });
    });

    it('disables button during submission and hides component on success', async () => {
      let resolvePost;
      resumeWorkflow.mockImplementation(
        () =>
          new Promise((resolve) => {
            resolvePost = resolve;
          }),
      );

      findApproveButton().vm.$emit('click');
      await nextTick();

      expect(findApproveButton().attributes('disabled')).toBeDefined();

      resolvePost({});
      await waitForPromises();

      assertHidden();
    });
  });

  describe('reject button', () => {
    it('makes API call with correct payload when clicked', async () => {
      findRejectButton().vm.$emit('click');
      await waitForPromises();

      expect(cancelWorkflow).toHaveBeenCalledWith(mockWorkflowId);
    });

    it('disables button during submission and hides component on success', async () => {
      let resolvePost;
      cancelWorkflow.mockImplementation(
        () =>
          new Promise((resolve) => {
            resolvePost = resolve;
          }),
      );

      findRejectButton().vm.$emit('click');
      await nextTick();

      expect(findRejectButton().attributes('disabled')).toBeDefined();

      resolvePost({});
      await waitForPromises();

      assertHidden();
    });
  });
});
