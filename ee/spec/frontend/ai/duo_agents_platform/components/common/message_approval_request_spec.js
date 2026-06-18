import { InputRequestedMessage } from '@gitlab/duo-ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import MessageApprovalRequest from 'ee/ai/duo_agents_platform/components/common/message_approval_request.vue';
import AgentFlowUserApproval from 'ee/ai/duo_agents_platform/components/common/agent_flow_user_approval.vue';

describe('MessageApprovalRequest', () => {
  let wrapper;

  const defaultMessage = {
    id: '1',
    content: 'Approval needed',
    isLastMessage: true,
  };

  const createComponent = ({ message = {}, provide = {} } = {}) => {
    wrapper = shallowMountExtended(MessageApprovalRequest, {
      propsData: {
        message: { ...defaultMessage, ...message },
      },
      provide: {
        canResumeWorkflow: true,
        canUpdateWorkflow: true,
        ...provide,
      },
    });
  };

  const findInputRequestedMessage = () => wrapper.findComponent(InputRequestedMessage);
  const findAgentFlowUserApproval = () => wrapper.findComponent(AgentFlowUserApproval);

  describe('InputRequestedMessage', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders InputRequestedMessage with the message prop', () => {
      expect(findInputRequestedMessage().props('message')).toEqual(defaultMessage);
    });

    it('passes listeners to InputRequestedMessage', () => {
      const listener = jest.fn();
      wrapper = shallowMountExtended(MessageApprovalRequest, {
        propsData: { message: defaultMessage },
        provide: { canResumeWorkflow: true, canUpdateWorkflow: true },
        listeners: { 'custom-event': listener },
      });

      findInputRequestedMessage().vm.$emit('custom-event');

      expect(listener).toHaveBeenCalled();
    });
  });

  describe('AgentFlowUserApproval', () => {
    describe('when canResumeWorkflow, canUpdateWorkflow, and isLastMessage are all true', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the approval component', () => {
        expect(findAgentFlowUserApproval().exists()).toBe(true);
      });
    });

    describe('when canResumeWorkflow is false', () => {
      beforeEach(() => {
        createComponent({ provide: { canResumeWorkflow: false } });
      });

      it('does not render the approval component', () => {
        expect(findAgentFlowUserApproval().exists()).toBe(false);
      });
    });

    describe('when canUpdateWorkflow is false', () => {
      beforeEach(() => {
        createComponent({ provide: { canUpdateWorkflow: false } });
      });

      it('does not render the approval component', () => {
        expect(findAgentFlowUserApproval().exists()).toBe(false);
      });
    });

    describe('when isLastMessage is false', () => {
      beforeEach(() => {
        createComponent({ message: { isLastMessage: false } });
      });

      it('does not render the approval component', () => {
        expect(findAgentFlowUserApproval().exists()).toBe(false);
      });
    });

    describe('when all conditions are false', () => {
      beforeEach(() => {
        createComponent({
          message: { isLastMessage: false },
          provide: { canResumeWorkflow: false, canUpdateWorkflow: false },
        });
      });

      it('does not render the approval component', () => {
        expect(findAgentFlowUserApproval().exists()).toBe(false);
      });
    });
  });
});
