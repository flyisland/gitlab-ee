import { GlButton } from '@gitlab/ui';
import { sendDuoChatCommand } from 'ee/ai/utils';
import SetupCiPipelineButton from 'ee/repository/components/header_area/setup_ci_pipeline_button.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

jest.mock('ee/ai/utils', () => ({
  sendDuoChatCommand: jest.fn(),
}));

describe('SetupCiPipelineButton', () => {
  let wrapper;

  const resourceId = 'gid://gitlab/Project/1';

  const createComponent = () => {
    wrapper = shallowMountExtended(SetupCiPipelineButton, {
      provide: {
        resourceId,
      },
    });
  };

  const findButton = () => wrapper.findComponent(GlButton);

  it('calls sendDuoChatCommand with correct parameters when clicked', () => {
    createComponent();

    findButton().vm.$emit('click');

    expect(sendDuoChatCommand).toHaveBeenCalledWith({
      question: '/pipeline_authoring',
      resourceId,
      agenticPrompt:
        'Analyze this repository and create a CI/CD pipeline that meets the needs of the project.',
      agent: { id: 'gid://gitlab/Ai::FoundationalChatAgent/ci_expert_agent-v1' },
    });
  });
});
